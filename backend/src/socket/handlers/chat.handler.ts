import { Server } from 'socket.io';
import { prisma } from '../../config/database';
import { RequestStatus } from '@prisma/client';
import { logger } from '../../utils/logger';
import { AuthenticatedSocket } from '../middleware/socket-auth.middleware';
import { NotificationService } from '../../services/notification.service';

// Helper function to check if users have blocked each other
async function areUsersBlocked(userId1: string, userId2: string): Promise<boolean> {
  const block = await prisma.block.findFirst({
    where: {
      OR: [
        { blockerId: userId1, blockedId: userId2 },
        { blockerId: userId2, blockedId: userId1 },
      ],
    },
  });
  return !!block;
}

// Standardized socket error handler
function emitSocketError(
  socket: AuthenticatedSocket,
  message: string,
  context: Record<string, unknown> = {}
): void {
  logger.warn({ ...context, userId: socket.user?.userId }, `Socket error: ${message}`);
  socket.emit('error', { message });
}

// Basic XSS sanitization - removes potential HTML/script tags
function sanitizeMessage(content: string): string {
  return content
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;')
    .replace(/\//g, '&#x2F;')
    .trim();
}

export function registerChatHandlers(io: Server, socket: AuthenticatedSocket) {
  const userId = socket.user!.userId;

  // Join conversation room
  socket.on('join_conversation', async (data: { requestId: string }) => {
    try {
      const { requestId } = data;

      // Verify user is part of this conversation
      const request = await prisma.tripRequest.findUnique({
        where: { id: requestId },
        include: {
          trip: true,
        },
      });

      if (!request) {
        return emitSocketError(socket, 'Request not found', { requestId });
      }

      // User must be either the requester or trip owner
      if (request.requesterId !== userId && request.trip.userId !== userId) {
        return emitSocketError(socket, 'Not authorized to join this conversation', { requestId });
      }

      // Only allow joining conversations for accepted requests
      if (request.status !== RequestStatus.ACCEPTED) {
        return emitSocketError(socket, 'Conversation is only available for accepted requests', { requestId, status: request.status });
      }

      // Check if users have blocked each other
      const otherUserId = userId === request.requesterId ? request.trip.userId : request.requesterId;
      if (await areUsersBlocked(userId, otherUserId)) {
        return emitSocketError(socket, 'Cannot join this conversation', { requestId });
      }

      // Join room
      socket.join(`request_${requestId}`);
      logger.info({ userId, requestId }, 'User joined conversation');

      socket.emit('joined_conversation', { requestId });
    } catch (error) {
      logger.error({ error, userId }, 'Error joining conversation');
      emitSocketError(socket, 'Failed to join conversation');
    }
  });

  // Leave conversation room
  socket.on('leave_conversation', async (data: { requestId: string }) => {
    try {
      const { requestId } = data;
      socket.leave(`request_${requestId}`);
      logger.info({ userId, requestId }, 'User left conversation');
    } catch (error) {
      logger.error({ error, userId }, 'Error leaving conversation');
    }
  });

  // Send message
  socket.on('send_message', async (data: { requestId: string; content: string }) => {
    try {
      const { requestId, content } = data;

      if (!content || content.trim().length === 0) {
        return emitSocketError(socket, 'Message content cannot be empty', { requestId });
      }

      // Validate message length (prevent extremely long messages)
      if (content.trim().length > 5000) {
        return emitSocketError(socket, 'Message is too long (max 5000 characters)', { requestId });
      }

      // Verify user is part of this conversation
      const request = await prisma.tripRequest.findUnique({
        where: { id: requestId },
        include: {
          trip: true,
        },
      });

      if (!request) {
        return emitSocketError(socket, 'Request not found', { requestId });
      }

      // Only allow messaging for accepted requests
      if (request.status !== RequestStatus.ACCEPTED) {
        return emitSocketError(socket, 'Messaging is only available for accepted requests', { requestId, status: request.status });
      }

      // Determine sender and receiver
      const senderId = userId;
      const receiverId =
        userId === request.requesterId ? request.trip.userId : request.requesterId;

      if (senderId !== request.requesterId && senderId !== request.trip.userId) {
        return emitSocketError(socket, 'Not authorized to send message in this conversation', { requestId });
      }

      // Check if users have blocked each other
      if (await areUsersBlocked(senderId, receiverId)) {
        return emitSocketError(socket, 'Cannot send message to this user', { requestId });
      }

      // Sanitize message content to prevent XSS
      const sanitizedContent = sanitizeMessage(content);

      // Create message
      const message = await prisma.message.create({
        data: {
          senderId,
          receiverId,
          tripRequestId: requestId,
          content: sanitizedContent,
        },
        include: {
          sender: {
            select: {
              id: true,
              fullName: true,
              profilePhotoUrl: true,
            },
          },
        },
      });

      // Emit to room
      io.to(`request_${requestId}`).emit('message_received', message);

      // Create notification for receiver (will also emit via socket)
      await NotificationService.createNotification({
        userId: receiverId,
        type: 'NEW_MESSAGE',
        title: 'New Message',
        body: `${message.sender.fullName} sent you a message`,
        data: {
          messageId: message.id,
          requestId,
          senderId,
        },
      });

      logger.info({ messageId: message.id, requestId }, 'Message sent');
    } catch (error) {
      logger.error({ error, userId }, 'Error sending message');
      emitSocketError(socket, 'Failed to send message');
    }
  });

  // Typing indicators
  socket.on('typing_start', (data: { requestId: string }) => {
    try {
      const { requestId } = data;
      socket.to(`request_${requestId}`).emit('user_typing', {
        userId,
        requestId,
      });
    } catch (error) {
      logger.error({ error, userId }, 'Error broadcasting typing start');
    }
  });

  socket.on('typing_stop', (data: { requestId: string }) => {
    try {
      const { requestId } = data;
      socket.to(`request_${requestId}`).emit('user_stopped_typing', {
        userId,
        requestId,
      });
    } catch (error) {
      logger.error({ error, userId }, 'Error broadcasting typing stop');
    }
  });

  // Mark message as read
  socket.on('mark_read', async (data: { messageId: string }) => {
    try {
      const { messageId } = data;

      // Fetch message with request details to verify conversation membership
      const message = await prisma.message.findUnique({
        where: { id: messageId },
        include: {
          tripRequest: {
            include: {
              trip: {
                select: { userId: true },
              },
            },
          },
        },
      });

      if (!message) {
        return emitSocketError(socket, 'Message not found', { messageId });
      }

      // Verify user is the intended receiver
      if (message.receiverId !== userId) {
        return emitSocketError(socket, 'Not authorized to mark this message as read', { messageId });
      }

      // Additional check: verify user is part of this conversation
      const isRequester = message.tripRequest.requesterId === userId;
      const isTripOwner = message.tripRequest.trip.userId === userId;
      if (!isRequester && !isTripOwner) {
        return emitSocketError(socket, 'Not authorized - not part of this conversation', { messageId });
      }

      // Verify request is accepted (messages should only be marked read for accepted requests)
      if (message.tripRequest.status !== RequestStatus.ACCEPTED) {
        return emitSocketError(socket, 'Cannot mark message as read - request not accepted', { messageId });
      }

      await prisma.message.update({
        where: { id: messageId },
        data: { isRead: true },
      });

      io.to(`request_${message.tripRequestId}`).emit('message_read', {
        messageId,
      });

      logger.info({ messageId, userId }, 'Message marked as read');
    } catch (error) {
      logger.error({ error, userId }, 'Error marking message as read');
      emitSocketError(socket, 'Failed to mark message as read');
    }
  });

  // Mark all messages in a conversation as read
  socket.on('mark_all_read', async (data: { requestId: string }) => {
    try {
      const { requestId } = data;

      // Verify user is part of this conversation
      const request = await prisma.tripRequest.findUnique({
        where: { id: requestId },
        include: {
          trip: {
            select: { userId: true },
          },
        },
      });

      if (!request) {
        return emitSocketError(socket, 'Request not found', { requestId });
      }

      const isRequester = request.requesterId === userId;
      const isTripOwner = request.trip.userId === userId;
      if (!isRequester && !isTripOwner) {
        return emitSocketError(socket, 'Not authorized - not part of this conversation', { requestId });
      }

      if (request.status !== RequestStatus.ACCEPTED) {
        return emitSocketError(socket, 'Cannot mark messages as read - request not accepted', { requestId });
      }

      // Mark all unread messages for this user as read
      const result = await prisma.message.updateMany({
        where: {
          tripRequestId: requestId,
          receiverId: userId,
          isRead: false,
        },
        data: { isRead: true },
      });

      io.to(`request_${requestId}`).emit('all_messages_read', {
        requestId,
        userId,
        count: result.count,
      });

      logger.info({ requestId, userId, count: result.count }, 'All messages marked as read');
    } catch (error) {
      logger.error({ error, userId }, 'Error marking all messages as read');
      emitSocketError(socket, 'Failed to mark messages as read');
    }
  });
}

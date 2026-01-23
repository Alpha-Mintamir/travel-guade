import { Server } from 'socket.io';
import { prisma } from '../../config/database';
import { logger } from '../../utils/logger';
import { AuthenticatedSocket } from '../middleware/socket-auth.middleware';

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
        socket.emit('error', { message: 'Request not found' });
        return;
      }

      // User must be either the requester or trip owner
      if (request.requesterId !== userId && request.trip.userId !== userId) {
        socket.emit('error', { message: 'Not authorized to join this conversation' });
        return;
      }

      // Join room
      socket.join(`request_${requestId}`);
      logger.info({ userId, requestId }, 'User joined conversation');

      socket.emit('joined_conversation', { requestId });
    } catch (error) {
      logger.error({ error }, 'Error joining conversation');
      socket.emit('error', { message: 'Failed to join conversation' });
    }
  });

  // Leave conversation room
  socket.on('leave_conversation', async (data: { requestId: string }) => {
    try {
      const { requestId } = data;
      socket.leave(`request_${requestId}`);
      logger.info({ userId, requestId }, 'User left conversation');
    } catch (error) {
      logger.error({ error }, 'Error leaving conversation');
    }
  });

  // Send message
  socket.on('send_message', async (data: { requestId: string; content: string }) => {
    try {
      const { requestId, content } = data;

      if (!content || content.trim().length === 0) {
        socket.emit('error', { message: 'Message content cannot be empty' });
        return;
      }

      // Verify user is part of this conversation
      const request = await prisma.tripRequest.findUnique({
        where: { id: requestId },
        include: {
          trip: true,
        },
      });

      if (!request) {
        socket.emit('error', { message: 'Request not found' });
        return;
      }

      // Determine sender and receiver
      const senderId = userId;
      const receiverId =
        userId === request.requesterId ? request.trip.userId : request.requesterId;

      if (senderId !== request.requesterId && senderId !== request.trip.userId) {
        socket.emit('error', { message: 'Not authorized to send message in this conversation' });
        return;
      }

      // Create message
      const message = await prisma.message.create({
        data: {
          senderId,
          receiverId,
          tripRequestId: requestId,
          content: content.trim(),
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

      // Create notification for receiver
      await prisma.notification.create({
        data: {
          userId: receiverId,
          type: 'NEW_MESSAGE',
          title: 'New Message',
          body: `${message.sender.fullName} sent you a message`,
          data: {
            messageId: message.id,
            requestId,
            senderId,
          },
        },
      });

      logger.info({ messageId: message.id, requestId }, 'Message sent');
    } catch (error) {
      logger.error({ error }, 'Error sending message');
      socket.emit('error', { message: 'Failed to send message' });
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
      logger.error({ error }, 'Error broadcasting typing start');
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
      logger.error({ error }, 'Error broadcasting typing stop');
    }
  });

  // Mark message as read
  socket.on('mark_read', async (data: { messageId: string }) => {
    try {
      const { messageId } = data;

      const message = await prisma.message.findUnique({
        where: { id: messageId },
      });

      if (!message) {
        socket.emit('error', { message: 'Message not found' });
        return;
      }

      if (message.receiverId !== userId) {
        socket.emit('error', { message: 'Not authorized' });
        return;
      }

      await prisma.message.update({
        where: { id: messageId },
        data: { isRead: true },
      });

      io.to(`request_${message.tripRequestId}`).emit('message_read', {
        messageId,
      });

      logger.info({ messageId }, 'Message marked as read');
    } catch (error) {
      logger.error({ error }, 'Error marking message as read');
      socket.emit('error', { message: 'Failed to mark message as read' });
    }
  });
}

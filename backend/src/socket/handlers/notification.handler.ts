import { Server } from 'socket.io';
import { logger } from '../../utils/logger';
import { AuthenticatedSocket } from '../middleware/socket-auth.middleware';

export function registerNotificationHandlers(_io: Server, socket: AuthenticatedSocket) {
  const userId = socket.user!.userId;

  // Join user's personal notification room
  socket.join(`user_${userId}`);
  logger.info({ userId }, 'User joined notification room');

  // Disconnect handler
  socket.on('disconnect', () => {
    logger.info({ userId }, 'User disconnected');
  });
}

// Helper function to emit notification to specific user
export function emitNotificationToUser(io: Server, userId: string, notification: any) {
  io.to(`user_${userId}`).emit('notification', notification);
  logger.info({ userId, notificationId: notification.id }, 'Notification emitted to user');
}

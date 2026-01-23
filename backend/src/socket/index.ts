import { Server as HTTPServer } from 'http';
import { Server } from 'socket.io';
import { socketAuthMiddleware, AuthenticatedSocket } from './middleware/socket-auth.middleware';
import { registerChatHandlers } from './handlers/chat.handler';
import { registerNotificationHandlers } from './handlers/notification.handler';
import { logger } from '../utils/logger';
import { env } from '../config/env';

export function initializeSocketIO(httpServer: HTTPServer): Server {
  const allowedOrigins = env.ALLOWED_ORIGINS.split(',');

  const io = new Server(httpServer, {
    cors: {
      origin: allowedOrigins,
      credentials: true,
    },
    transports: ['websocket', 'polling'],
  });

  // Authentication middleware
  io.use(socketAuthMiddleware);

  // Connection handler
  io.on('connection', (socket: AuthenticatedSocket) => {
    const userId = socket.user?.userId;
    logger.info({ userId, socketId: socket.id }, 'Client connected');

    // Register handlers
    registerChatHandlers(io, socket);
    registerNotificationHandlers(io, socket);

    socket.on('disconnect', (reason) => {
      logger.info({ userId, socketId: socket.id, reason }, 'Client disconnected');
    });
  });

  logger.info('Socket.io initialized');

  return io;
}

export { emitNotificationToUser } from './handlers/notification.handler';

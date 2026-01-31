import { Server as HTTPServer } from 'http';
import { Server } from 'socket.io';
import { socketAuthMiddleware, AuthenticatedSocket } from './middleware/socket-auth.middleware';
import { registerChatHandlers } from './handlers/chat.handler';
import { registerNotificationHandlers } from './handlers/notification.handler';
import { logger } from '../utils/logger';
import { env } from '../config/env';

// Store io instance for global access
let ioInstance: Server | null = null;

export function getIO(): Server | null {
  return ioInstance;
}

export function initializeSocketIO(httpServer: HTTPServer): Server {
  // Handle CORS origins - if '*' is set, allow all origins
  const corsOrigin = env.ALLOWED_ORIGINS === '*' 
    ? true 
    : env.ALLOWED_ORIGINS.split(',').map(origin => origin.trim()).filter(Boolean);

  const io = new Server(httpServer, {
    cors: {
      origin: corsOrigin,
      credentials: true,
    },
    transports: ['websocket', 'polling'],
  });

  // Store instance for global access
  ioInstance = io;

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

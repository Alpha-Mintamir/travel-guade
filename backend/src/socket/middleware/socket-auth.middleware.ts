import { Socket } from 'socket.io';
import { logger } from '../../utils/logger';
import { prisma } from '../../config/database';

interface UserPayload {
  userId: string;
  email: string;
}

export interface AuthenticatedSocket extends Socket {
  user?: UserPayload;
}

export const socketAuthMiddleware = async (socket: AuthenticatedSocket, next: any) => {
  try {
    const token = socket.handshake.auth.token || socket.handshake.headers.authorization?.replace('Bearer ', '');

    if (!token) {
      logger.warn('Socket connection rejected: No token provided');
      return next(new Error('Authentication error: No token provided'));
    }

    // Validate Better Auth session token
    const session = await prisma.session.findUnique({
      where: { token },
      include: { user: true },
    });

    if (!session || session.expiresAt < new Date()) {
      logger.warn('Socket connection rejected: Invalid or expired token');
      return next(new Error('Authentication error: Invalid token'));
    }

    socket.user = {
      userId: session.userId,
      email: session.user.email,
    };
    
    logger.info({ userId: session.userId }, 'Socket authenticated');
    next();
  } catch (error) {
    logger.warn({ error }, 'Socket authentication failed');
    next(new Error('Authentication error: Invalid token'));
  }
};

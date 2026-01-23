import { Request, Response, NextFunction } from 'express';
import { UnauthorizedError } from '../utils/errors';
import { prisma } from '../config/database';

export const authenticate = async (
  req: Request,
  _res: Response,
  next: NextFunction
) => {
  try {
    // Get token from Authorization header (Flutter sends it here)
    const token = req.headers.authorization?.replace('Bearer ', '');

    if (!token) {
      throw new UnauthorizedError('No token provided');
    }

    // Validate session token with Better Auth
    const session = await prisma.session.findUnique({
      where: { token },
      include: { user: true },
    });

    if (!session) {
      throw new UnauthorizedError('Invalid token');
    }

    if (session.expiresAt < new Date()) {
      throw new UnauthorizedError('Token expired');
    }

    // Set user info in request
    req.user = {
      userId: session.userId,
      email: session.user.email,
    };

    next();
  } catch (error) {
    next(error);
  }
};

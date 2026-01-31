import { Request, Response, NextFunction } from 'express';
import { ApiResponse } from '../utils/response';
import { prisma } from '../config/database';
import { BadRequestError, UnauthorizedError, ConflictError } from '../utils/errors';
import bcrypt from 'bcrypt';
import crypto from 'crypto';
import { EmailService } from '../services/email.service';
import { generateGenderedAvatarUrl } from '../utils/avatar';

export class AuthController {
  /**
   * Register a new user
   * Flutter expects: { email, password, fullName, gender?, dateOfBirth? }
   * Returns: { token, user }
   */
  static async register(req: Request, res: Response, next: NextFunction) {
    try {
      const { email, password, fullName, gender, dateOfBirth } = req.body;

      // Check if user already exists
      const existingUser = await prisma.user.findUnique({
        where: { email },
      });

      if (existingUser) {
        throw new ConflictError('Email already registered');
      }

      // Hash password
      const passwordHash = await bcrypt.hash(password, 10);

      // Generate verification token
      const verificationToken = crypto.randomBytes(32).toString('hex');
      const verificationExpiry = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

      // Generate a random seed for the avatar (using email + timestamp for uniqueness)
      const avatarSeed = `${email}-${Date.now()}`;
      // Generate gender-appropriate avatar
      const avatarUrl = generateGenderedAvatarUrl(avatarSeed, gender || null);

      // Create user with random avatar
      const user = await prisma.user.create({
        data: {
          email,
          name: fullName,
          fullName,
          emailVerified: false,
          gender: gender || null,
          dateOfBirth: dateOfBirth ? new Date(dateOfBirth) : null,
          profilePhotoUrl: avatarUrl,
          image: avatarUrl, // Better Auth field
        },
      });

      // Create account with password
      await prisma.account.create({
        data: {
          id: crypto.randomUUID(),
          userId: user.id,
          accountId: email,
          providerId: 'credential',
          password: passwordHash,
        },
      });

      // Create verification token
      await prisma.verification.create({
        data: {
          id: crypto.randomUUID(),
          identifier: email,
          value: verificationToken,
          expiresAt: verificationExpiry,
        },
      });

      // Send verification email
      await EmailService.sendVerificationEmail(email, verificationToken);

      // Create session
      const sessionToken = crypto.randomBytes(32).toString('hex');
      const session = await prisma.session.create({
        data: {
          id: crypto.randomUUID(),
          userId: user.id,
          token: sessionToken,
          expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
        },
      });

      // Format response for Flutter
      ApiResponse.success(
        res,
        {
          token: session.token,
          refreshToken: session.token,
          user: {
            id: user.id,
            email: user.email,
            fullName: user.fullName,
            profilePhotoUrl: user.profilePhotoUrl,
            cityOfResidence: user.cityOfResidence,
            bio: user.bio,
            travelPreferences: user.travelPreferences,
            emailVerified: user.emailVerified,
            gender: user.gender,
            dateOfBirth: user.dateOfBirth,
            createdAt: user.createdAt,
          },
        },
        'Registration successful',
        201
      );
    } catch (error) {
      next(error);
    }
  }

  /**
   * Login user
   * Flutter expects: { email, password }
   * Returns: { token, user }
   */
  static async login(req: Request, res: Response, next: NextFunction) {
    try {
      const { email, password } = req.body;

      // Find user
      const user = await prisma.user.findUnique({
        where: { email },
      });

      if (!user) {
        throw new UnauthorizedError('Invalid credentials');
      }

      // Find account
      const account = await prisma.account.findFirst({
        where: {
          userId: user.id,
          providerId: 'credential',
        },
      });

      if (!account || !account.password) {
        throw new UnauthorizedError('Invalid credentials');
      }

      // Verify password
      const isValid = await bcrypt.compare(password, account.password);

      if (!isValid) {
        throw new UnauthorizedError('Invalid credentials');
      }

      // Create new session
      const sessionToken = crypto.randomBytes(32).toString('hex');
      const session = await prisma.session.create({
        data: {
          id: crypto.randomUUID(),
          userId: user.id,
          token: sessionToken,
          expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
        },
      });

      // Get full user data including gender and dateOfBirth
      const fullUser = await prisma.user.findUnique({
        where: { id: user.id },
      });

      // Format response for Flutter
      ApiResponse.success(res, {
        token: session.token,
        refreshToken: session.token,
        user: {
          id: user.id,
          email: user.email,
          fullName: user.fullName,
          profilePhotoUrl: user.profilePhotoUrl,
          cityOfResidence: user.cityOfResidence,
          bio: user.bio,
          travelPreferences: user.travelPreferences,
          emailVerified: user.emailVerified,
          gender: fullUser?.gender,
          dateOfBirth: fullUser?.dateOfBirth,
          createdAt: user.createdAt,
        },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Verify email
   * Flutter expects: { token }
   */
  static async verifyEmail(req: Request, res: Response, next: NextFunction) {
    try {
      const { token } = req.body;

      // Find verification token
      const verification = await prisma.verification.findFirst({
        where: {
          value: token,
          expiresAt: {
            gt: new Date(),
          },
        },
      });

      if (!verification) {
        throw new BadRequestError('Invalid or expired verification token');
      }

      // Update user
      await prisma.user.update({
        where: { email: verification.identifier },
        data: { emailVerified: true },
      });

      // Delete used verification token
      await prisma.verification.delete({
        where: { id: verification.id },
      });

      ApiResponse.success(res, { message: 'Email verified successfully' });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Request password reset
   * Flutter expects: { email }
   */
  static async forgotPassword(req: Request, res: Response, next: NextFunction) {
    try {
      const { email } = req.body;

      const user = await prisma.user.findUnique({
        where: { email },
      });

      if (user) {
        // Generate reset token
        const resetToken = crypto.randomBytes(32).toString('hex');
        const resetExpiry = new Date(Date.now() + 60 * 60 * 1000); // 1 hour

        // Store verification token
        await prisma.verification.create({
          data: {
            id: crypto.randomUUID(),
            identifier: email,
            value: resetToken,
            expiresAt: resetExpiry,
          },
        });

        // Send reset email
        await EmailService.sendPasswordResetEmail(email, resetToken);
      }

      // Always return success to prevent email enumeration
      ApiResponse.success(res, {
        message: 'If the email exists, a reset link has been sent',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Reset password
   * Flutter expects: { token, password }
   */
  static async resetPassword(req: Request, res: Response, next: NextFunction) {
    try {
      const { token, password } = req.body;

      // Find verification token
      const verification = await prisma.verification.findFirst({
        where: {
          value: token,
          expiresAt: {
            gt: new Date(),
          },
        },
      });

      if (!verification) {
        throw new BadRequestError('Invalid or expired reset token');
      }

      // Hash new password
      const passwordHash = await bcrypt.hash(password, 10);

      // Update account password
      const user = await prisma.user.findUnique({
        where: { email: verification.identifier },
      });

      if (!user) {
        throw new BadRequestError('User not found');
      }

      await prisma.account.updateMany({
        where: {
          userId: user.id,
          providerId: 'credential',
        },
        data: {
          password: passwordHash,
        },
      });

      // Delete used verification token
      await prisma.verification.delete({
        where: { id: verification.id },
      });

      ApiResponse.success(res, { message: 'Password reset successfully' });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Refresh token
   * Flutter expects: { refreshToken }
   */
  static async refreshToken(req: Request, res: Response, next: NextFunction) {
    try {
      const { refreshToken } = req.body;

      // Validate session token
      const session = await prisma.session.findUnique({
        where: { token: refreshToken },
        include: { user: true },
      });

      if (!session || session.expiresAt < new Date()) {
        throw new UnauthorizedError('Invalid or expired token');
      }

      // Extend session expiry
      await prisma.session.update({
        where: { id: session.id },
        data: {
          expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
        },
      });

      ApiResponse.success(res, { token: session.token });
    } catch (error) {
      next(error);
    }
  }
}

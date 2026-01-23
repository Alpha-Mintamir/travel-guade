import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller';
import { validate } from '../middleware/validate.middleware';
import {
  registerSchema,
  loginSchema,
  verifyEmailSchema,
  forgotPasswordSchema,
  resetPasswordSchema,
  refreshTokenSchema,
} from '../schemas/auth.schema';
import { auth } from '../lib/auth';

const router = Router();

// Flutter-compatible endpoints (wrap Better Auth)
router.post('/register', validate(registerSchema), AuthController.register);
router.post('/login', validate(loginSchema), AuthController.login);
router.post('/verify-email', validate(verifyEmailSchema), AuthController.verifyEmail);
router.post('/forgot-password', validate(forgotPasswordSchema), AuthController.forgotPassword);
router.post('/reset-password', validate(resetPasswordSchema), AuthController.resetPassword);
router.post('/refresh-token', validate(refreshTokenSchema), AuthController.refreshToken);

// Mount Better Auth's native API (for future web client or additional features)
// This handles all Better Auth endpoints at /api/auth/*
router.all('/*', async (req, _res) => {
  return auth.handler(req as any);
});

export default router;

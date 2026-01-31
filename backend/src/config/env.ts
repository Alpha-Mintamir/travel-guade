import { z } from 'zod';
import dotenv from 'dotenv';
import path from 'path';

// Load environment variables from .env file (skip in Vercel)
if (!process.env.VERCEL) {
  dotenv.config({ path: path.resolve(__dirname, '../../.env') });
}

const isProduction = process.env.NODE_ENV === 'production';

// Base schema with optional defaults for development
const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.string().default('3000'),
  DATABASE_URL: z.string().min(1, 'DATABASE_URL is required'),
  BETTER_AUTH_SECRET: z.string().min(32, 'BETTER_AUTH_SECRET must be at least 32 characters'),
  BETTER_AUTH_URL: z.string().url().default('http://localhost:3000'),
  RESEND_API_KEY: z.string().default(''),
  EMAIL_FROM: z.string().default('noreply@example.com'),
  CLOUDINARY_CLOUD_NAME: z.string().default(''),
  CLOUDINARY_API_KEY: z.string().default(''),
  CLOUDINARY_API_SECRET: z.string().default(''),
  FRONTEND_URL: z.string().url().default('http://localhost:3000'),
  ALLOWED_ORIGINS: z.string().default('*'),
});

export type Env = z.infer<typeof envSchema>;

const INSECURE_SECRET = 'default-secret-change-in-production-32chars';

export function validateEnv(): Env {
  const result = envSchema.safeParse(process.env);
  
  if (!result.success) {
    const errors = result.error.format();
    console.error('❌ Invalid environment variables:');
    console.error(JSON.stringify(errors, null, 2));
    
    if (isProduction) {
      // In production, fail fast on invalid configuration
      throw new Error('Invalid environment configuration. Check the logs above for details.');
    }
    
    // In development, provide helpful defaults but warn
    console.warn('⚠️ Using development defaults. Set proper environment variables before deploying.');
    return {
      NODE_ENV: 'development',
      PORT: '3000',
      DATABASE_URL: process.env.DATABASE_URL || '',
      BETTER_AUTH_SECRET: process.env.BETTER_AUTH_SECRET || INSECURE_SECRET,
      BETTER_AUTH_URL: process.env.BETTER_AUTH_URL || 'http://localhost:3000',
      RESEND_API_KEY: process.env.RESEND_API_KEY || '',
      EMAIL_FROM: process.env.EMAIL_FROM || 'noreply@example.com',
      CLOUDINARY_CLOUD_NAME: process.env.CLOUDINARY_CLOUD_NAME || '',
      CLOUDINARY_API_KEY: process.env.CLOUDINARY_API_KEY || '',
      CLOUDINARY_API_SECRET: process.env.CLOUDINARY_API_SECRET || '',
      FRONTEND_URL: process.env.FRONTEND_URL || 'http://localhost:3000',
      ALLOWED_ORIGINS: process.env.ALLOWED_ORIGINS || '*',
    };
  }
  
  const env = result.data;
  
  // Warn about insecure configuration in production
  if (isProduction) {
    if (env.BETTER_AUTH_SECRET === INSECURE_SECRET) {
      throw new Error('BETTER_AUTH_SECRET is using the default insecure value. Set a unique secret for production.');
    }
    if (env.ALLOWED_ORIGINS === '*') {
      console.warn('⚠️ ALLOWED_ORIGINS is set to "*". Consider restricting to specific origins in production.');
    }
    if (!env.DATABASE_URL) {
      throw new Error('DATABASE_URL is required in production.');
    }
  }
  
  return env;
}

export const env = validateEnv();

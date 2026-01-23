import { z } from 'zod';
import dotenv from 'dotenv';
import path from 'path';

// Load environment variables from .env file (skip in Vercel)
if (!process.env.VERCEL) {
  dotenv.config({ path: path.resolve(__dirname, '../../.env') });
}

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('production'),
  PORT: z.string().default('3000'),
  DATABASE_URL: z.string().default(''),
  BETTER_AUTH_SECRET: z.string().default('default-secret-change-in-production-32chars'),
  BETTER_AUTH_URL: z.string().default('https://travel-guade-fukm.vercel.app'),
  RESEND_API_KEY: z.string().default(''),
  EMAIL_FROM: z.string().default('noreply@example.com'),
  CLOUDINARY_CLOUD_NAME: z.string().default(''),
  CLOUDINARY_API_KEY: z.string().default(''),
  CLOUDINARY_API_SECRET: z.string().default(''),
  FRONTEND_URL: z.string().default('https://travel-guade-fukm.vercel.app'),
  ALLOWED_ORIGINS: z.string().default('*'),
});

export type Env = z.infer<typeof envSchema>;

export function validateEnv(): Env {
  try {
    return envSchema.parse(process.env);
  } catch (error) {
    console.error('❌ Invalid environment variables:', error);
    // Return defaults instead of crashing in serverless
    return {
      NODE_ENV: 'production',
      PORT: '3000',
      DATABASE_URL: process.env.DATABASE_URL || '',
      BETTER_AUTH_SECRET: process.env.BETTER_AUTH_SECRET || 'default-secret-change-in-production-32chars',
      BETTER_AUTH_URL: process.env.BETTER_AUTH_URL || 'https://travel-guade-fukm.vercel.app',
      RESEND_API_KEY: process.env.RESEND_API_KEY || '',
      EMAIL_FROM: process.env.EMAIL_FROM || 'noreply@example.com',
      CLOUDINARY_CLOUD_NAME: process.env.CLOUDINARY_CLOUD_NAME || '',
      CLOUDINARY_API_KEY: process.env.CLOUDINARY_API_KEY || '',
      CLOUDINARY_API_SECRET: process.env.CLOUDINARY_API_SECRET || '',
      FRONTEND_URL: process.env.FRONTEND_URL || 'https://travel-guade-fukm.vercel.app',
      ALLOWED_ORIGINS: process.env.ALLOWED_ORIGINS || '*',
    };
  }
}

export const env = validateEnv();

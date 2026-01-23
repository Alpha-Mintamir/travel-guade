import type { VercelRequest, VercelResponse } from '@vercel/node';
import app from '../src/app';
import { connectDatabase } from '../src/config/database';

// Track if database is connected
let isConnected = false;

export default async function handler(req: VercelRequest, res: VercelResponse) {
  // Connect to database once
  if (!isConnected) {
    await connectDatabase();
    isConnected = true;
  }
  
  // Let Express handle the request
  return app(req, res);
}

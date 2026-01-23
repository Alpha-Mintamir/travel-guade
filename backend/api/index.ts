import app from '../src/app';
import { connectDatabase } from '../src/config/database';

let isDbConnected = false;

export default async function handler(req: any, res: any) {
  try {
    // Connect to database once
    if (!isDbConnected) {
      await connectDatabase();
      isDbConnected = true;
    }
    
    // Pass to Express
    return app(req, res);
  } catch (error: any) {
    console.error('Handler error:', error);
    return res.status(500).json({
      error: 'Internal Server Error',
      message: error.message,
      stack: process.env.NODE_ENV === 'development' ? error.stack : undefined,
    });
  }
}

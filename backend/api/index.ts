import app from '../src/app';
import { connectDatabase } from '../src/config/database';

// Connect to database on cold start (non-blocking)
let dbConnected = false;
const initDb = async () => {
  if (!dbConnected) {
    try {
      await connectDatabase();
      dbConnected = true;
    } catch (error) {
      console.error('Database connection error:', error);
    }
  }
};

// Start connection
initDb();

// Export Express app as default for Vercel
export default app;

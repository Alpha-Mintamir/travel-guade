import app from '../src/app';
import { connectDatabase } from '../src/config/database';

// Connect to database on cold start
connectDatabase().catch(console.error);

// Export Express app as default for Vercel
export default app;

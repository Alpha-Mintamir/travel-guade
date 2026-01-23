import app from '../src/app';
import { connectDatabase } from '../src/config/database';

// Connect to database (connection is reused in serverless)
connectDatabase().catch(console.error);

export default app;

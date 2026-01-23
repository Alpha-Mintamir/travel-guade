// Simple test handler first
export default async function handler(req, res) {
    try {
        // Dynamically import to catch any initialization errors
        const { default: app } = await import('../src/app');
        const { connectDatabase } = await import('../src/config/database');
        // Connect to database
        await connectDatabase();
        // Pass to Express
        return app(req, res);
    }
    catch (error) {
        console.error('Handler error:', error);
        return res.status(500).json({
            error: 'Internal Server Error',
            message: error.message,
            stack: process.env.NODE_ENV === 'development' ? error.stack : undefined,
        });
    }
}
//# sourceMappingURL=index.js.map
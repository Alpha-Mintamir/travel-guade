# TravelBro Backend API

Backend API for TravelBro - Ethiopian Travel Partner mobile app. Built with Node.js, TypeScript, Express, Prisma, PostgreSQL, Better Auth, and Socket.io.

## Features

- 🔐 Better Auth authentication with session management
- 👤 User profiles with Cloudinary photo uploads
- 🗺️ Ethiopian destinations with 14 seeded locations
- ✈️ Trip creation and discovery with filtering
- 🤝 Trip join requests system
- 💬 Real-time chat with Socket.io
- 🔔 Real-time notifications
- 📧 Email verification and password reset with Resend
- 🛡️ Security with helmet, rate limiting, and CORS
- 📊 Type-safe database access with Prisma

## Tech Stack

- **Runtime**: Node.js 20+
- **Language**: TypeScript
- **Framework**: Express.js
- **Database**: PostgreSQL
- **ORM**: Prisma
- **Real-time**: Socket.io
- **Authentication**: Better Auth
- **Email**: Resend
- **File Storage**: Cloudinary
- **Validation**: Zod
- **Logging**: Pino

## Prerequisites

- Node.js 20+
- PostgreSQL 14+
- npm or yarn

## Installation

1. **Clone and navigate to backend directory**

```bash
cd backend
```

2. **Install dependencies**

```bash
npm install
```

3. **Set up environment variables**

```bash
cp .env.example .env
```

Edit `.env` and fill in your configuration:

```env
# Server
PORT=3000
NODE_ENV=development

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/travelbro

# Better Auth (generate secure secret!)
BETTER_AUTH_SECRET=your-secret-key-min-32-chars
BETTER_AUTH_URL=http://localhost:3000

# Resend (get from https://resend.com)
RESEND_API_KEY=re_xxxxx
EMAIL_FROM=noreply@travelbro.com

# Cloudinary (get from https://cloudinary.com)
CLOUDINARY_CLOUD_NAME=xxxxx
CLOUDINARY_API_KEY=xxxxx
CLOUDINARY_API_SECRET=xxxxx

# Frontend URL
FRONTEND_URL=http://localhost:3000

# CORS
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

4. **Set up database**

```bash
# Generate Prisma client
npm run prisma:generate

# Run migrations
npm run prisma:migrate

# Seed Ethiopian destinations
npm run prisma:seed
```

5. **Start development server**

```bash
npm run dev
```

The API will be available at `http://localhost:3000`

## API Endpoints

### Authentication (`/api/auth`)

- `POST /register` - Register new user
- `POST /login` - Login
- `POST /verify-email` - Verify email with token
- `POST /forgot-password` - Request password reset
- `POST /reset-password` - Reset password with token
- `POST /refresh-token` - Refresh access token

### Users (`/api/users`)

- `GET /me` - Get current user profile (protected)
- `PATCH /me` - Update profile (protected)
- `POST /me/photo` - Upload profile photo (protected)
- `GET /:id` - Get public user profile

### Destinations (`/api/destinations`)

- `GET /` - List all destinations (filter by region, type)
- `GET /:id` - Get destination details

### Trips (`/api/trips`)

- `GET /` - List trips with filters (destinationId, region, dates, pagination)
- `GET /:id` - Get trip details
- `POST /` - Create trip (protected)
- `PATCH /:id` - Update trip (protected, owner only)
- `DELETE /:id` - Delete trip (protected, owner only)
- `GET /my-trips` - Get current user's trips (protected)

### Requests (`/api/requests`)

- `POST /trips/:tripId/requests` - Send join request (protected)
- `GET /trips/:tripId/requests` - Get trip requests (protected, owner only)
- `PATCH /:id/respond` - Accept/reject request (protected)
- `GET /sent` - Get sent requests (protected)
- `GET /received` - Get received requests (protected)

### Notifications (`/api/notifications`)

- `GET /` - Get user notifications (protected)
- `PATCH /:id/read` - Mark as read (protected)
- `POST /read-all` - Mark all as read (protected)

### Health Check

- `GET /api/health` - API health check

## Socket.io Events

### Connection

Connect with JWT token in authorization header:

```javascript
const socket = io('http://localhost:3000', {
  auth: {
    token: 'your-jwt-token'
  }
});
```

### Chat Events

**Client to Server:**
- `join_conversation` - Join chat room for a trip request
- `leave_conversation` - Leave chat room
- `send_message` - Send message in conversation
- `typing_start` - Start typing indicator
- `typing_stop` - Stop typing indicator
- `mark_read` - Mark message as read

**Server to Client:**
- `message_received` - New message in conversation
- `user_typing` - User started typing
- `user_stopped_typing` - User stopped typing
- `message_read` - Message was read
- `notification` - Real-time notification
- `error` - Error occurred

## Database Schema

The database includes the following models:

- **User** - User accounts with authentication
- **Destination** - Ethiopian travel destinations
- **Trip** - User-created trips
- **TripRequest** - Join requests for trips
- **Message** - Chat messages between users
- **Notification** - User notifications
- **Report** - User reports
- **Block** - User blocks

See `prisma/schema.prisma` for full schema details.

## Development

```bash
# Run in development mode with hot reload
npm run dev

# Build for production
npm run build

# Start production server
npm start

# View database in Prisma Studio
npm run prisma:studio
```

## Production Deployment

1. Set `NODE_ENV=production`
2. Use strong JWT secrets (32+ characters)
3. Set up PostgreSQL database
4. Configure Resend for email
5. Configure Cloudinary for images
6. Set appropriate CORS origins
7. Use process manager (PM2, systemd)
8. Set up SSL/TLS
9. Configure firewall
10. Enable logging and monitoring

## Security Features

- Better Auth session management with database validation
- Secure password hashing via Better Auth
- Session expiration and automatic cleanup
- Rate limiting on all endpoints
- Helmet for security headers
- CORS protection
- CSRF protection (Better Auth built-in)
- Input validation with Zod
- SQL injection protection via Prisma
- File upload validation
- Environment variable validation

## License

MIT

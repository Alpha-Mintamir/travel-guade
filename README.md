# Travel Guade - Ethiopian Travel Partner

A mobile-first platform connecting travelers exploring Ethiopia. Find travel companions, share experiences, and discover hidden gems across the Land of Origins.

## Features

- **Find Travel Partners**: Connect with fellow travelers heading to the same destinations
- **Trip Planning**: Create and share trip plans with dates, budget, and travel style
- **Real-time Chat**: Message potential travel companions instantly
- **Ethiopian Destinations**: Explore UNESCO heritage sites, national parks, and cultural landmarks
- **Social Integration**: Connect via Instagram, Telegram, or phone

## Tech Stack

### Backend
- **Runtime**: Node.js 20+ with TypeScript
- **Framework**: Express.js
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: Better Auth
- **Real-time**: Socket.io
- **File Storage**: Cloudinary
- **Email**: Resend

### Mobile App
- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **HTTP Client**: Dio

## Project Structure

```
travel-guade/
├── backend/           # Node.js/Express API server
│   ├── src/
│   │   ├── controllers/
│   │   ├── routes/
│   │   ├── services/
│   │   ├── middleware/
│   │   └── socket/
│   └── prisma/        # Database schema & migrations
├── mobile/            # Flutter mobile app
│   └── lib/
│       ├── features/  # Feature-based modules
│       ├── shared/    # Shared components
│       └── routes/    # Navigation
└── README.md
```

## Getting Started

### Prerequisites
- Node.js 20+
- PostgreSQL 15+
- Flutter 3.x
- Docker (optional, for local PostgreSQL)

### Backend Setup

1. Navigate to backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your database URL and API keys
   ```

4. Run database migrations:
   ```bash
   npx prisma migrate dev
   ```

5. Start development server:
   ```bash
   npm run dev
   ```

### Mobile Setup

1. Navigate to mobile directory:
   ```bash
   cd mobile
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate code (Freezed, Riverpod):
   ```bash
   dart run build_runner build
   ```

4. Run the app:
   ```bash
   flutter run
   ```

### Build APK

```bash
cd mobile
flutter build apk --release
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register new user |
| POST | `/api/auth/login` | User login |
| GET | `/api/trips` | List all trips |
| POST | `/api/trips` | Create new trip |
| GET | `/api/trips/:id` | Get trip details |
| POST | `/api/trips/upload-photo` | Upload trip photo |
| GET | `/api/destinations` | List destinations |
| POST | `/api/requests` | Send trip request |

## Environment Variables

### Backend (.env)
```
DATABASE_URL=postgresql://user:password@localhost:5432/travelbro
JWT_SECRET=your-secret-key
BETTER_AUTH_SECRET=your-auth-secret
RESEND_API_KEY=your-resend-key
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret
```

## Deployment

### Backend (Vercel)
The backend is configured for Vercel deployment with `vercel.json`.

```bash
cd backend
vercel --prod
```

### Mobile
Build release APK or deploy to app stores:
```bash
flutter build apk --release
flutter build appbundle --release  # For Play Store
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Contact

Alpha Mintamir - [@Alpha-Mintamir](https://github.com/Alpha-Mintamir)

Project Link: [https://github.com/Alpha-Mintamir/travel-guade](https://github.com/Alpha-Mintamir/travel-guade)

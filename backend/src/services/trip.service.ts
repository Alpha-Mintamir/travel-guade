import { prisma } from '../config/database';
import { BudgetLevel, TravelStyle, TripStatus } from '@prisma/client';
import { NotFoundError, ForbiddenError } from '../utils/errors';

interface CreateTripData {
  destinationName: string;
  startDate: string;
  endDate: string;
  flexibleDates?: boolean;
  description?: string;
  peopleNeeded: number;
  budgetLevel: BudgetLevel;
  travelStyle: TravelStyle;
  // Contact info
  instagramUsername: string;
  phoneNumber?: string;
  telegramUsername?: string;
  photoUrl?: string;
}

interface GetTripsFilters {
  destinationId?: string;
  region?: string;
  startDate?: string;
  endDate?: string;
  page?: string;
  limit?: string;
}

export class TripService {
  static async createTrip(userId: string, data: CreateTripData) {
    const trip = await prisma.trip.create({
      data: {
        destinationName: data.destinationName,
        startDate: new Date(data.startDate),
        endDate: new Date(data.endDate),
        flexibleDates: data.flexibleDates,
        description: data.description,
        peopleNeeded: data.peopleNeeded,
        budgetLevel: data.budgetLevel,
        travelStyle: data.travelStyle,
        instagramUsername: data.instagramUsername,
        phoneNumber: data.phoneNumber,
        telegramUsername: data.telegramUsername,
        photoUrl: data.photoUrl,
        userId,
      },
      include: {
        creator: {
          select: {
            id: true,
            email: true,
            fullName: true,
            profilePhotoUrl: true,
            cityOfResidence: true,
            bio: true,
            travelPreferences: true,
            emailVerified: true,
            createdAt: true,
          },
        },
      },
    });

    return trip;
  }

  static async getTrips(filters: GetTripsFilters) {
    const page = parseInt(filters.page || '1');
    const limit = parseInt(filters.limit || '20');
    const skip = (page - 1) * limit;

    const where: any = {
      status: TripStatus.ACTIVE,
    };

    if (filters.destinationId) {
      where.destinationId = parseInt(filters.destinationId);
    }

    if (filters.region) {
      where.destination = {
        region: filters.region,
      };
    }

    if (filters.startDate || filters.endDate) {
      where.startDate = {};
      if (filters.startDate) {
        where.startDate.gte = new Date(filters.startDate);
      }
      if (filters.endDate) {
        where.startDate.lte = new Date(filters.endDate);
      }
    }

    const [trips, total] = await Promise.all([
      prisma.trip.findMany({
        where,
        include: {
          creator: {
            select: {
              id: true,
              email: true,
              fullName: true,
              profilePhotoUrl: true,
              cityOfResidence: true,
              bio: true,
              travelPreferences: true,
              emailVerified: true,
              createdAt: true,
            },
          },
        },
        orderBy: {
          createdAt: 'desc',
        },
        skip,
        take: limit,
      }),
      prisma.trip.count({ where }),
    ]);

    return { trips, total, page, limit };
  }

  static async getTripById(id: string) {
    const trip = await prisma.trip.findUnique({
      where: { id },
      include: {
        creator: {
          select: {
            id: true,
            email: true,
            fullName: true,
            profilePhotoUrl: true,
            cityOfResidence: true,
            bio: true,
            travelPreferences: true,
            emailVerified: true,
            createdAt: true,
          },
        },
      },
    });

    if (!trip) {
      throw new NotFoundError('Trip not found');
    }

    return trip;
  }

  static async updateTrip(
    tripId: string,
    userId: string,
    data: Partial<CreateTripData>
  ) {
    const trip = await prisma.trip.findUnique({
      where: { id: tripId },
    });

    if (!trip) {
      throw new NotFoundError('Trip not found');
    }

    if (trip.userId !== userId) {
      throw new ForbiddenError('You can only update your own trips');
    }

    const updatedTrip = await prisma.trip.update({
      where: { id: tripId },
      data: {
        ...(data.destinationName && { destinationName: data.destinationName }),
        ...(data.startDate && { startDate: new Date(data.startDate) }),
        ...(data.endDate && { endDate: new Date(data.endDate) }),
        ...(data.flexibleDates !== undefined && { flexibleDates: data.flexibleDates }),
        ...(data.description && { description: data.description }),
        ...(data.peopleNeeded && { peopleNeeded: data.peopleNeeded }),
        ...(data.budgetLevel && { budgetLevel: data.budgetLevel }),
        ...(data.travelStyle && { travelStyle: data.travelStyle }),
        ...(data.instagramUsername && { instagramUsername: data.instagramUsername }),
        ...(data.phoneNumber && { phoneNumber: data.phoneNumber }),
        ...(data.telegramUsername && { telegramUsername: data.telegramUsername }),
        ...(data.photoUrl && { photoUrl: data.photoUrl }),
      },
      include: {
        creator: {
          select: {
            id: true,
            email: true,
            fullName: true,
            profilePhotoUrl: true,
            cityOfResidence: true,
            bio: true,
            travelPreferences: true,
            emailVerified: true,
            createdAt: true,
          },
        },
      },
    });

    return updatedTrip;
  }

  static async deleteTrip(tripId: string, userId: string) {
    const trip = await prisma.trip.findUnique({
      where: { id: tripId },
    });

    if (!trip) {
      throw new NotFoundError('Trip not found');
    }

    if (trip.userId !== userId) {
      throw new ForbiddenError('You can only delete your own trips');
    }

    await prisma.trip.delete({
      where: { id: tripId },
    });

    return { message: 'Trip deleted successfully' };
  }

  static async getMyTrips(userId: string) {
    const trips = await prisma.trip.findMany({
      where: { userId },
      include: {
        creator: {
          select: {
            id: true,
            email: true,
            fullName: true,
            profilePhotoUrl: true,
            cityOfResidence: true,
            bio: true,
            travelPreferences: true,
            emailVerified: true,
            createdAt: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return trips;
  }
}

import { prisma } from '../config/database';
import { BudgetLevel, RequestStatus, TravelStyle, TripStatus } from '@prisma/client';
import { NotFoundError, ForbiddenError, BadRequestError, ConflictError } from '../utils/errors';
import { NotificationService } from './notification.service';

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
  // Photos
  photoUrl?: string;       // Destination photo
  userPhotoUrl?: string;   // Creator's photo for the trip
}

interface GetTripsFilters {
  destinationId?: string;
  region?: string;
  startDate?: string;
  endDate?: string;
  search?: string;
  page?: string;
  limit?: string;
}

export class TripService {
  // Helper to validate date range
  private static validateDateRange(startDate: string, endDate: string): void {
    const start = new Date(startDate);
    const end = new Date(endDate);

    if (isNaN(start.getTime()) || isNaN(end.getTime())) {
      throw new BadRequestError('Invalid date format');
    }

    if (start >= end) {
      throw new BadRequestError('Start date must be before end date');
    }

    // Optional: Ensure start date is not in the past
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    if (start < today) {
      throw new BadRequestError('Start date cannot be in the past');
    }
  }

  static async createTrip(userId: string, data: CreateTripData) {
    // Validate date range
    this.validateDateRange(data.startDate, data.endDate);

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
        userPhotoUrl: data.userPhotoUrl,
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

    // Text search across multiple fields
    if (filters.search) {
      const searchTerm = filters.search.trim();
      where.OR = [
        { destinationName: { contains: searchTerm, mode: 'insensitive' } },
        { description: { contains: searchTerm, mode: 'insensitive' } },
        { travelStyle: { equals: searchTerm.toUpperCase() as TravelStyle } },
        { budgetLevel: { equals: searchTerm.toUpperCase() as BudgetLevel } },
        { creator: { fullName: { contains: searchTerm, mode: 'insensitive' } } },
        { creator: { cityOfResidence: { contains: searchTerm, mode: 'insensitive' } } },
      ];
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

  static async getTripById(id: string, options?: { includeInactive?: boolean }) {
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
        _count: {
          select: {
            requests: {
              where: { status: RequestStatus.ACCEPTED },
            },
          },
        },
      },
    });

    if (!trip) {
      throw new NotFoundError('Trip not found');
    }

    // By default, only return active trips unless explicitly requested
    if (!options?.includeInactive && trip.status !== TripStatus.ACTIVE) {
      throw new NotFoundError('Trip not found or no longer available');
    }

    // Calculate spots remaining
    const acceptedCount = trip._count.requests;
    const spotsRemaining = Math.max(0, trip.peopleNeeded - acceptedCount);

    return {
      ...trip,
      acceptedCount,
      spotsRemaining,
      isFull: spotsRemaining === 0,
    };
  }

  static async updateTrip(
    tripId: string,
    userId: string,
    data: Partial<CreateTripData>
  ) {
    const trip = await prisma.trip.findUnique({
      where: { id: tripId },
      include: {
        requests: {
          where: { status: RequestStatus.ACCEPTED },
          select: { requesterId: true },
        },
      },
    });

    if (!trip) {
      throw new NotFoundError('Trip not found');
    }

    if (trip.userId !== userId) {
      throw new ForbiddenError('You can only update your own trips');
    }

    // Validate date range if dates are being updated
    const newStartDate = data.startDate ? new Date(data.startDate) : trip.startDate;
    const newEndDate = data.endDate ? new Date(data.endDate) : trip.endDate;

    if (data.startDate || data.endDate) {
      if (newStartDate >= newEndDate) {
        throw new BadRequestError('Start date must be before end date');
      }
    }

    // Check if reducing peopleNeeded below current accepted count
    if (data.peopleNeeded !== undefined) {
      const acceptedCount = trip.requests.length;
      if (data.peopleNeeded < acceptedCount) {
        throw new ConflictError(
          `Cannot reduce spots to ${data.peopleNeeded}. You already have ${acceptedCount} accepted participant(s).`
        );
      }
    }

    // Determine if critical fields are changing (to notify participants)
    const criticalChanges: string[] = [];
    if (data.destinationName && data.destinationName !== trip.destinationName) {
      criticalChanges.push('destination');
    }
    if (data.startDate && new Date(data.startDate).getTime() !== trip.startDate.getTime()) {
      criticalChanges.push('start date');
    }
    if (data.endDate && new Date(data.endDate).getTime() !== trip.endDate.getTime()) {
      criticalChanges.push('end date');
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
        ...(data.userPhotoUrl && { userPhotoUrl: data.userPhotoUrl }),
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

    // Notify accepted participants about critical changes
    if (criticalChanges.length > 0 && trip.requests.length > 0) {
      const changeDescription = criticalChanges.join(', ');
      await Promise.all(
        trip.requests.map((request) =>
          NotificationService.createNotification({
            userId: request.requesterId,
            type: 'TRIP_UPDATE',
            title: 'Trip Updated',
            body: `The trip to ${updatedTrip.destinationName} has been updated (${changeDescription})`,
            data: {
              tripId: updatedTrip.id,
              changes: criticalChanges,
            },
          })
        )
      );
    }

    return updatedTrip;
  }

  static async deleteTrip(tripId: string, userId: string, options?: { force?: boolean }) {
    const trip = await prisma.trip.findUnique({
      where: { id: tripId },
      include: {
        requests: {
          where: { status: RequestStatus.ACCEPTED },
          select: { requesterId: true },
        },
      },
    });

    if (!trip) {
      throw new NotFoundError('Trip not found');
    }

    if (trip.userId !== userId) {
      throw new ForbiddenError('You can only delete your own trips');
    }

    // Check if there are accepted participants
    const acceptedParticipants = trip.requests;
    if (acceptedParticipants.length > 0 && !options?.force) {
      throw new ConflictError(
        `Cannot delete trip with ${acceptedParticipants.length} accepted participant(s). ` +
        'Please cancel the trip instead, or use force delete to notify and remove all participants.'
      );
    }

    // Notify accepted participants before deletion if force delete
    if (acceptedParticipants.length > 0) {
      await Promise.all(
        acceptedParticipants.map((request) =>
          NotificationService.createNotification({
            userId: request.requesterId,
            type: 'TRIP_UPDATE',
            title: 'Trip Cancelled',
            body: `The trip to ${trip.destinationName} has been cancelled by the organizer.`,
            data: {
              tripId: trip.id,
              action: 'deleted',
            },
          })
        )
      );
    }

    await prisma.trip.delete({
      where: { id: tripId },
    });

    return { 
      message: 'Trip deleted successfully',
      notifiedParticipants: acceptedParticipants.length,
    };
  }

  // Alternative: Cancel trip instead of deleting (softer approach)
  static async cancelTrip(tripId: string, userId: string) {
    const trip = await prisma.trip.findUnique({
      where: { id: tripId },
      include: {
        requests: {
          where: { status: RequestStatus.ACCEPTED },
          select: { requesterId: true },
        },
      },
    });

    if (!trip) {
      throw new NotFoundError('Trip not found');
    }

    if (trip.userId !== userId) {
      throw new ForbiddenError('You can only cancel your own trips');
    }

    if (trip.status === TripStatus.CANCELLED) {
      throw new BadRequestError('Trip is already cancelled');
    }

    const updatedTrip = await prisma.trip.update({
      where: { id: tripId },
      data: { status: TripStatus.CANCELLED },
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

    // Notify all accepted participants
    if (trip.requests.length > 0) {
      await Promise.all(
        trip.requests.map((request) =>
          NotificationService.createNotification({
            userId: request.requesterId,
            type: 'TRIP_UPDATE',
            title: 'Trip Cancelled',
            body: `The trip to ${trip.destinationName} has been cancelled by the organizer.`,
            data: {
              tripId: trip.id,
              action: 'cancelled',
            },
          })
        )
      );
    }

    return updatedTrip;
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

import { z } from 'zod';
import { BudgetLevel, TravelStyle } from '@prisma/client';

// Helper for flexible date string validation
const dateString = z.string().refine(
  (val) => !isNaN(Date.parse(val)),
  { message: 'Invalid date format' }
);

export const createTripSchema = z.object({
  body: z.object({
    destinationName: z.string().min(1, 'Destination is required'),
    startDate: dateString,
    endDate: dateString,
    flexibleDates: z.boolean().optional(),
    description: z.string().optional().nullable(),
    peopleNeeded: z.number().int().positive().default(1),
    budgetLevel: z.nativeEnum(BudgetLevel),
    travelStyle: z.nativeEnum(TravelStyle),
    // Contact info
    instagramUsername: z.string().min(1, 'Instagram username is required'),
    phoneNumber: z.string().optional().nullable(),
    telegramUsername: z.string().optional().nullable(),
    photoUrl: z.string().optional().nullable(),
  }),
});

export const updateTripSchema = z.object({
  body: z.object({
    destinationId: z.number().int().positive().optional(),
    startDate: z.string().datetime().optional(),
    endDate: z.string().datetime().optional(),
    flexibleDates: z.boolean().optional(),
    description: z.string().optional(),
    peopleNeeded: z.number().int().positive().optional(),
    budgetLevel: z.nativeEnum(BudgetLevel).optional(),
    travelStyle: z.nativeEnum(TravelStyle).optional(),
  }),
});

export const getTripsSchema = z.object({
  query: z.object({
    destinationId: z.string().optional(),
    region: z.string().optional(),
    startDate: z.string().datetime().optional(),
    endDate: z.string().datetime().optional(),
    page: z.string().optional(),
    limit: z.string().optional(),
  }),
});

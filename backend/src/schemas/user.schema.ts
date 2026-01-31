import { z } from 'zod';

export const updateProfileSchema = z.object({
  body: z.object({
    fullName: z.string().min(1).optional(),
    cityOfResidence: z.string().optional(),
    bio: z.string().max(500).optional(),
    travelPreferences: z.string().optional(),
    interests: z.string().max(1000).optional(),
    gender: z.enum(['MALE', 'FEMALE']).optional(),
    dateOfBirth: z.string().optional().transform((val) => val ? new Date(val) : undefined),
    profilePhotoUrl: z.string().url().optional(), // DiceBear avatar URL
  }),
});

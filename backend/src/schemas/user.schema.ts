import { z } from 'zod';

export const updateProfileSchema = z.object({
  body: z.object({
    fullName: z.string().min(1).optional(),
    cityOfResidence: z.string().optional(),
    bio: z.string().max(500).optional(),
    travelPreferences: z.string().optional(),
  }),
});

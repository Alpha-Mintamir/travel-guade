import { z } from 'zod';
import { RequestStatus } from '@prisma/client';

export const createRequestSchema = z.object({
  body: z.object({
    message: z.string().optional(),
  }),
});

export const respondToRequestSchema = z.object({
  body: z.object({
    status: z.enum([RequestStatus.ACCEPTED, RequestStatus.REJECTED]),
  }),
});

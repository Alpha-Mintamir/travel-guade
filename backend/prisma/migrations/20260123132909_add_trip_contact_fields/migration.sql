/*
  Warnings:

  - Added the required column `instagram_username` to the `trips` table without a default value. This is not possible if the table is not empty.

*/
-- AlterEnum
ALTER TYPE "BudgetLevel" ADD VALUE 'MEDIUM';

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "TravelStyle" ADD VALUE 'FOOD';
ALTER TYPE "TravelStyle" ADD VALUE 'NATURE';

-- AlterTable
ALTER TABLE "trips" ADD COLUMN     "instagram_username" TEXT NOT NULL,
ADD COLUMN     "phone_number" TEXT,
ADD COLUMN     "photo_url" TEXT,
ADD COLUMN     "telegram_username" TEXT;

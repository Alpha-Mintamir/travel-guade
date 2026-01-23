/*
  Warnings:

  - Added the required column `destination_name` to the `trips` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "trips" DROP CONSTRAINT "trips_destination_id_fkey";

-- AlterTable
ALTER TABLE "trips" ADD COLUMN     "destination_name" TEXT NOT NULL,
ALTER COLUMN "destination_id" DROP NOT NULL;

-- AddForeignKey
ALTER TABLE "trips" ADD CONSTRAINT "trips_destination_id_fkey" FOREIGN KEY ("destination_id") REFERENCES "destinations"("id") ON DELETE SET NULL ON UPDATE CASCADE;

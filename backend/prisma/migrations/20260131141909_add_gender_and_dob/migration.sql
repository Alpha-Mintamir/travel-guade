-- CreateEnum
CREATE TYPE "Gender" AS ENUM ('MALE', 'FEMALE');

-- AlterTable
ALTER TABLE "user" ADD COLUMN     "date_of_birth" TIMESTAMP(3),
ADD COLUMN     "gender" "Gender";

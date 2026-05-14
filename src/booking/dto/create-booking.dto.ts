import { Type } from "class-transformer";
import { IsDateString, IsNotEmpty, IsNumber, IsOptional, IsString, MinLength } from "class-validator";

export class CreateBookingDto {
    @Type(() => Number)
    @IsNumber()
    katalogId! : number;

    @IsString()
    @MinLength(3, {message : "Nama penyewa minimal 3 karakter"})
    customerName! : string;

    @IsOptional()
    @IsString()
    customerPhone? : string;

    @IsNotEmpty()
    @IsDateString()
    startDate! : string;

    @IsNotEmpty()
    @IsDateString()
    endDate! : string;
}

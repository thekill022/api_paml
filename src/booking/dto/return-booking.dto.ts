import { IsDateString, IsNotEmpty } from "class-validator";

export class ReturnBookingDto {
    @IsNotEmpty()
    @IsDateString()
    actualReturnDate! : string;
}

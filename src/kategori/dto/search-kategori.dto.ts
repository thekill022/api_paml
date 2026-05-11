import { IsNotEmpty, IsString } from "class-validator";

export class SearchKategoriDto {
    @IsNotEmpty()
    @IsString()
    nama! : string;
}

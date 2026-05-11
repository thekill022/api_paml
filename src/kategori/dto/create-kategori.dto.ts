import { IsNotEmpty, IsString, MinLength } from "class-validator";

export class CreateKategoriDto {
    @IsNotEmpty()
    @MinLength(3, {message : "Minimal panjang nama kategori adalah 3 karakter"})
    @IsString()
    kategori! : string;
}

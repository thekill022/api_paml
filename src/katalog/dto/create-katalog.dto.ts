import { IsNotEmpty, IsNumber, IsString, MinLength } from "class-validator";

export class CreateKatalogDto {
    @IsString()
    @MinLength(3, {message : "Minimal nama adalah 3 karakter"})
    nama! : string;
    @IsNumber()
    harga! : number;
    status? : boolean;
    @IsNotEmpty()
    kategoriId! : number;
}

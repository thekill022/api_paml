import { Transform, Type } from "class-transformer";
import { IsBoolean, IsNotEmpty, IsNumber, IsOptional, IsString, MinLength } from "class-validator";

export class CreateKatalogDto {
    @IsString()
    @MinLength(3, {message : "Minimal nama adalah 3 karakter"})
    nama! : string;

    @Type(() => Number)
    @IsNumber()
    harga! : number;

    @IsOptional()
    @Transform(({ value }) => value === true || value === 'true')
    @IsBoolean()
    status? : boolean;

    @Type(() => Number)
    @IsNumber()
    @IsNotEmpty()
    kategoriId! : number;
}

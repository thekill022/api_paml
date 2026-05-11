import { IsEmail, IsString, MinLength } from "class-validator";

export class Auth {
    @IsEmail({}, {message : "Format email salah"})
    email! : string;

    @IsString()
    @MinLength(8, {message : "Minimal panjang password adalah 8 karakter"})
    password! : string;
}
import { IsEmail, IsString, MinLength } from "class-validator";
import { BeforeInsert } from "typeorm";
import * as Bcrypt from 'bcrypt'

export class CreateUserDto {
    @IsEmail({}, {message : "Format email salah"})
    email! : string;
    
    @MinLength(3, {message : "Nama pertama minimal 3 karakter"})
    @IsString()
    firstName! : string;

    @IsString()
    lastName! : string;

    @IsString()
    @MinLength(8, {message : "Minimal panjang password adalah 8 karakter"})
    password! : string;

    @IsString()
    role! : string;

    @BeforeInsert()
    async hashPassword() {
        const salt = await Bcrypt.genSalt()
        this.password = await Bcrypt.hash(this.password, salt);
    }

}

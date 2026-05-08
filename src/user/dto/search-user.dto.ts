import { IsString } from "class-validator";

export class SearchUserByNameDto {
    @IsString()
    name! : string;
}
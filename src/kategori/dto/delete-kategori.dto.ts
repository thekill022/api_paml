import { IsNotEmpty, IsNumber} from "class-validator";

export class CreateKategoriDto {
    @IsNotEmpty()
    @IsNumber()
    id! : Number;
}

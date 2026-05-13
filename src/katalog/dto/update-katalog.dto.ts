import { PartialType } from '@nestjs/mapped-types';
import { CreateKatalogDto } from './create-katalog.dto';
import { IsOptional } from 'class-validator';

export class UpdateKatalogDto extends PartialType(CreateKatalogDto) {
    @IsOptional()
    kategoriId?: number;
}

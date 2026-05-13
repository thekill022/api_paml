import { Module } from '@nestjs/common';
import { KatalogService } from './katalog.service';
import { KatalogController } from './katalog.controller';
import { Katalog } from './entities/katalog.entity';
import { TypeOrmModule } from '@nestjs/typeorm';

@Module({
  imports : [
    TypeOrmModule.forFeature([Katalog])
  ],
  controllers: [KatalogController],
  providers: [KatalogService],
})
export class KatalogModule {}

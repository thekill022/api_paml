import { Module } from '@nestjs/common';
import { KatalogService } from './katalog.service';
import { KatalogController } from './katalog.controller';
import { Katalog } from './entities/katalog.entity';
import { TypeOrmModule } from '@nestjs/typeorm';
import { KategoriGuard } from 'src/kategori/role-kategori.guard';

@Module({
  imports : [
    TypeOrmModule.forFeature([Katalog])
  ],
  controllers: [KatalogController],
  providers: [KatalogService, KategoriGuard],
})
export class KatalogModule {}

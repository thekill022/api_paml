import { Module } from '@nestjs/common';
import { KategoriService } from './kategori.service';
import { KategoriController } from './kategori.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Kategori } from './entities/kategori.entity';

@Module({
  imports : [TypeOrmModule.forFeature([Kategori])],
  controllers: [KategoriController],
  providers: [KategoriService],
})
export class KategoriModule {}

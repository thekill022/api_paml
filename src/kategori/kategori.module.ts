import { Module } from '@nestjs/common';
import { KategoriService } from './kategori.service';
import { KategoriController } from './kategori.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Kategori } from './entities/kategori.entity';
import { APP_GUARD } from '@nestjs/core';
import { KategoriGuard } from './role-kategori.guard';

@Module({
  imports : [TypeOrmModule.forFeature([Kategori])],
  controllers: [KategoriController],
  providers: [KategoriService, {
    provide : APP_GUARD,
    useClass : KategoriGuard
  }],
})
export class KategoriModule {}

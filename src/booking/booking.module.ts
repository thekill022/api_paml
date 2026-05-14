import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BookingController } from './booking.controller';
import { BookingService } from './booking.service';
import { Booking } from './entities/booking.entity';
import { Katalog } from 'src/katalog/entities/katalog.entity';
import { KategoriGuard } from 'src/kategori/role-kategori.guard';

@Module({
  imports: [TypeOrmModule.forFeature([Booking, Katalog])],
  controllers: [BookingController],
  providers: [BookingService, KategoriGuard],
})
export class BookingModule {}

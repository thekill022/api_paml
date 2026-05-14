import { Body, Controller, Delete, Get, Param, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { RoleAdmin } from 'src/kategori/decorator/role-kategori.decorator';
import { KategoriGuard } from 'src/kategori/role-kategori.guard';
import { BookingService } from './booking.service';
import { CreateBookingDto } from './dto/create-booking.dto';
import { ReturnBookingDto } from './dto/return-booking.dto';
import { UpdateBookingDto } from './dto/update-booking.dto';

@Controller('booking')
export class BookingController {
  constructor(private readonly bookingService: BookingService) {}

  @Get()
  @RoleAdmin()
  @UseGuards(KategoriGuard)
  findAll() {
    return this.bookingService.findAll();
  }

  @Get('availability')
  checkAvailability(
    @Query('katalogId') katalogId: string,
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
    @Query('excludeId') excludeId?: string,
  ) {
    return this.bookingService.checkAvailability(
      +katalogId,
      startDate,
      endDate,
      excludeId ? +excludeId : undefined,
    );
  }

  @Post()
  @RoleAdmin()
  @UseGuards(KategoriGuard)
  create(@Body() createBookingDto: CreateBookingDto) {
    return this.bookingService.create(createBookingDto);
  }

  @Patch(':id')
  @RoleAdmin()
  @UseGuards(KategoriGuard)
  update(@Param('id') id: string, @Body() updateBookingDto: UpdateBookingDto) {
    return this.bookingService.update(+id, updateBookingDto);
  }

  @Patch(':id/return')
  @RoleAdmin()
  @UseGuards(KategoriGuard)
  returnEarly(@Param('id') id: string, @Body() returnBookingDto: ReturnBookingDto) {
    return this.bookingService.returnEarly(+id, returnBookingDto);
  }

  @Delete(':id')
  @RoleAdmin()
  @UseGuards(KategoriGuard)
  remove(@Param('id') id: string) {
    return this.bookingService.remove(+id);
  }
}

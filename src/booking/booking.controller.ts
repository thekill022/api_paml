import { Body, Controller, Delete, Get, Param, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { RoleAdmin } from 'src/kategori/decorator/role-kategori.decorator';
import { KategoriGuard } from 'src/kategori/role-kategori.guard';
import { BookingService } from './booking.service';
import { CreateBookingDto } from './dto/create-booking.dto';
import { ReturnBookingDto } from './dto/return-booking.dto';
import { UpdateBookingDto } from './dto/update-booking.dto';

@Controller('booking')
@RoleAdmin()
@UseGuards(KategoriGuard)
export class BookingController {
  constructor(private readonly bookingService: BookingService) {}

  @Get()
  findAll() {
    return this.bookingService.findAll();
  }

  @Get('availability')
  checkAvailability(
    @Query('katalogId') katalogId: string,
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
  ) {
    return this.bookingService.checkAvailability(+katalogId, startDate, endDate);
  }

  @Post()
  create(@Body() createBookingDto: CreateBookingDto) {
    return this.bookingService.create(createBookingDto);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateBookingDto: UpdateBookingDto) {
    return this.bookingService.update(+id, updateBookingDto);
  }

  @Patch(':id/return')
  returnEarly(@Param('id') id: string, @Body() returnBookingDto: ReturnBookingDto) {
    return this.bookingService.returnEarly(+id, returnBookingDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.bookingService.remove(+id);
  }
}

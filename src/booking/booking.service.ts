import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { LessThanOrEqual, MoreThanOrEqual, Repository } from 'typeorm';
import { Katalog } from 'src/katalog/entities/katalog.entity';
import { CreateBookingDto } from './dto/create-booking.dto';
import { ReturnBookingDto } from './dto/return-booking.dto';
import { Booking, BookingStatus } from './entities/booking.entity';

@Injectable()
export class BookingService {
  constructor(
    @InjectRepository(Booking)
    private readonly bookingRepository: Repository<Booking>,
    @InjectRepository(Katalog)
    private readonly katalogRepository: Repository<Katalog>,
  ) {}

  findAll() {
    return this.bookingRepository.find({
      relations: { katalog: true },
      order: { startDate: 'DESC' },
    });
  }

  async checkAvailability(katalogId: number, startDate: string, endDate: string) {
    this.validateDateRange(startDate, endDate);
    const conflicts = await this.findConflicts(katalogId, startDate, endDate);

    return {
      available: conflicts.length === 0,
      bookedRanges: conflicts.map((booking) => ({
        id: booking.id,
        startDate: booking.startDate,
        endDate: booking.endDate,
        customerName: booking.customerName,
      })),
    };
  }

  async create(createBookingDto: CreateBookingDto) {
    this.validateDateRange(createBookingDto.startDate, createBookingDto.endDate);

    const katalog = await this.katalogRepository.findOne({
      where: { id: Number(createBookingDto.katalogId) },
    });

    if (!katalog) {
      throw new NotFoundException('Katalog tidak ditemukan');
    }

    if (!katalog.status) {
      throw new BadRequestException('Mobil sedang tidak tersedia');
    }

    const conflicts = await this.findConflicts(
      Number(createBookingDto.katalogId),
      createBookingDto.startDate,
      createBookingDto.endDate,
    );

    if (conflicts.length > 0) {
      throw new BadRequestException('Tanggal booking bertumpuk dengan booking aktif');
    }

    const booking = this.bookingRepository.create({
      customerName: createBookingDto.customerName,
      customerPhone: createBookingDto.customerPhone,
      startDate: createBookingDto.startDate,
      endDate: createBookingDto.endDate,
      status: BookingStatus.ACTIVE,
      katalog: { id: Number(createBookingDto.katalogId) } as Katalog,
    });

    return this.bookingRepository.save(booking);
  }

  async returnEarly(id: number, returnBookingDto: ReturnBookingDto) {
    const booking = await this.bookingRepository.findOne({
      where: { id },
      relations: { katalog: true },
    });

    if (!booking) {
      throw new NotFoundException('Booking tidak ditemukan');
    }

    if (booking.status !== BookingStatus.ACTIVE) {
      throw new BadRequestException('Booking sudah tidak aktif');
    }

    if (returnBookingDto.actualReturnDate < booking.startDate) {
      throw new BadRequestException('Tanggal kembali tidak boleh sebelum tanggal mulai');
    }

    booking.actualReturnDate = returnBookingDto.actualReturnDate;
    booking.status = BookingStatus.RETURNED;

    return this.bookingRepository.save(booking);
  }

  async cancel(id: number) {
    const booking = await this.bookingRepository.findOne({ where: { id } });

    if (!booking) {
      throw new NotFoundException('Booking tidak ditemukan');
    }

    booking.status = BookingStatus.CANCELLED;
    return this.bookingRepository.save(booking);
  }

  private async findConflicts(katalogId: number, startDate: string, endDate: string) {
    return this.bookingRepository.find({
      where: {
        katalog: { id: katalogId },
        status: BookingStatus.ACTIVE,
        startDate: LessThanOrEqual(endDate),
        endDate: MoreThanOrEqual(startDate),
      },
      relations: { katalog: true },
      order: { startDate: 'ASC' },
    });
  }

  private validateDateRange(startDate: string, endDate: string) {
    if (endDate < startDate) {
      throw new BadRequestException('Tanggal selesai tidak boleh sebelum tanggal mulai');
    }
  }
}

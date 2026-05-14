import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards } from '@nestjs/common';
import { KategoriService } from './kategori.service';
import { CreateKategoriDto } from './dto/create-kategori.dto';
import { UpdateKategoriDto } from './dto/update-kategori.dto';
import { RoleAdmin } from './decorator/role-kategori.decorator';
import { KategoriGuard } from './role-kategori.guard';

@Controller('kategori')
export class KategoriController {
  constructor(private readonly kategoriService: KategoriService) {}

  @Post()
  @RoleAdmin()
  @UseGuards(KategoriGuard)
  create(@Body() createKategoriDto: CreateKategoriDto) {
    return this.kategoriService.create(createKategoriDto);
  }

  @Get()
  findAll() {
    return this.kategoriService.findAll();
  }

  @Get('/search/:nama')
  findByName(@Param('nama') nama : string) {
    return this.kategoriService.findByName(nama);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.kategoriService.findOne(+id);
  }

  @Patch(':id')
  @RoleAdmin()
  @UseGuards(KategoriGuard)
  update(@Param('id') id: string, @Body() updateKategoriDto: UpdateKategoriDto) {
    return this.kategoriService.update(+id, updateKategoriDto);
  }

  @Delete(':id')
  @RoleAdmin()
  @UseGuards(KategoriGuard)
  remove(@Param('id') id: string) {
    return this.kategoriService.remove(+id);
  }
}

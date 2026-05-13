import { Controller, Get, Post, Body, Patch, Param, Delete, UseInterceptors, UploadedFile, BadRequestException } from '@nestjs/common';
import { KatalogService } from './katalog.service';
import { CreateKatalogDto } from './dto/create-katalog.dto';
import { UpdateKatalogDto } from './dto/update-katalog.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import { extname } from 'path';
import { diskStorage } from 'multer';

@Controller('katalog')
export class KatalogController {
  constructor(private readonly katalogService: KatalogService) {}

  @Post()
  @UseInterceptors(FileInterceptor('file', {
    storage : diskStorage({
      destination : './public',
      filename : (req, file, cb) => {
        const namaFile = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, `${namaFile}${extname(file.originalname)}`);
      }
    })
  }
  ))
  create(@Body() createKatalogDto: CreateKatalogDto, @UploadedFile() file : Express.Multer.File) {
    if (!file) {
      throw new BadRequestException("File gambar wajib disertakan");
    }
    return this.katalogService.create(createKatalogDto, file.filename);
  }

  @Get()
  findAll() {
    return this.katalogService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.katalogService.findOne(+id);
  }

  @Patch(':id')
  @UseInterceptors(FileInterceptor('file', {
    storage : diskStorage({
      destination : './public',
      filename : (req, file, cb) => {
        const namaFile = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, `${namaFile}${extname(file.originalname)}`);
      }
    })
  }
  ))
  update(@Param('id') id: string, @Body() updateKatalogDto: UpdateKatalogDto, @UploadedFile() file? : Express.Multer.File) {
    const filename = file ? file.filename : undefined;
    return this.katalogService.update(+id, updateKatalogDto, filename);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.katalogService.remove(+id);
  }
}

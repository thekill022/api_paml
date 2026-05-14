import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateKategoriDto } from './dto/create-kategori.dto';
import { UpdateKategoriDto } from './dto/update-kategori.dto';
import { Like, Repository } from 'typeorm';
import { Kategori } from './entities/kategori.entity';
import { InjectRepository } from '@nestjs/typeorm';

@Injectable()
export class KategoriService {
  constructor(
    @InjectRepository(Kategori)
    private readonly kategoriRepository : Repository<Kategori>
  ) {}

  create(createKategoriDto: CreateKategoriDto) {
    const kategori = this.kategoriRepository.create(createKategoriDto);
    return this.kategoriRepository.save(kategori);
  }

  findAll() {
    const kategori =  this.kategoriRepository.find();
    
    if (!kategori) {
      throw new NotFoundException("Data tidak ditemukan");
    }
    return kategori;
  }

  findOne(id: number) {
    const kategori =  this.kategoriRepository.findOne({where : {id}})

    if(!kategori) {
      throw new NotFoundException("Data tidak ditemukan");
    }
    return kategori;
  }

  findByName(nama : string) {
    const kategori = this.kategoriRepository.findOne({where : {kategori : Like(nama)}});

    if (!kategori) {
      throw new NotFoundException("Data tidak ditemukan");
    }

    return kategori;
  }

  async update(id: number, updateKategoriDto: UpdateKategoriDto) {
      await this.kategoriRepository.update(id, updateKategoriDto);

      const kategori = this.kategoriRepository.findOne({where : {id}});
      if(!kategori) {
        throw new NotFoundException("Data tidak ditemukan");
      }
      return kategori;
  }

  remove(id: number) {
    this.kategoriRepository.delete(id);
    return {
      message : "Berhasil menghapus kategori dengan id " + id
    }
  }
}

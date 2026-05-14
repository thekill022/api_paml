import { CreateKatalogDto } from './dto/create-katalog.dto';
import { UpdateKatalogDto } from './dto/update-katalog.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Katalog } from './entities/katalog.entity';
import { Like, Repository } from 'typeorm';
import { Injectable, NotFoundException } from '@nestjs/common';
import { join } from 'path';
import { existsSync, unlinkSync } from 'fs';

@Injectable()
export class KatalogService {
  constructor(
    @InjectRepository(Katalog)
    private readonly katalogRepository : Repository<Katalog>
  ) {}

  create(createKatalogDto: CreateKatalogDto, path : string) {
    const ktg = this.katalogRepository.create({
      nama : createKatalogDto.nama,
      harga : Number(createKatalogDto.harga),
      status : createKatalogDto.status === undefined ? true : String(createKatalogDto.status) == 'true',
      path : path,
      kategori : {
        id : Number(createKatalogDto.kategoriId)
      }
    });
    return this.katalogRepository.save(ktg);
  }

  findAll() {
  const katalog = this.katalogRepository.find({
    relations : {
      kategori : true
    }
  });

  if(!katalog) {
    throw new NotFoundException("Data tidak ditemukan");
  }

  return katalog;
  }

  async findByKategori(id : number) {
    const katalog = await this.katalogRepository.find({where : {
      kategori : {
        id: id
      }
    },
  relations :{
    kategori : true
  }})

  if(katalog.length <= 0 ) {
    throw new NotFoundException("Data tidak ditemukan");
  }
  return katalog;
  }

  async findByName(nama : string) {
    const katalog = await this.katalogRepository.find({where : {
      nama : Like(`%${nama}%`)
    },
  relations : {
    kategori : true
  }});

    if (katalog.length <= 0) {
      throw new NotFoundException("Data tidak ditemukan");
    }
    return katalog;
  }

  async findByStatus(status : boolean) {
    return await this.katalogRepository.find({where : {
      status : status
    },
  relations : {
    kategori : true
  }});
  }

  findOne(id: number) {
    const katalog = this.katalogRepository.findOne({where : {id}, relations : {kategori : true}});

    if(!katalog) {
      throw new NotFoundException("Data tidak ditemukan");
    }

    return katalog;
  }

  async update(id: number, updateKatalogDto: UpdateKatalogDto, path? : string | undefined) {
    const katalog = await this.katalogRepository.findOne({ where: { id } });
    if (!katalog) throw new NotFoundException('Data tidak ditemukan');

    if(path) {
      if (katalog.path) {
        const gambarLama = join(process.cwd(), 'public', katalog.path);
        if (existsSync(gambarLama)) {
          unlinkSync(gambarLama);
        }
      }
      katalog.path = path
    }

    if (updateKatalogDto.nama !== undefined) {
      katalog.nama = updateKatalogDto.nama;
    }

    if (updateKatalogDto.harga !== undefined) {
      katalog.harga = Number(updateKatalogDto.harga);
    }

    if (updateKatalogDto.status !== undefined) {
      katalog.status = String(updateKatalogDto.status) == 'true';
    }

    if (updateKatalogDto.kategoriId) {
      katalog.kategori = {id : Number(updateKatalogDto.kategoriId)} as any;
    }

    return await this.katalogRepository.save(katalog);

  }

  async remove(id: number) {

    const katalog = await this.katalogRepository.findOne({where : {id}});

    if (!katalog) {
      throw new NotFoundException("data tidak ditemukan");
    }

    const gambar = join(process.cwd(), 'public', katalog.path);
      if (existsSync(gambar)) {
        await unlinkSync(gambar);
      }

      this.katalogRepository.delete(id);

    return {
      message : "Berhasil menghapus katalog dengan id " + id
    }
  }
}

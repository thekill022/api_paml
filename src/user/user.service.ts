import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { User } from './entities/user.entity';
import { Like, Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';

@Injectable()
export class UserService {

  constructor(
    @InjectRepository(User)
    private userRepository : Repository<User>
  ) {}

  create(createUserDto: CreateUserDto) {
    const newUser = this.userRepository.create(createUserDto);
    return this.userRepository.save(newUser)
  }

  findAll() {
    return this.userRepository.find({
      select : ['firstName', 'lastName', 'email', 'role']
    });
  }

  findOne(id: number) {
    const user =  this.userRepository.findOne({where : {id : id},
    select : ['firstName', 'lastName', 'email', 'role']
    });

    if(!user) {
      throw new NotFoundException("User tidak ditemukan");
    }
    return user;
  }

  findByEmail(email : string) {
    const user = this.userRepository.findOne({where : {email}});

    if(!user) {
      throw new NotFoundException(`User dengan email ${email} tidak ditemukan`);
    }

    return user;

  }

  update(id: number, updateUserDto: UpdateUserDto) {
    this.userRepository.update(id, updateUserDto);

    const newData = this.userRepository.findOne({where : {id},
    select : ['firstName', 'lastName', 'email', 'role']
    });

    if (!newData) {
      throw new NotFoundException("User tidak ditemukan");
    }

    return newData;
  }

  remove(id: number) {
    this.userRepository.delete(id);
    return {
      message : "Berhasil menghapus data user"
    }
  }

  search(nama : string) {
    const userData = this.userRepository.find({where : {
      firstName : Like(nama),
      lastName : Like(nama)
    }, 
    select : ['firstName', 'lastName', 'email', 'role']
  })

    if(!userData) {
      throw new NotFoundException("Hasil tidak ditemukan");
    }

    return userData;

  }

}

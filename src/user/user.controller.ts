import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Req, ForbiddenException } from '@nestjs/common';
import { UserService } from './user.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { Role } from './role/role.decorator';
import { RoleGuard } from './role/role.guard';
import { Public } from 'src/auth/decorator/public.decorator';

@Controller('user')
export class UserController {
  constructor(
    private readonly userService: UserService
  ) {}

  @Post()
  @Role()
  @UseGuards(RoleGuard)
  create(@Body() createUserDto: CreateUserDto) {
    return this.userService.create(createUserDto);
  }

  @Public()
  @Post('register')
  registerMember(@Body() createUserDto: CreateUserDto) {
    return this.userService.create({
      ...createUserDto,
      role: 'member',
    });
  }

  @Get()
  @Role()
  @UseGuards(RoleGuard)
  findAll() {
    return this.userService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.userService.findOne(+id);
  }

  @Get("/search/:nama")
  findByName(@Param('nama') nama : string) {
    return this.userService.search(nama);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateUserDto: UpdateUserDto, @Req() request: any) {
    const user = request.user;
    const isSuperadmin = user?.role === 'superadmin';
    const isSelf = Number(user?.userId) === +id;

    if (!isSuperadmin && !isSelf) {
      throw new ForbiddenException('Hanya bisa mengubah akun sendiri');
    }

    if (!isSuperadmin) {
      return this.userService.update(+id, {
        firstName: updateUserDto.firstName,
        lastName: updateUserDto.lastName,
        password: updateUserDto.password,
      });
    }

    return this.userService.update(+id, updateUserDto);
  }

  @Delete(':id')
  @Role()
  @UseGuards(RoleGuard)
  remove(@Param('id') id: string) {
    return this.userService.remove(+id);
  }
}

import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UserService } from 'src/user/user.service';
import * as Bcrypt from 'bcrypt'

@Injectable()
export class AuthService {

    constructor(
        private readonly userService : UserService,
        private readonly jwtService : JwtService
    ){}

    async login(email : string, password : string) {
      const user = await this.userService.findByEmail(email);
      
      if (!user) {
        throw new UnauthorizedException("User dengan email tersebut tidak ditemukan");
      }
      
      const comparePw = await Bcrypt.compare(password, user!.password);
  
      if (!comparePw) {
        throw new UnauthorizedException()
      }

      const payload = {
          userId : user.id,
          firstName : user.firstName,
          lastName : user.lastName || "",
          email : user.email,
          role : user.role
        }
        return {
          access_token : await this.jwtService.signAsync(payload),
        }
    }
}

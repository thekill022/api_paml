import { Body, Controller, HttpStatus, Post, Res } from '@nestjs/common';
import { AuthService } from './auth.service';
import { Auth } from './dto/auth-user.dto';
import * as express from 'express';
import { Public } from './decorator/public.decorator';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
  ) {}

  @Public()
  @Post("/login")
  async signIn(@Body() authData : Auth, @Res() res : express.Response)  {
    try {
      const response = await this.authService.login(authData.email, authData.password);

      return res.status(HttpStatus.ACCEPTED).json(response)
    } catch (error) {
      return res.status(HttpStatus.UNAUTHORIZED).json({
        message : "Email atau password salah"
      });
    }
  }

}

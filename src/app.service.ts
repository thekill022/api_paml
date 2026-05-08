import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): { message: string } {
    return { message: 'Ni API v1 gueh ya, welcome yeah ' };
  }
}

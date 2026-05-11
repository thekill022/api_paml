import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserModule } from './user/user.module';
import { User } from './user/entities/user.entity';
import { AuthModule } from './auth/auth.module';

@Module({
  imports: [ConfigModule.forRoot({
    envFilePath : ".env"
  }),
  TypeOrmModule.forRoot({
    type : 'mysql',
    host : process.env.HOST,
    port : Number(process.env.DB_PORT),
    username : process.env.USER,
    password : process.env.PASS,
    database : process.env.DB,
    entities : [User],
    synchronize : true,
    logging : true
  }),
  UserModule,
  AuthModule
],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}

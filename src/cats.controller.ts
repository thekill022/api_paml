import { Controller, Get } from "@nestjs/common";

@Controller('cats')
export class CatsContoller {
    @Get()
    findAll() : string {
        return "Hai"
    }
}
import { CanActivate, ExecutionContext, ForbiddenException } from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { IS_ADMIN } from "./decorator/role-kategori.decorator";

export class KategoriGuard implements CanActivate {
    constructor(
        private readonly reflector : Reflector
    ) {}

    async canActivate(context: ExecutionContext): Promise<boolean> {
        const isAdmin = this.reflector.getAllAndOverride(IS_ADMIN, [
            context.getHandler(),
            context.getClass()
        ])

        if(!isAdmin) return true;

        const request = context.switchToHttp().getRequest();
        const user = request.user;

        if (user && (user.role == "superadmin" || user.role == "admin")) {
            return true;
        }

        throw new ForbiddenException("Izin tidak diberikan untuk endpoint ini");

    }

}
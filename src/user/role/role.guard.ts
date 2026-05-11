import { CanActivate, ExecutionContext, ForbiddenException, Injectable } from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { Observable } from "rxjs";
import { IS_SUPERADMIN } from "./role.decorator";

@Injectable()
export class RoleGuard implements CanActivate {

    constructor(
        private readonly reflector : Reflector
    ) {}

    async canActivate(context: ExecutionContext): Promise<boolean> {
        const isSuperadmin = this.reflector.getAllAndOverride(IS_SUPERADMIN, [
            context.getHandler(),
            context.getClass()
        ])

        if(!isSuperadmin) return true;

        const request = context.switchToHttp().getRequest();
        const user = request.user;

        if (user && user.role == 'superadmin') {
            return true;
        }

        throw new ForbiddenException("Hanya superadmin yang boleh mengakses endpoint");

    }

}
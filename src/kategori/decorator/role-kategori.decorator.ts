import { SetMetadata } from "@nestjs/common";

export const IS_ADMIN = 'isAdmin';
export const RoleAdmin = () => SetMetadata(IS_ADMIN, true);
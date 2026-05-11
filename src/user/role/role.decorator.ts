import { SetMetadata } from "@nestjs/common";

export const IS_SUPERADMIN = 'isSuperadmin';
export const Role = () => SetMetadata(IS_SUPERADMIN, true);
import { BeforeInsert, Column, Entity, PrimaryGeneratedColumn } from "typeorm";
import * as Bcrypt from 'bcrypt'


export enum Role {
    SUPERADMIN = 'superadmin',
    ADMIN = 'admin',
    MEMBER = 'member'
}

@Entity()
export class User {
    @PrimaryGeneratedColumn()
    id! : number;

    @Column()
    firstName! : string;

    @Column()
    lastName? : string;

    @Column({unique : true})
    email! : string;

    @Column()
    password! : string;

    @Column({
        type : 'enum',
        enum : Role,
        default : Role.MEMBER
    })
    role! : string

    @BeforeInsert()
    async hashPassword() {
        const salt = await Bcrypt.genSalt()
        this.password = await Bcrypt.hash(this.password, salt);
    }

}

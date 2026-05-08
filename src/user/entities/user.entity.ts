import { Column, PrimaryGeneratedColumn } from "typeorm";

export class User {
    @PrimaryGeneratedColumn()
    id! : string;

    @Column()
    firstName! : string;

    @Column()
    lastName! : string;

    @Column({unique : true})
    email! : string;

    @Column()
    password! : string;
}

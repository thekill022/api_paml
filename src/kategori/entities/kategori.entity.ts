import { Column, PrimaryGeneratedColumn } from "typeorm";

export class Kategori {
    @PrimaryGeneratedColumn()
    id! : Number;

    @Column()
    kategori! : String;
}

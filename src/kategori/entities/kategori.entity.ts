import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity()
export class Kategori {
    @PrimaryGeneratedColumn()
    id! : Number;

    @Column()
    kategori! : String;
}

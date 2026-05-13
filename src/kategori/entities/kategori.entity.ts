import { Katalog } from "src/katalog/entities/katalog.entity";
import { Column, Entity, OneToMany, PrimaryGeneratedColumn } from "typeorm";

@Entity()
export class Kategori {
    @PrimaryGeneratedColumn()
    id! : number;

    @Column({unique : true})
    kategori! : string;

    @OneToMany(() => Katalog, (katalog) => katalog.kategori)
    katalog! : Katalog[];
}

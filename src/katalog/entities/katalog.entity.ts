import { Kategori } from "src/kategori/entities/kategori.entity";
import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from "typeorm";

@Entity()
export class Katalog {
    @PrimaryGeneratedColumn()
    id! : number;

    @Column({unique : true})
    nama! : string;

    @Column({type : 'decimal'})
    harga! : number;

    @Column({default : true})
    status! : boolean;

    @Column()
    path! : string;

    @ManyToOne(() => Kategori, (kategori) => kategori.katalog)
    kategori! : Kategori;

}

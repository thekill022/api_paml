import { Katalog } from "src/katalog/entities/katalog.entity";
import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from "typeorm";

export enum BookingStatus {
    ACTIVE = 'active',
    RETURNED = 'returned',
    CANCELLED = 'cancelled'
}

@Entity()
export class Booking {
    @PrimaryGeneratedColumn()
    id! : number;

    @Column()
    customerName! : string;

    @Column({nullable : true})
    customerPhone? : string;

    @Column({type : 'date'})
    startDate! : string;

    @Column({type : 'date'})
    endDate! : string;

    @Column({type : 'date', nullable : true})
    actualReturnDate? : string;

    @Column({
        type : 'enum',
        enum : BookingStatus,
        default : BookingStatus.ACTIVE
    })
    status! : BookingStatus;

    @ManyToOne(() => Katalog)
    katalog! : Katalog;
}

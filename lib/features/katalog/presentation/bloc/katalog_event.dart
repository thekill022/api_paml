part of 'katalog_bloc.dart';

sealed class KatalogEvent extends Equatable {
  const KatalogEvent();

  @override
  List<Object?> get props => [];
}

class KatalogFetchRequested extends KatalogEvent {
  const KatalogFetchRequested();
}

class KatalogCreateRequested extends KatalogEvent {
  const KatalogCreateRequested({
    required this.nama,
    required this.harga,
    required this.status,
    required this.kategoriId,
    required this.imagePath,
  });

  final String nama;
  final String harga;
  final bool status;
  final int kategoriId;
  final String imagePath;

  @override
  List<Object?> get props => [nama, harga, status, kategoriId, imagePath];
}

class KatalogUpdateRequested extends KatalogEvent {
  const KatalogUpdateRequested({
    required this.id,
    required this.nama,
    required this.harga,
    required this.status,
    required this.kategoriId,
    this.imagePath,
  });

  final int id;
  final String nama;
  final String harga;
  final bool status;
  final int kategoriId;
  final String? imagePath;

  @override
  List<Object?> get props => [id, nama, harga, status, kategoriId, imagePath];
}

class KatalogDeleteRequested extends KatalogEvent {
  const KatalogDeleteRequested(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

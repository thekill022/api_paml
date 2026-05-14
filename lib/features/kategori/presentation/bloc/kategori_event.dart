part of 'kategori_bloc.dart';

sealed class KategoriEvent extends Equatable {
  const KategoriEvent();

  @override
  List<Object?> get props => [];
}

class KategoriFetchRequested extends KategoriEvent {
  const KategoriFetchRequested();
}

class KategoriCreateRequested extends KategoriEvent {
  const KategoriCreateRequested(this.kategori);

  final String kategori;

  @override
  List<Object?> get props => [kategori];
}

class KategoriUpdateRequested extends KategoriEvent {
  const KategoriUpdateRequested({required this.id, required this.kategori});

  final int id;
  final String kategori;

  @override
  List<Object?> get props => [id, kategori];
}

class KategoriDeleteRequested extends KategoriEvent {
  const KategoriDeleteRequested(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

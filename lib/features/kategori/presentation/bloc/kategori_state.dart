part of 'kategori_bloc.dart';

sealed class KategoriState extends Equatable {
  const KategoriState();

  @override
  List<Object?> get props => [];
}

class KategoriInitial extends KategoriState {
  const KategoriInitial();
}

class KategoriLoading extends KategoriState {
  const KategoriLoading();
}

class KategoriSubmitting extends KategoriState {
  const KategoriSubmitting();
}

class KategoriEmpty extends KategoriState {
  const KategoriEmpty();
}

class KategoriLoaded extends KategoriState {
  const KategoriLoaded(this.kategori);

  final List<KategoriModel> kategori;

  @override
  List<Object?> get props => [kategori];
}

class KategoriActionSuccess extends KategoriState {
  const KategoriActionSuccess(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class KategoriFailure extends KategoriState {
  const KategoriFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

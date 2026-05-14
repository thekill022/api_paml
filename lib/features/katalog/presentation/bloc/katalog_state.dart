part of 'katalog_bloc.dart';

sealed class KatalogState extends Equatable {
  const KatalogState();

  @override
  List<Object?> get props => [];
}

class KatalogInitial extends KatalogState {
  const KatalogInitial();
}

class KatalogLoading extends KatalogState {
  const KatalogLoading();
}

class KatalogSubmitting extends KatalogState {
  const KatalogSubmitting();
}

class KatalogEmpty extends KatalogState {
  const KatalogEmpty();
}

class KatalogLoaded extends KatalogState {
  const KatalogLoaded(this.katalog);

  final List<KatalogModel> katalog;

  @override
  List<Object?> get props => [katalog];
}

class KatalogActionSuccess extends KatalogState {
  const KatalogActionSuccess(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class KatalogFailure extends KatalogState {
  const KatalogFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

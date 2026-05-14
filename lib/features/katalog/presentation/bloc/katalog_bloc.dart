import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/katalog_model.dart';
import '../../data/repositories/katalog_repository.dart';

part 'katalog_event.dart';
part 'katalog_state.dart';

class KatalogBloc extends Bloc<KatalogEvent, KatalogState> {
  KatalogBloc(this._repository) : super(const KatalogInitial()) {
    on<KatalogFetchRequested>(_onFetch);
    on<KatalogSearchRequested>(_onSearch);
    on<KatalogStatusFilterRequested>(_onStatusFilter);
    on<KatalogCreateRequested>(_onCreate);
    on<KatalogUpdateRequested>(_onUpdate);
    on<KatalogDeleteRequested>(_onDelete);
  }

  final KatalogRepository _repository;

  Future<void> _onFetch(
    KatalogFetchRequested event,
    Emitter<KatalogState> emit,
  ) async {
    emit(const KatalogLoading());
    await _load(emit);
  }

  Future<void> _onSearch(
    KatalogSearchRequested event,
    Emitter<KatalogState> emit,
  ) async {
    emit(const KatalogLoading());
    try {
      final katalog = await _repository.searchKatalog(event.keyword);
      emit(katalog.isEmpty ? const KatalogEmpty() : KatalogLoaded(katalog));
    } on KatalogException catch (error) {
      emit(KatalogFailure(error.message));
    } catch (_) {
      emit(const KatalogFailure('Tidak dapat terhubung ke server'));
    }
  }

  Future<void> _onStatusFilter(
    KatalogStatusFilterRequested event,
    Emitter<KatalogState> emit,
  ) async {
    emit(const KatalogLoading());
    try {
      final katalog =
          event.status == null
              ? await _repository.fetchKatalog()
              : await _repository.fetchByStatus(event.status!);
      emit(katalog.isEmpty ? const KatalogEmpty() : KatalogLoaded(katalog));
    } on KatalogException catch (error) {
      emit(KatalogFailure(error.message));
    } catch (_) {
      emit(const KatalogFailure('Tidak dapat terhubung ke server'));
    }
  }

  Future<void> _onCreate(
    KatalogCreateRequested event,
    Emitter<KatalogState> emit,
  ) async {
    emit(const KatalogSubmitting());
    try {
      await _repository.createKatalog(
        nama: event.nama,
        harga: event.harga,
        status: event.status,
        kategoriId: event.kategoriId,
        imagePath: event.imagePath,
      );
      emit(const KatalogActionSuccess('Katalog berhasil ditambahkan'));
      await _load(emit);
    } on KatalogException catch (error) {
      emit(KatalogFailure(error.message));
    } catch (_) {
      emit(const KatalogFailure('Tidak dapat terhubung ke server'));
    }
  }

  Future<void> _onUpdate(
    KatalogUpdateRequested event,
    Emitter<KatalogState> emit,
  ) async {
    emit(const KatalogSubmitting());
    try {
      await _repository.updateKatalog(
        id: event.id,
        nama: event.nama,
        harga: event.harga,
        status: event.status,
        kategoriId: event.kategoriId,
        imagePath: event.imagePath,
      );
      emit(const KatalogActionSuccess('Katalog berhasil diubah'));
      await _load(emit);
    } on KatalogException catch (error) {
      emit(KatalogFailure(error.message));
    } catch (_) {
      emit(const KatalogFailure('Tidak dapat terhubung ke server'));
    }
  }

  Future<void> _onDelete(
    KatalogDeleteRequested event,
    Emitter<KatalogState> emit,
  ) async {
    emit(const KatalogSubmitting());
    try {
      await _repository.deleteKatalog(event.id);
      emit(const KatalogActionSuccess('Katalog berhasil dihapus'));
      await _load(emit);
    } on KatalogException catch (error) {
      emit(KatalogFailure(error.message));
    } catch (_) {
      emit(const KatalogFailure('Tidak dapat terhubung ke server'));
    }
  }

  Future<void> _load(Emitter<KatalogState> emit) async {
    try {
      final katalog = await _repository.fetchKatalog();
      emit(katalog.isEmpty ? const KatalogEmpty() : KatalogLoaded(katalog));
    } on KatalogException catch (error) {
      emit(KatalogFailure(error.message));
    } catch (_) {
      emit(const KatalogFailure('Tidak dapat terhubung ke server'));
    }
  }
}

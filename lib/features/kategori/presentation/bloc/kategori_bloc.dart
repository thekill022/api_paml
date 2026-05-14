import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/kategori_model.dart';
import '../../data/repositories/kategori_repository.dart';

part 'kategori_event.dart';
part 'kategori_state.dart';

class KategoriBloc extends Bloc<KategoriEvent, KategoriState> {
  KategoriBloc(this._repository) : super(const KategoriInitial()) {
    on<KategoriFetchRequested>(_onFetch);
    on<KategoriCreateRequested>(_onCreate);
    on<KategoriUpdateRequested>(_onUpdate);
    on<KategoriDeleteRequested>(_onDelete);
  }

  final KategoriRepository _repository;

  Future<void> _onFetch(
    KategoriFetchRequested event,
    Emitter<KategoriState> emit,
  ) async {
    emit(const KategoriLoading());
    await _load(emit);
  }

  Future<void> _onCreate(
    KategoriCreateRequested event,
    Emitter<KategoriState> emit,
  ) async {
    emit(const KategoriSubmitting());
    try {
      await _repository.createKategori(event.kategori);
      emit(const KategoriActionSuccess('Kategori berhasil ditambahkan'));
      await _load(emit);
    } on KategoriException catch (error) {
      emit(KategoriFailure(error.message));
    } catch (_) {
      emit(const KategoriFailure('Tidak dapat terhubung ke server'));
    }
  }

  Future<void> _onUpdate(
    KategoriUpdateRequested event,
    Emitter<KategoriState> emit,
  ) async {
    emit(const KategoriSubmitting());
    try {
      await _repository.updateKategori(id: event.id, kategori: event.kategori);
      emit(const KategoriActionSuccess('Kategori berhasil diubah'));
      await _load(emit);
    } on KategoriException catch (error) {
      emit(KategoriFailure(error.message));
    } catch (_) {
      emit(const KategoriFailure('Tidak dapat terhubung ke server'));
    }
  }

  Future<void> _onDelete(
    KategoriDeleteRequested event,
    Emitter<KategoriState> emit,
  ) async {
    emit(const KategoriSubmitting());
    try {
      await _repository.deleteKategori(event.id);
      emit(const KategoriActionSuccess('Kategori berhasil dihapus'));
      await _load(emit);
    } on KategoriException catch (error) {
      emit(KategoriFailure(error.message));
    } catch (_) {
      emit(const KategoriFailure('Tidak dapat terhubung ke server'));
    }
  }

  Future<void> _load(Emitter<KategoriState> emit) async {
    try {
      final kategori = await _repository.fetchKategori();
      emit(kategori.isEmpty ? const KategoriEmpty() : KategoriLoaded(kategori));
    } on KategoriException catch (error) {
      emit(KategoriFailure(error.message));
    } catch (_) {
      emit(const KategoriFailure('Tidak dapat terhubung ke server'));
    }
  }
}

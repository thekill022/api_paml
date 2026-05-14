import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../kategori/data/models/kategori_model.dart';
import '../../../kategori/data/repositories/kategori_repository.dart';
import '../../data/models/katalog_model.dart';
import '../../data/repositories/katalog_repository.dart';
import '../bloc/katalog_bloc.dart';

class KatalogFormPage extends StatefulWidget {
  const KatalogFormPage({super.key, this.katalog});

  final KatalogModel? katalog;

  @override
  State<KatalogFormPage> createState() => _KatalogFormPageState();
}

class _KatalogFormPageState extends State<KatalogFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _kategoriRepository = KategoriRepository();
  late final Future<List<KategoriModel>> _kategoriFuture;
  bool _status = true;
  int? _kategoriId;
  XFile? _pickedImage;

  bool get _isEdit => widget.katalog != null;

  @override
  void initState() {
    super.initState();
    _kategoriFuture = _kategoriRepository.fetchKategori();
    final katalog = widget.katalog;
    if (katalog != null) {
      _namaController.text = katalog.nama;
      _hargaController.text = katalog.harga.toStringAsFixed(0);
      _status = katalog.status;
      _kategoriId = katalog.kategori?.id;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
    );
    if (image == null) return;
    setState(() {
      _pickedImage = image;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_kategoriId == null) {
      _snack('Kategori wajib dipilih');
      return;
    }
    if (!_isEdit && _pickedImage == null) {
      _snack('Gambar wajib dipilih');
      return;
    }

    final bloc = context.read<KatalogBloc>();
    if (_isEdit) {
      bloc.add(
        KatalogUpdateRequested(
          id: widget.katalog!.id,
          nama: _namaController.text.trim(),
          harga: _hargaController.text.trim(),
          status: _status,
          kategoriId: _kategoriId!,
          imagePath: _pickedImage?.path,
        ),
      );
    } else {
      bloc.add(
        KatalogCreateRequested(
          nama: _namaController.text.trim(),
          harga: _hargaController.text.trim(),
          status: _status,
          kategoriId: _kategoriId!,
          imagePath: _pickedImage!.path,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KatalogBloc, KatalogState>(
      listener: (context, state) {
        if (state is KatalogActionSuccess) {
          Navigator.pop(context);
        }
      },
      child: BlocBuilder<KatalogBloc, KatalogState>(
        builder: (context, state) {
          final isSubmitting = state is KatalogSubmitting;
          return Scaffold(
            appBar: AppBar(
              title: Text(_isEdit ? 'Edit Katalog' : 'Tambah Katalog'),
            ),
            body: SafeArea(
              child: FutureBuilder<List<KategoriModel>>(
                future: _kategoriFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return _ErrorBox(
                      message: 'Kategori gagal dimuat: ${snapshot.error}',
                    );
                  }
                  final kategori = snapshot.data ?? [];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ImagePickerBox(
                            pickedImage: _pickedImage,
                            existingPath: widget.katalog?.path,
                            onPick: isSubmitting ? null : _pickImage,
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _namaController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Nama mobil',
                              prefixIcon: Icon(Icons.directions_car_outlined),
                            ),
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) return 'Nama mobil wajib diisi';
                              if (text.length < 3) {
                                return 'Nama minimal 3 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _hargaController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Harga sewa per hari',
                              prefixIcon: Icon(Icons.payments_outlined),
                            ),
                            validator: (value) {
                              final harga = num.tryParse(value?.trim() ?? '');
                              if (harga == null) return 'Harga wajib angka';
                              if (harga <= 0) return 'Harga harus lebih dari 0';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<int>(
                            value: _kategoriId,
                            decoration: const InputDecoration(
                              labelText: 'Kategori',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            items:
                                kategori
                                    .map(
                                      (item) => DropdownMenuItem<int>(
                                        value: item.id,
                                        child: Text(item.kategori),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                isSubmitting
                                    ? null
                                    : (value) {
                                      setState(() {
                                        _kategoriId = value;
                                      });
                                    },
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Kategori wajib dipilih'
                                        : null,
                          ),
                          const SizedBox(height: 14),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Mobil tersedia'),
                            subtitle: const Text(
                              'Nonaktifkan jika mobil tidak bisa disewa',
                            ),
                            value: _status,
                            onChanged:
                                isSubmitting
                                    ? null
                                    : (value) {
                                      setState(() {
                                        _status = value;
                                      });
                                    },
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: isSubmitting ? null : _submit,
                            child:
                                isSubmitting
                                    ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white,
                                      ),
                                    )
                                    : Text(
                                      _isEdit ? 'Simpan' : 'Tambah Katalog',
                                    ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ImagePickerBox extends StatelessWidget {
  const _ImagePickerBox({
    required this.pickedImage,
    required this.existingPath,
    required this.onPick,
  });

  final XFile? pickedImage;
  final String? existingPath;
  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) {
    Widget preview;
    if (pickedImage != null) {
      preview = Image.file(File(pickedImage!.path), fit: BoxFit.cover);
    } else if (existingPath != null && existingPath!.isNotEmpty) {
      preview = Image.network(
        KatalogRepository().imageUrl(existingPath!),
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => const Icon(Icons.image_not_supported_outlined),
      );
    } else {
      preview = const Icon(
        Icons.add_photo_alternate_outlined,
        size: 42,
        color: AppTheme.textSecondary,
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onPick,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            preview,
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                color: Colors.black.withValues(alpha: 0.52),
                child: const Text(
                  'Pilih Gambar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
      ),
    );
  }
}

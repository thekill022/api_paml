import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/kategori_model.dart';
import '../../data/repositories/kategori_repository.dart';
import '../bloc/kategori_bloc.dart';

class KategoriManagementPage extends StatelessWidget {
  const KategoriManagementPage({super.key});

  static const routeName = '/kategori';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              KategoriBloc(KategoriRepository())
                ..add(const KategoriFetchRequested()),
      child: const _KategoriManagementView(),
    );
  }
}

class _KategoriManagementView extends StatelessWidget {
  const _KategoriManagementView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KategoriBloc, KategoriState>(
      listener: (context, state) {
        if (state is KategoriFailure) {
          _snack(context, state.message);
        }
        if (state is KategoriActionSuccess) {
          _snack(context, state.message);
        }
      },
      builder: (context, state) {
        final isBusy = state is KategoriSubmitting;
        return Scaffold(
          appBar: AppBar(title: const Text('Kelola Kategori')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: isBusy ? null : () => _showForm(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah'),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<KategoriBloc>().add(
                  const KategoriFetchRequested(),
                );
              },
              child: _body(context, state),
            ),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, KategoriState state) {
    if (state is KategoriLoading || state is KategoriSubmitting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is KategoriFailure) {
      return _MessageState(
        title: 'Kategori gagal dimuat',
        subtitle: state.message,
        icon: Icons.error_outline_rounded,
        actionLabel: 'Coba Lagi',
        onAction:
            () => context.read<KategoriBloc>().add(
              const KategoriFetchRequested(),
            ),
      );
    }
    if (state is KategoriEmpty) {
      return _MessageState(
        title: 'Belum ada kategori',
        subtitle: 'Tambahkan kategori mobil seperti SUV, MPV, atau City Car.',
        icon: Icons.category_outlined,
        actionLabel: 'Tambah Kategori',
        onAction: () => _showForm(context),
      );
    }

    final items =
        state is KategoriLoaded ? state.kategori : const <KategoriModel>[];
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final kategori = items[index];
        return _KategoriTile(
          kategori: kategori,
          onEdit: () => _showForm(context, kategori: kategori),
          onDelete: () => _confirmDelete(context, kategori),
        );
      },
    );
  }

  Future<void> _showForm(
    BuildContext context, {
    KategoriModel? kategori,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: context.read<KategoriBloc>(),
          child: _KategoriFormSheet(kategori: kategori),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    KategoriModel kategori,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            titlePadding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
            contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            actionsPadding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            title: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Hapus kategori?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: 'Tutup',
                  onPressed: () => Navigator.pop(dialogContext, false),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            content: Text('${kategori.kategori} akan dihapus.'),
            actions: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.error,
                  ),
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Hapus'),
                ),
              ),
            ],
          ),
    );
    if (confirmed == true && context.mounted) {
      context.read<KategoriBloc>().add(KategoriDeleteRequested(kategori.id));
    }
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _KategoriFormSheet extends StatefulWidget {
  const _KategoriFormSheet({this.kategori});

  final KategoriModel? kategori;

  @override
  State<_KategoriFormSheet> createState() => _KategoriFormSheetState();
}

class _KategoriFormSheetState extends State<_KategoriFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  bool get _isEdit => widget.kategori != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.kategori?.kategori ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<KategoriBloc>();
    if (_isEdit) {
      bloc.add(
        KategoriUpdateRequested(
          id: widget.kategori!.id,
          kategori: _controller.text.trim(),
        ),
      );
    } else {
      bloc.add(KategoriCreateRequested(_controller.text.trim()));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _isEdit ? 'Edit Kategori' : 'Tambah Kategori',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Tutup',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nama kategori',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Kategori wajib diisi';
                if (text.length < 3) return 'Kategori minimal 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _submit,
              child: Text(_isEdit ? 'Simpan' : 'Tambah'),
            ),
          ],
        ),
      ),
    );
  }
}

class _KategoriTile extends StatelessWidget {
  const _KategoriTile({
    required this.kategori,
    required this.onEdit,
    required this.onDelete,
  });

  final KategoriModel kategori;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onEdit,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.category_rounded,
                  color: AppTheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  kategori.kategori,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Edit',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Hapus',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Icon(icon, size: 52, color: AppTheme.textSecondary),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 20),
        Center(
          child: FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ),
      ],
    );
  }
}

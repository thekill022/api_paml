import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/katalog_model.dart';
import '../../data/repositories/katalog_repository.dart';
import '../bloc/katalog_bloc.dart';
import 'katalog_form_page.dart';

class KatalogManagementPage extends StatelessWidget {
  const KatalogManagementPage({super.key});

  static const routeName = '/katalog';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              KatalogBloc(KatalogRepository())
                ..add(const KatalogFetchRequested()),
      child: const _KatalogManagementView(),
    );
  }
}

class _KatalogManagementView extends StatefulWidget {
  const _KatalogManagementView();

  @override
  State<_KatalogManagementView> createState() => _KatalogManagementViewState();
}

class _KatalogManagementViewState extends State<_KatalogManagementView> {
  final _searchController = TextEditingController();
  bool? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KatalogBloc, KatalogState>(
      listener: (context, state) {
        if (state is KatalogFailure) _snack(context, state.message);
        if (state is KatalogActionSuccess) _snack(context, state.message);
      },
      builder: (context, state) {
        final isBusy = state is KatalogSubmitting;
        return Scaffold(
          appBar: AppBar(title: const Text('Kelola Katalog')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: isBusy ? null : () => _openForm(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah'),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<KatalogBloc>().add(const KatalogFetchRequested());
              },
              child: _body(context, state),
            ),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, KatalogState state) {
    if (state is KatalogLoading || state is KatalogSubmitting) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        children: [
          _KatalogToolbar(
            controller: _searchController,
            selectedStatus: _statusFilter,
            onSearch: _search,
            onStatusChanged: _setStatusFilter,
          ),
          const SizedBox(height: 96),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }
    if (state is KatalogFailure) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        children: [
          _KatalogToolbar(
            controller: _searchController,
            selectedStatus: _statusFilter,
            onSearch: _search,
            onStatusChanged: _setStatusFilter,
          ),
          _MessageState(
            title: 'Katalog gagal dimuat',
            subtitle: state.message,
            icon: Icons.error_outline_rounded,
            actionLabel: 'Coba Lagi',
            onAction:
                () => context.read<KatalogBloc>().add(
                  const KatalogFetchRequested(),
                ),
          ),
        ],
      );
    }
    if (state is KatalogEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        children: [
          _KatalogToolbar(
            controller: _searchController,
            selectedStatus: _statusFilter,
            onSearch: _search,
            onStatusChanged: _setStatusFilter,
          ),
          _MessageState(
            title: 'Data tidak ditemukan',
            subtitle:
                'Tidak ada katalog yang cocok dengan pencarian atau filter saat ini.',
            icon: Icons.directions_car_outlined,
            actionLabel: 'Reset Filter',
            onAction: _resetFilter,
          ),
        ],
      );
    }

    final items =
        state is KatalogLoaded ? state.katalog : const <KatalogModel>[];
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      itemCount: items.length + 1,
      separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 14 : 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _KatalogToolbar(
            controller: _searchController,
            selectedStatus: _statusFilter,
            onSearch: _search,
            onStatusChanged: _setStatusFilter,
          );
        }
        final item = items[index - 1];
        return _KatalogTile(
          item: item,
          onEdit: () => _openForm(context, katalog: item),
          onDelete: () => _confirmDelete(context, item),
        );
      },
    );
  }

  void _search(String keyword) {
    setState(() {
      _statusFilter = null;
    });
    context.read<KatalogBloc>().add(KatalogSearchRequested(keyword));
  }

  void _setStatusFilter(bool? status) {
    setState(() {
      _statusFilter = status;
      _searchController.clear();
    });
    context.read<KatalogBloc>().add(KatalogStatusFilterRequested(status));
  }

  void _resetFilter() {
    setState(() {
      _statusFilter = null;
      _searchController.clear();
    });
    context.read<KatalogBloc>().add(const KatalogFetchRequested());
  }

  Future<void> _openForm(BuildContext context, {KatalogModel? katalog}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => BlocProvider.value(
              value: context.read<KatalogBloc>(),
              child: KatalogFormPage(katalog: katalog),
            ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, KatalogModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Hapus katalog?'),
            content: Text('${item.nama} akan dihapus beserta gambar katalog.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
    if (confirmed == true && context.mounted) {
      context.read<KatalogBloc>().add(KatalogDeleteRequested(item.id));
    }
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _KatalogToolbar extends StatelessWidget {
  const _KatalogToolbar({
    required this.controller,
    required this.selectedStatus,
    required this.onSearch,
    required this.onStatusChanged,
  });

  final TextEditingController controller;
  final bool? selectedStatus;
  final ValueChanged<String> onSearch;
  final ValueChanged<bool?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onSubmitted: onSearch,
          decoration: InputDecoration(
            labelText: 'Cari mobil',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon:
                controller.text.isEmpty
                    ? null
                    : IconButton(
                      tooltip: 'Bersihkan pencarian',
                      onPressed: () {
                        controller.clear();
                        onSearch('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Semua'),
              selected: selectedStatus == null,
              onSelected: (_) => onStatusChanged(null),
            ),
            FilterChip(
              label: const Text('Tersedia'),
              selected: selectedStatus == true,
              onSelected: (_) => onStatusChanged(true),
            ),
            FilterChip(
              label: const Text('Tidak tersedia'),
              selected: selectedStatus == false,
              onSelected: (_) => onStatusChanged(false),
            ),
          ],
        ),
      ],
    );
  }
}

class _KatalogTile extends StatelessWidget {
  const _KatalogTile({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final KatalogModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final imageUrl = KatalogRepository().imageUrl(item.path);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onEdit,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 88,
                  height: 76,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        width: 88,
                        height: 76,
                        color: const Color(0xFFE2E8F0),
                        child: const Icon(Icons.directions_car_outlined),
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.kategori?.kategori ?? 'Tanpa kategori',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _Badge(
                          label: NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(item.harga),
                          color: AppTheme.primary,
                        ),
                        _Badge(
                          label: item.status ? 'Tersedia' : 'Tidak tersedia',
                          color:
                              item.status ? AppTheme.secondary : AppTheme.error,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_KatalogAction>(
                tooltip: 'Aksi katalog',
                onSelected: (action) {
                  switch (action) {
                    case _KatalogAction.edit:
                      onEdit();
                    case _KatalogAction.delete:
                      onDelete();
                  }
                },
                itemBuilder:
                    (_) => const [
                      PopupMenuItem(
                        value: _KatalogAction.edit,
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: _KatalogAction.delete,
                        child: Text('Hapus'),
                      ),
                    ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
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

enum _KatalogAction { edit, delete }

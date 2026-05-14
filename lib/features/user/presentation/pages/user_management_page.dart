import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../bloc/user_bloc.dart';
import 'user_form_page.dart';

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  static const routeName = '/users';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => UserBloc(UserRepository())..add(const UserFetchRequested()),
      child: const _UserManagementView(),
    );
  }
}

class _UserManagementView extends StatelessWidget {
  const _UserManagementView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is UserActionSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isSubmitting = state is UserSubmitting;

        return Scaffold(
          appBar: AppBar(title: const Text('Kelola User')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: isSubmitting ? null : () => _openForm(context),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Tambah'),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<UserBloc>().add(const UserFetchRequested());
              },
              child: _buildBody(context, state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, UserState state) {
    if (state is UserLoading || state is UserSubmitting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is UserFailure) {
      return _StateMessage(
        icon: Icons.error_outline_rounded,
        title: 'Data user gagal dimuat',
        subtitle: state.message,
        actionLabel: 'Coba Lagi',
        onAction:
            () => context.read<UserBloc>().add(const UserFetchRequested()),
      );
    }

    if (state is UserEmpty) {
      return _StateMessage(
        icon: Icons.group_off_rounded,
        title: 'Belum ada user',
        subtitle: 'Tambahkan admin atau member untuk mulai mengelola akun.',
        actionLabel: 'Tambah User',
        onAction: () => _openForm(context),
      );
    }

    final users = state is UserLoaded ? state.users : const <UserModel>[];
    if (users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      itemBuilder: (context, index) {
        final user = users[index];
        return _UserTile(
          user: user,
          onEdit: () => _openForm(context, user: user),
          onDelete: () => _confirmDelete(context, user),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: users.length,
    );
  }

  Future<void> _openForm(BuildContext context, {UserModel? user}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => BlocProvider.value(
              value: context.read<UserBloc>(),
              child: UserFormPage(user: user),
            ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          actionsPadding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          title: Row(
            children: [
              const Expanded(
                child: Text(
                  'Hapus user?',
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
          content: Text('${user.fullName} akan dihapus dari DriveEase.'),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Hapus'),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      context.read<UserBloc>().add(UserDeleteRequested(user.id));
    }
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  final UserModel user;
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
              CircleAvatar(
                backgroundColor: _roleColor(user.role).withValues(alpha: 0.12),
                foregroundColor: _roleColor(user.role),
                child: Text(_initials(user)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName.isEmpty ? '-' : user.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _RoleBadge(role: user.role),
              PopupMenuButton<_UserAction>(
                tooltip: 'Aksi user',
                onSelected: (action) {
                  switch (action) {
                    case _UserAction.edit:
                      onEdit();
                    case _UserAction.delete:
                      onDelete();
                  }
                },
                itemBuilder:
                    (context) => const [
                      PopupMenuItem(
                        value: _UserAction.edit,
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: _UserAction.delete,
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

  String _initials(UserModel user) {
    final first = user.firstName.isNotEmpty ? user.firstName[0] : '';
    final last = user.lastName.isNotEmpty ? user.lastName[0] : '';
    final value = '$first$last'.trim();
    return value.isEmpty ? '?' : value.toUpperCase();
  }

  Color _roleColor(String role) {
    return switch (role) {
      'superadmin' => const Color(0xFF7C3AED),
      'admin' => AppTheme.primary,
      _ => AppTheme.secondary,
    };
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final color = switch (role) {
      'superadmin' => const Color(0xFF7C3AED),
      'admin' => AppTheme.primary,
      _ => AppTheme.secondary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
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

enum _UserAction { edit, delete }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/auth_session.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../data/settings_repository.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            LoginPage.routeName,
            (_) => false,
          );
        }
      },
      builder: (context, state) {
        final session = state is Authenticated ? state.session : null;

        return Scaffold(
          appBar: AppBar(title: const Text('Pengaturan')),
          body: SafeArea(
            child:
                session == null
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _ProfilePanel(session: session),
                        const SizedBox(height: 18),
                        _SettingsSection(
                          title: 'Akun',
                          children: [
                            _ActionTile(
                              icon: Icons.drive_file_rename_outline_rounded,
                              title: 'Edit nama',
                              subtitle: session.fullName,
                              onTap: () => _editName(context, session),
                            ),
                            _ActionTile(
                              icon: Icons.lock_reset_rounded,
                              title: 'Edit password',
                              subtitle: 'Ubah password akun saat ini',
                              onTap: () => _editPassword(context, session),
                            ),
                            _SettingsTile(
                              icon: Icons.badge_outlined,
                              title: 'Role',
                              subtitle: session.role,
                            ),
                            _SettingsTile(
                              icon: Icons.email_outlined,
                              title: 'Email',
                              subtitle: session.email,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _SettingsSection(
                          title: 'Session',
                          children: [
                            _ActionTile(
                              icon: Icons.logout_rounded,
                              title: 'Logout',
                              subtitle: 'Keluar dari akun DriveEase',
                              color: AppTheme.error,
                              onTap: () => _confirmLogout(context),
                            ),
                          ],
                        ),
                      ],
                    ),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => const _ConfirmActionDialog(
            title: 'Logout?',
            message: 'Session superadmin akan dihapus dari perangkat.',
            actionLabel: 'Logout',
            actionColor: AppTheme.error,
          ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(AuthLogoutRequested());
    }
  }

  Future<void> _editName(BuildContext context, AuthSession session) async {
    final userId = session.userId;
    if (userId == null) {
      _showSnack(context, 'User id tidak ditemukan. Silakan login ulang.');
      return;
    }

    final result = await showDialog<_NameResult>(
      context: context,
      builder:
          (_) => _EditNameDialog(
            firstName: session.firstName,
            lastName: session.lastName,
          ),
    );

    if (result == null || !context.mounted) return;

    try {
      await SettingsRepository().updateName(
        userId: userId,
        firstName: result.firstName,
        lastName: result.lastName,
      );
      if (!context.mounted) return;
      context.read<AuthBloc>().add(
        AuthSessionNameUpdated(
          firstName: result.firstName,
          lastName: result.lastName,
        ),
      );
      _showSnack(context, 'Nama berhasil diubah');
    } on SettingsException catch (error) {
      if (context.mounted) _showSnack(context, error.message);
    } catch (_) {
      if (context.mounted) {
        _showSnack(context, 'Tidak dapat terhubung ke server');
      }
    }
  }

  Future<void> _editPassword(BuildContext context, AuthSession session) async {
    final userId = session.userId;
    if (userId == null) {
      _showSnack(context, 'User id tidak ditemukan. Silakan login ulang.');
      return;
    }

    final password = await showDialog<String>(
      context: context,
      builder: (_) => const _EditPasswordDialog(),
    );

    if (password == null || !context.mounted) return;

    try {
      await SettingsRepository().updatePassword(
        userId: userId,
        password: password,
      );
      if (context.mounted) _showSnack(context, 'Password berhasil diubah');
    } on SettingsException catch (error) {
      if (context.mounted) _showSnack(context, error.message);
    } catch (_) {
      if (context.mounted) {
        _showSnack(context, 'Tidak dapat terhubung ke server');
      }
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _NameResult {
  const _NameResult({required this.firstName, required this.lastName});

  final String firstName;
  final String lastName;
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
        IconButton(
          tooltip: 'Tutup',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}

class _ConfirmActionDialog extends StatelessWidget {
  const _ConfirmActionDialog({
    required this.title,
    required this.message,
    required this.actionLabel,
    this.actionColor = AppTheme.primary,
  });

  final String title;
  final String message;
  final String actionLabel;
  final Color actionColor;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      title: _DialogHeader(title: title),
      content: Text(message),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: actionColor),
            onPressed: () => Navigator.pop(context, true),
            child: Text(actionLabel),
          ),
        ),
      ],
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.firstName, required this.lastName});

  final String firstName;
  final String lastName;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _NameResult(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      title: const _DialogHeader(title: 'Edit nama'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _firstNameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nama depan'),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Nama depan wajib diisi';
                if (text.length < 3) return 'Minimal 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Nama belakang'),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Nama belakang wajib diisi';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(onPressed: _submit, child: const Text('Simpan')),
        ),
      ],
    );
  }
}

class _EditPasswordDialog extends StatefulWidget {
  const _EditPasswordDialog();

  @override
  State<_EditPasswordDialog> createState() => _EditPasswordDialogState();
}

class _EditPasswordDialogState extends State<_EditPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      title: const _DialogHeader(title: 'Edit password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password baru',
                suffixIcon: IconButton(
                  tooltip: 'Tampilkan password',
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                final text = value ?? '';
                if (text.isEmpty) return 'Password wajib diisi';
                if (text.length < 8) return 'Password minimal 8 karakter';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Konfirmasi password',
                suffixIcon: IconButton(
                  tooltip: 'Tampilkan password',
                  onPressed: () {
                    setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    });
                  },
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Konfirmasi password tidak sama';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(onPressed: _submit, child: const Text('Simpan')),
        ),
      ],
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({required this.session});

  final AuthSession session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            foregroundColor: Colors.white,
            child: Text(
              _initials(session),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  session.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.82)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(AuthSession session) {
    final first = session.firstName.isNotEmpty ? session.firstName[0] : '';
    final last = session.lastName.isNotEmpty ? session.lastName[0] : '';
    final value = '$first$last'.trim();
    return value.isEmpty ? '?' : value.toUpperCase();
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _TileShell(
      icon: icon,
      title: title,
      subtitle: subtitle,
      color: AppTheme.primary,
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color = AppTheme.primary,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return _TileShell(
      icon: icon,
      title: title,
      subtitle: subtitle,
      color: color,
      onTap: onTap,
      trailing: Icon(Icons.chevron_right_rounded, color: color),
    );
  }
}

class _TileShell extends StatelessWidget {
  const _TileShell({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

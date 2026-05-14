import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/auth_session.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/pages/login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const routeName = '/home';

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
          appBar: AppBar(
            title: const Text('DriveEase'),
            actions: [
              IconButton(
                tooltip: 'Logout',
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
          body:
              session == null
                  ? const Center(child: CircularProgressIndicator())
                  : session.isSuperadmin
                  ? _SuperadminHome(session: session)
                  : _BasicHome(session: session),
        );
      },
    );
  }
}

class _SuperadminHome extends StatelessWidget {
  const _SuperadminHome({required this.session});

  final AuthSession session;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _WelcomePanel(
                title: 'Halo, ${session.fullName}',
                subtitle:
                    'Kelola operasional rental, data kendaraan, kategori, dan user dari satu dashboard.',
                role: 'Superadmin',
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Menu Superadmin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid.builder(
              itemCount: _superadminMenus.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.08,
              ),
              itemBuilder: (context, index) {
                final item = _superadminMenus[index];
                return _MenuTile(item: item);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BasicHome extends StatelessWidget {
  const _BasicHome({required this.session});

  final AuthSession session;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _WelcomePanel(
          title: 'Halo, ${session.fullName}',
          subtitle:
              'Dashboard untuk role ${session.role} akan dibuat setelah menu superadmin selesai.',
          role: session.role,
        ),
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({
    required this.title,
    required this.subtitle,
    required this.role,
  });

  final String title;
  final String subtitle;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  role,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.84),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item});

  final _SuperadminMenuItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showComingSoon(context, item.title),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 25),
              ),
              const Spacer(),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$title akan dibuat berikutnya')));
  }
}

class _SuperadminMenuItem {
  const _SuperadminMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

const _superadminMenus = [
  _SuperadminMenuItem(
    title: 'Kelola User',
    subtitle: 'Tambah admin, lihat member, dan atur akun',
    icon: Icons.group_rounded,
    color: AppTheme.primary,
  ),
  _SuperadminMenuItem(
    title: 'Kelola Kategori',
    subtitle: 'Atur kategori mobil rental',
    icon: Icons.category_rounded,
    color: AppTheme.secondary,
  ),
  _SuperadminMenuItem(
    title: 'Kelola Katalog',
    subtitle: 'Tambah, edit, dan hapus mobil',
    icon: Icons.directions_car_filled_rounded,
    color: Color(0xFFF59E0B),
  ),
  _SuperadminMenuItem(
    title: 'Mobil Tersedia',
    subtitle: 'Pantau stok kendaraan aktif',
    icon: Icons.fact_check_rounded,
    color: Color(0xFF7C3AED),
  ),
  _SuperadminMenuItem(
    title: 'Laporan',
    subtitle: 'Ringkasan data operasional',
    icon: Icons.bar_chart_rounded,
    color: Color(0xFF0F766E),
  ),
  _SuperadminMenuItem(
    title: 'Pengaturan',
    subtitle: 'Konfigurasi aplikasi DriveEase',
    icon: Icons.settings_rounded,
    color: Color(0xFF475569),
  ),
];

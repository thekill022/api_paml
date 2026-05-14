import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/auth_session.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../booking/presentation/pages/booking_management_page.dart';
import '../../../katalog/presentation/pages/katalog_management_page.dart';
import '../../../kategori/presentation/pages/kategori_management_page.dart';
import '../../../member/presentation/pages/member_home_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../user/presentation/pages/user_management_page.dart';

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
              if (session != null && !session.canManageOperations)
                IconButton(
                  tooltip: 'Pengaturan akun',
                  onPressed: () {
                    Navigator.pushNamed(context, SettingsPage.routeName);
                  },
                  icon: const Icon(Icons.settings_rounded),
                ),
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
                  : session.canManageOperations
                  ? _AdminHome(session: session)
                  : const MemberHomePage(),
        );
      },
    );
  }
}

class _AdminHome extends StatelessWidget {
  const _AdminHome({required this.session});

  final AuthSession session;

  @override
  Widget build(BuildContext context) {
    final isSuperadmin = session.isSuperadmin;
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _WelcomePanel(
                title:
                    isSuperadmin
                        ? 'Halo, ${session.fullName}'
                        : 'Dashboard Admin',
                subtitle:
                    isSuperadmin
                        ? 'Kelola operasional rental, booking, data kendaraan, kategori, dan user dari satu dashboard.'
                        : 'Pantau booking, ketersediaan mobil, katalog, dan kategori untuk operasional rental harian.',
                role: session.role,
                icon:
                    isSuperadmin
                        ? Icons.admin_panel_settings_rounded
                        : Icons.support_agent_rounded,
                color:
                    isSuperadmin ? AppTheme.primary : const Color(0xFF0F766E),
              ),
            ),
          ),
          if (!isSuperadmin)
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
              sliver: SliverToBoxAdapter(child: _AdminScopePanel()),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Text(
                session.isSuperadmin ? 'Menu Superadmin' : 'Menu Admin',
                style: const TextStyle(
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
              itemCount: _menusFor(session).length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.08,
              ),
              itemBuilder: (context, index) {
                final item = _menusFor(session)[index];
                return _MenuTile(item: item);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({
    required this.title,
    required this.subtitle,
    required this.role,
    this.icon = Icons.admin_panel_settings_rounded,
    this.color = AppTheme.primary,
  });

  final String title;
  final String subtitle;
  final String role;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
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
                child: Icon(icon, color: Colors.white, size: 28),
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

class _AdminScopePanel extends StatelessWidget {
  const _AdminScopePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppTheme.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Admin dapat mengelola booking, kategori, dan katalog. Kelola User hanya tersedia untuk superadmin.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.35),
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
        onTap: () => _handleTap(context),
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

  void _handleTap(BuildContext context) {
    if (item.title == 'Kelola User') {
      Navigator.pushNamed(context, UserManagementPage.routeName);
      return;
    }
    if (item.title == 'Kelola Kategori') {
      Navigator.pushNamed(context, KategoriManagementPage.routeName);
      return;
    }
    if (item.title == 'Kelola Katalog') {
      Navigator.pushNamed(context, KatalogManagementPage.routeName);
      return;
    }
    if (item.title == 'Booking') {
      Navigator.pushNamed(context, BookingManagementPage.routeName);
      return;
    }
    if (item.title == 'Pengaturan') {
      Navigator.pushNamed(context, SettingsPage.routeName);
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${item.title} akan dibuat berikutnya')),
      );
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
    title: 'Booking',
    subtitle: 'Cek tanggal sewa dan pengembalian',
    icon: Icons.event_available_rounded,
    color: Color(0xFF7C3AED),
  ),
  _SuperadminMenuItem(
    title: 'Pengaturan',
    subtitle: 'Konfigurasi aplikasi DriveEase',
    icon: Icons.settings_rounded,
    color: Color(0xFF475569),
  ),
];

const _adminMenus = [
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
    title: 'Booking',
    subtitle: 'Cek tanggal sewa dan pengembalian',
    icon: Icons.event_available_rounded,
    color: Color(0xFF7C3AED),
  ),
  _SuperadminMenuItem(
    title: 'Pengaturan',
    subtitle: 'Konfigurasi aplikasi DriveEase',
    icon: Icons.settings_rounded,
    color: Color(0xFF475569),
  ),
];

List<_SuperadminMenuItem> _menusFor(AuthSession session) {
  return session.isSuperadmin ? _superadminMenus : _adminMenus;
}

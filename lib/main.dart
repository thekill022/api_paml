import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/katalog/presentation/pages/katalog_management_page.dart';
import 'features/kategori/presentation/pages/kategori_management_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/user/presentation/pages/user_management_page.dart';

void main() {
  runApp(const DriveEaseApp());
}

class DriveEaseApp extends StatelessWidget {
  const DriveEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => AuthRepository(),
      child: BlocProvider(
        create:
            (context) =>
                AuthBloc(context.read<AuthRepository>())..add(AuthStarted()),
        child: MaterialApp(
          title: 'DriveEase',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialRoute: SplashPage.routeName,
          routes: {
            SplashPage.routeName: (_) => const SplashPage(),
            LoginPage.routeName: (_) => const LoginPage(),
            RegisterPage.routeName: (_) => const RegisterPage(),
            HomePage.routeName: (_) => const HomePage(),
            UserManagementPage.routeName: (_) => const UserManagementPage(),
            KategoriManagementPage.routeName:
                (_) => const KategoriManagementPage(),
            KatalogManagementPage.routeName:
                (_) => const KatalogManagementPage(),
            SettingsPage.routeName: (_) => const SettingsPage(),
          },
        ),
      ),
    );
  }
}

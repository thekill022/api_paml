import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../bloc/auth_bloc.dart';
import 'login_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushReplacementNamed(context, HomePage.routeName);
        } else if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, LoginPage.routeName);
        }
      },
      child: const Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DriveEaseMark(size: 84),
                SizedBox(height: 20),
                Text(
                  'DriveEase',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Rentcar lebih mudah',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                SizedBox(height: 28),
                SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DriveEaseMark extends StatelessWidget {
  const _DriveEaseMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(
        Icons.directions_car_filled_rounded,
        color: Colors.white,
        size: 42,
      ),
    );
  }
}

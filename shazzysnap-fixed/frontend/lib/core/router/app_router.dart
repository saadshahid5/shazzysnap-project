import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/download/download_screen.dart';
import '../../presentation/screens/library/library_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/player/player_screen.dart';
import '../../presentation/widgets/common/main_navigation_shell.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String download = '/download';
  static const String library = '/library';
  static const String settings = '/settings';
  static const String player = '/player';
}

final appRouterProvider = Provider<GoRouter>((ref) => GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(path:AppRoutes.splash,builder:(_,__)=>const SplashScreen()),
    ShellRoute(
      builder:(_,__,child)=>MainNavigationShell(child:child),
      routes:[
        GoRoute(path:AppRoutes.home,builder:(_,__)=>const HomeScreen()),
        GoRoute(path:AppRoutes.download,builder:(_,state)=>DownloadScreen(initialUrl:state.uri.queryParameters['url'])),
        GoRoute(path:AppRoutes.library,builder:(_,__)=>const LibraryScreen()),
        GoRoute(path:AppRoutes.settings,builder:(_,__)=>const SettingsScreen()),
      ],
    ),
    GoRoute(path:AppRoutes.player,builder:(_,state)=>PlayerScreen(filePath:state.uri.queryParameters['path']??'',title:state.uri.queryParameters['title']??'Video')),
  ],
  errorBuilder:(_,state)=>Scaffold(body:Center(child:Text('Not found: ${state.error}'))),
));

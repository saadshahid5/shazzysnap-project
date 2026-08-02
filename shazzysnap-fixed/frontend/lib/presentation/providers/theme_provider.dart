import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier,ThemeMode>((_)=>ThemeModeNotifier());
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier():super(ThemeMode.dark){_load();}
  Future<void> _load() async { final p=await SharedPreferences.getInstance(); final s=p.getString(AppConstants.keyThemeMode); state=s=='light'?ThemeMode.light:s=='system'?ThemeMode.system:ThemeMode.dark; }
  Future<void> setTheme(ThemeMode m) async { state=m; (await SharedPreferences.getInstance()).setString(AppConstants.keyThemeMode,m.name); }
  Future<void> toggleTheme() => setTheme(state==ThemeMode.dark?ThemeMode.light:ThemeMode.dark);
}

final themeColorProvider = StateNotifierProvider<ThemeColorNotifier,Color>((_)=>ThemeColorNotifier());
class ThemeColorNotifier extends StateNotifier<Color> {
  ThemeColorNotifier():super(AppTheme.defaultPrimary){_load();}
  Future<void> _load() async { final p=await SharedPreferences.getInstance(); final n=p.getString(AppConstants.keyThemeColor); if(n!=null&&AppTheme.themeColors.containsKey(n)) state=AppTheme.themeColors[n]!; }
  Future<void> setColor(String name) async { final c=AppTheme.themeColors[name]; if(c!=null){state=c;(await SharedPreferences.getInstance()).setString(AppConstants.keyThemeColor,name);} }
  String get currentColorName => AppTheme.themeColors.entries.firstWhere((e)=>e.value==state,orElse:()=>const MapEntry('Purple',Color(0xFF6C63FF))).key;
}

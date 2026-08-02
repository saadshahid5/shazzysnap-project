import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color defaultPrimary = Color(0xFF6C63FF);
  static const Color darkBackground = Color(0xFF0D0D1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF16213E);
  static const Color lightBackground = Color(0xFFF5F5FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF0F0FF);
  static const LinearGradient heroGradient = LinearGradient(colors:[Color(0xFF6C63FF),Color(0xFF3A3AFF),Color(0xFF00D2FF)],begin:Alignment.topLeft,end:Alignment.bottomRight);
  static const LinearGradient downloadGradient = LinearGradient(colors:[Color(0xFF11998e),Color(0xFF38ef7d)],begin:Alignment.centerLeft,end:Alignment.centerRight);
  static const Map<String,Color> themeColors = {'Purple':Color(0xFF6C63FF),'Blue':Color(0xFF2196F3),'Teal':Color(0xFF009688),'Green':Color(0xFF4CAF50),'Orange':Color(0xFFFF5722),'Pink':Color(0xFFE91E63),'Indigo':Color(0xFF3F51B5),'Cyan':Color(0xFF00BCD4)};

  static ThemeData lightTheme(Color primary) {
    final cs = ColorScheme.fromSeed(seedColor:primary,brightness:Brightness.light,primary:primary,surface:lightSurface);
    return ThemeData(useMaterial3:true,colorScheme:cs,scaffoldBackgroundColor:lightBackground,textTheme:_textTheme(Colors.black87),appBarTheme:AppBarTheme(backgroundColor:Colors.transparent,elevation:0,iconTheme:IconThemeData(color:primary)),cardTheme:CardTheme(elevation:0,color:lightCard,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16))),elevatedButtonTheme:ElevatedButtonThemeData(style:ElevatedButton.styleFrom(backgroundColor:primary,foregroundColor:Colors.white,elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14)))),inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:lightCard,border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:BorderSide.none),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:BorderSide.none),focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:BorderSide(color:primary,width:1.5))));
  }

  static ThemeData darkTheme(Color primary) {
    final cs = ColorScheme.fromSeed(seedColor:primary,brightness:Brightness.dark,primary:primary,surface:darkSurface);
    return ThemeData(useMaterial3:true,colorScheme:cs,scaffoldBackgroundColor:darkBackground,textTheme:_textTheme(Colors.white),appBarTheme:AppBarTheme(backgroundColor:Colors.transparent,elevation:0,iconTheme:IconThemeData(color:primary)),cardTheme:CardTheme(elevation:0,color:darkCard,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16))),elevatedButtonTheme:ElevatedButtonThemeData(style:ElevatedButton.styleFrom(backgroundColor:primary,foregroundColor:Colors.white,elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14)))),inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:darkSurface,border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:BorderSide.none),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:BorderSide(color:Colors.white12)),focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:BorderSide(color:primary,width:1.5))),dividerTheme:const DividerThemeData(color:Colors.white10));
  }

  static TextTheme _textTheme(Color c) => TextTheme(
    displayLarge:GoogleFonts.poppins(fontSize:32,fontWeight:FontWeight.w700,color:c),
    headlineLarge:GoogleFonts.poppins(fontSize:24,fontWeight:FontWeight.w700,color:c),
    headlineMedium:GoogleFonts.poppins(fontSize:20,fontWeight:FontWeight.w600,color:c),
    titleLarge:GoogleFonts.poppins(fontSize:18,fontWeight:FontWeight.w600,color:c),
    titleMedium:GoogleFonts.poppins(fontSize:16,fontWeight:FontWeight.w500,color:c),
    bodyLarge:GoogleFonts.poppins(fontSize:16,color:c),
    bodyMedium:GoogleFonts.poppins(fontSize:14,color:c),
    bodySmall:GoogleFonts.poppins(fontSize:12,color:c.withOpacity(0.7)),
    labelLarge:GoogleFonts.poppins(fontSize:14,fontWeight:FontWeight.w600,color:c),
  );
}

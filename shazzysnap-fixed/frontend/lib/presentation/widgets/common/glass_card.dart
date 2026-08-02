import 'dart:ui';
import 'package:flutter/material.dart';
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding,margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double blurSigma;
  final VoidCallback? onTap;
  const GlassCard({super.key,required this.child,this.padding,this.margin,this.borderRadius=16,this.backgroundColor,this.gradient,this.blurSigma=10,this.onTap});
  @override
  Widget build(BuildContext context) {
    final isDark=Theme.of(context).brightness==Brightness.dark;
    Widget card=ClipRRect(borderRadius:BorderRadius.circular(borderRadius),child:BackdropFilter(filter:ImageFilter.blur(sigmaX:blurSigma,sigmaY:blurSigma),child:Container(padding:padding,decoration:BoxDecoration(color:gradient==null?(backgroundColor??(isDark?Colors.white.withOpacity(0.05):Colors.white.withOpacity(0.7))):null,gradient:gradient,borderRadius:BorderRadius.circular(borderRadius),border:Border.all(color:isDark?Colors.white.withOpacity(0.1):Colors.white.withOpacity(0.8))),child:child)));
    if(margin!=null) card=Padding(padding:margin!,child:card);
    if(onTap!=null) return GestureDetector(onTap:onTap,child:card);
    return card;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState()=>_State();
}
class _State extends State<SplashScreen> {
  @override void initState(){super.initState();Future.delayed(const Duration(milliseconds:2800),(){if(mounted)context.go(AppRoutes.home);});}
  @override
  Widget build(BuildContext context){
    return Scaffold(body:Container(decoration:const BoxDecoration(gradient:LinearGradient(colors:[Color(0xFF0D0D1A),Color(0xFF1A1A2E),Color(0xFF0D0D1A)],begin:Alignment.topLeft,end:Alignment.bottomRight)),child:Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
      Container(width:100,height:100,decoration:BoxDecoration(gradient:AppTheme.heroGradient,borderRadius:BorderRadius.circular(28),boxShadow:[BoxShadow(color:const Color(0xFF6C63FF).withOpacity(0.4),blurRadius:30,spreadRadius:5)]),child:const Icon(Icons.download_rounded,color:Colors.white,size:52)).animate().scale(begin:const Offset(0.3,0.3),end:const Offset(1,1),duration:700.ms,curve:Curves.elasticOut).fadeIn(duration:400.ms).then().shimmer(duration:1200.ms,color:Colors.white24),
      const SizedBox(height:24),
      const Text('ShazzySnap',style:TextStyle(fontSize:36,fontWeight:FontWeight.w700,color:Colors.white,letterSpacing:1.5,fontFamily:'Poppins')).animate().fadeIn(delay:600.ms).slideY(begin:0.3,end:0),
      const SizedBox(height:8),
      const Text('Download • Authorized • Content',style:TextStyle(fontSize:12,color:Colors.white38,letterSpacing:3,fontFamily:'Poppins')).animate().fadeIn(delay:900.ms),
      const SizedBox(height:60),
      Row(mainAxisSize:MainAxisSize.min,children:List.generate(3,(i)=>Container(margin:const EdgeInsets.symmetric(horizontal:4),width:8,height:8,decoration:const BoxDecoration(shape:BoxShape.circle,color:Color(0xFF6C63FF))).animate(onPlay:(c)=>c.repeat()).scale(begin:const Offset(0.5,0.5),end:const Offset(1.3,1.3),delay:Duration(milliseconds:i*200),duration:600.ms).then().scale(end:const Offset(0.5,0.5),duration:600.ms))).animate().fadeIn(delay:1200.ms),
    ]))));
  }
}

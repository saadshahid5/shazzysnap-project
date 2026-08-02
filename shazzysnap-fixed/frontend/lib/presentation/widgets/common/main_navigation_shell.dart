import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';

class MainNavigationShell extends StatefulWidget {
  final Widget child;
  const MainNavigationShell({super.key,required this.child});
  @override State<MainNavigationShell> createState()=>_State();
}
class _State extends State<MainNavigationShell> {
  int _idx=0;
  static const _routes=[AppRoutes.home,AppRoutes.download,AppRoutes.library,AppRoutes.settings];
  static const _icons=[Icons.home_outlined,Icons.download_outlined,Icons.folder_outlined,Icons.settings_outlined];
  static const _activeIcons=[Icons.home_rounded,Icons.download_rounded,Icons.folder_rounded,Icons.settings_rounded];
  static const _labels=['Home','Download','Library','Settings'];
  void _tap(int i){if(_idx==i)return;setState(()=>_idx=i);context.go(_routes[i]);}
  @override
  Widget build(BuildContext context){
    final isDark=Theme.of(context).brightness==Brightness.dark;
    final primary=Theme.of(context).colorScheme.primary;
    final loc=GoRouterState.of(context).uri.toString();
    for(int i=0;i<_routes.length;i++){if(loc.startsWith(_routes[i])&&_idx!=i){WidgetsBinding.instance.addPostFrameCallback((_){if(mounted)setState(()=>_idx=i);});break;}}
    return Scaffold(body:widget.child,bottomNavigationBar:Container(decoration:BoxDecoration(color:isDark?AppTheme.darkSurface:AppTheme.lightSurface,border:Border(top:BorderSide(color:isDark?Colors.white10:Colors.black.withOpacity(0.05)))),child:SafeArea(child:SizedBox(height:64,child:Row(children:List.generate(4,(i){final sel=_idx==i;return Expanded(child:GestureDetector(onTap:()=>_tap(i),behavior:HitTestBehavior.opaque,child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[AnimatedContainer(duration:const Duration(milliseconds:200),padding:const EdgeInsets.symmetric(horizontal:12,vertical:4),decoration:BoxDecoration(color:sel?primary.withOpacity(0.12):Colors.transparent,borderRadius:BorderRadius.circular(12)),child:Icon(sel?_activeIcons[i]:_icons[i],color:sel?primary:(isDark?Colors.white38:Colors.black38),size:22)),const SizedBox(height:2),Text(_labels[i],style:TextStyle(fontSize:10,fontWeight:sel?FontWeight.w600:FontWeight.w400,color:sel?primary:(isDark?Colors.white38:Colors.black38),fontFamily:'Poppins'))]))));})))))});
  }
}

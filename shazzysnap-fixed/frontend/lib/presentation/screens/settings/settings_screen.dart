import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override ConsumerState<SettingsScreen> createState()=>_State();
}
class _State extends ConsumerState<SettingsScreen> {
  bool _autoUpdate=true,_notifications=true;
  @override void initState(){super.initState();_load();}
  Future<void> _load() async { final p=await SharedPreferences.getInstance(); setState((){_autoUpdate=p.getBool(AppConstants.keyAutoUpdate)??true;_notifications=p.getBool(AppConstants.keyNotifications)??true;}); }
  @override
  Widget build(BuildContext context){
    final isDark=Theme.of(context).brightness==Brightness.dark;
    final themeMode=ref.watch(themeModeProvider);
    final colorNotifier=ref.watch(themeColorProvider.notifier);
    final primary=Theme.of(context).colorScheme.primary;
    return Scaffold(backgroundColor:isDark?AppTheme.darkBackground:AppTheme.lightBackground,body:SafeArea(child:CustomScrollView(physics:const BouncingScrollPhysics(),slivers:[
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(20,16,20,24),child:Text('Settings',style:Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight:FontWeight.w700)).animate().fadeIn().slideX(begin:-0.2,end:0))),
      SliverToBoxAdapter(child:_section(context,isDark,'Appearance',[
        _switch(context,isDark,Icons.dark_mode_rounded,'Dark Mode','Use dark theme',themeMode==ThemeMode.dark,(v)=>ref.read(themeModeProvider.notifier).setTheme(v?ThemeMode.dark:ThemeMode.light),primary),
        _div(isDark),
        _tile(context,isDark,Icons.palette_rounded,'Theme Color',colorNotifier.currentColorName,()=>_colorPicker(context,ref),primary,trailing:Container(width:24,height:24,decoration:BoxDecoration(color:primary,shape:BoxShape.circle))),
      ]).animate().fadeIn(delay:100.ms)),
      SliverToBoxAdapter(child:_section(context,isDark,'Downloads',[
        _switch(context,isDark,Icons.notifications_rounded,'Notifications','Show progress notifications',_notifications,(v)async{setState(()=>_notifications=v);(await SharedPreferences.getInstance()).setBool(AppConstants.keyNotifications,v);},primary),
        _div(isDark),
        _switch(context,isDark,Icons.system_update_alt_rounded,'Auto Update','Check for app updates',_autoUpdate,(v)async{setState(()=>_autoUpdate=v);(await SharedPreferences.getInstance()).setBool(AppConstants.keyAutoUpdate,v);},primary),
      ]).animate().fadeIn(delay:200.ms)),
      SliverToBoxAdapter(child:_section(context,isDark,'Storage',[
        _tile(context,isDark,Icons.cleaning_services_rounded,'Clear Cache','Free up storage space',()=>_clearCache(context),primary),
        _div(isDark),
        _tile(context,isDark,Icons.delete_sweep_rounded,'Clear History','Remove failed & cancelled',()=>_clearHistory(context,ref),primary,iconColor:Colors.orange),
      ]).animate().fadeIn(delay:300.ms)),
      SliverToBoxAdapter(child:_section(context,isDark,'About',[
        _tile(context,isDark,Icons.info_outline_rounded,'Version','1.0.0',null,primary),
        _div(isDark),
        _tile(context,isDark,Icons.favorite_rounded,'Rate App','If you enjoy ShazzySnap',(){},primary,iconColor:Colors.red),
      ]).animate().fadeIn(delay:400.ms)),
      const SliverToBoxAdapter(child:SizedBox(height:100)),
    ])));
  }

  Widget _section(BuildContext ctx,bool isDark,String title,List<Widget> children)=>Padding(padding:const EdgeInsets.fromLTRB(16,0,16,16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Padding(padding:const EdgeInsets.only(left:4,bottom:8),child:Text(title.toUpperCase(),style:TextStyle(color:isDark?Colors.white38:Colors.black38,fontSize:11,fontWeight:FontWeight.w700,letterSpacing:1.2,fontFamily:'Poppins'))),Container(decoration:BoxDecoration(color:isDark?Colors.white.withOpacity(0.05):Colors.white,borderRadius:BorderRadius.circular(16),border:Border.all(color:isDark?Colors.white10:Colors.black.withOpacity(0.06))),child:Column(children:children))]));

  Widget _tile(BuildContext ctx,bool isDark,IconData icon,String title,String sub,VoidCallback? onTap,Color primary,{Color? iconColor,Widget? trailing})=>InkWell(onTap:onTap,borderRadius:BorderRadius.circular(16),child:Padding(padding:const EdgeInsets.symmetric(horizontal:16,vertical:14),child:Row(children:[Container(width:38,height:38,decoration:BoxDecoration(color:(iconColor??primary).withOpacity(0.12),borderRadius:BorderRadius.circular(10)),child:Icon(icon,size:20,color:iconColor??primary)),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(fontSize:14,fontWeight:FontWeight.w600,color:isDark?Colors.white:Colors.black87,fontFamily:'Poppins')),Text(sub,style:TextStyle(fontSize:12,color:isDark?Colors.white38:Colors.black38,fontFamily:'Poppins'))])),trailing??(onTap!=null?Icon(Icons.chevron_right_rounded,color:isDark?Colors.white24:Colors.black24):const SizedBox.shrink())])));

  Widget _switch(BuildContext ctx,bool isDark,IconData icon,String title,String sub,bool val,ValueChanged<bool> onChanged,Color primary)=>Padding(padding:const EdgeInsets.symmetric(horizontal:16,vertical:10),child:Row(children:[Container(width:38,height:38,decoration:BoxDecoration(color:primary.withOpacity(0.12),borderRadius:BorderRadius.circular(10)),child:Icon(icon,size:20,color:primary)),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(fontSize:14,fontWeight:FontWeight.w600,color:isDark?Colors.white:Colors.black87,fontFamily:'Poppins')),Text(sub,style:TextStyle(fontSize:12,color:isDark?Colors.white38:Colors.black38,fontFamily:'Poppins'))])),Switch(value:val,onChanged:onChanged,activeColor:primary)]));

  Widget _div(bool isDark)=>Divider(height:1,indent:68,color:isDark?Colors.white10:Colors.black.withOpacity(0.05));

  void _colorPicker(BuildContext context,WidgetRef ref){
    final notifier=ref.read(themeColorProvider.notifier);
    showModalBottomSheet(context:context,shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(24))),builder:(ctx)=>Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Choose Theme Color',style:Theme.of(context).textTheme.titleLarge),const SizedBox(height:20),Wrap(spacing:16,runSpacing:16,children:AppTheme.themeColors.entries.map((e){final sel=notifier.currentColorName==e.key;return GestureDetector(onTap:(){notifier.setColor(e.key);Navigator.pop(ctx);},child:Column(children:[Container(width:52,height:52,decoration:BoxDecoration(color:e.value,shape:BoxShape.circle,boxShadow:[BoxShadow(color:e.value.withOpacity(0.4),blurRadius:10,spreadRadius:sel?3:0)],border:sel?Border.all(color:Colors.white,width:3):null),child:sel?const Icon(Icons.check,color:Colors.white):null),const SizedBox(height:6),Text(e.key,style:const TextStyle(fontSize:11,fontFamily:'Poppins'))]));}).toList()),const SizedBox(height:16)])));
  }

  Future<void> _clearCache(BuildContext ctx)async{if(mounted)ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content:const Text('Cache cleared successfully'),backgroundColor:Colors.green.shade700,behavior:SnackBarBehavior.floating,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(10))));}
  Future<void> _clearHistory(BuildContext ctx,WidgetRef ref)async{final ok=await showDialog<bool>(context:ctx,builder:(d)=>AlertDialog(shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)),title:const Text('Clear History'),content:const Text('Remove failed and cancelled downloads?'),actions:[TextButton(onPressed:()=>Navigator.pop(d,false),child:const Text('Cancel')),TextButton(onPressed:()=>Navigator.pop(d,true),child:const Text('Clear',style:TextStyle(color:Colors.red)))]));if(ok==true){await ref.read(downloadRepositoryProvider).clearHistory();if(mounted)ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content:const Text('History cleared'),behavior:SnackBarBehavior.floating,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(10))));}}
}

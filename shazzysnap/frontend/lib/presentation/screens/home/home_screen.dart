import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clipboard/clipboard.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../widgets/home/trending_section.dart';
import '../../widgets/home/recent_downloads_section.dart';
import '../../widgets/common/glass_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override ConsumerState<HomeScreen> createState()=>_State();
}
class _State extends ConsumerState<HomeScreen> {
  final _scroll=ScrollController();
  final _searchCtrl=TextEditingController();
  @override void initState(){super.initState();_scroll.addListener((){if(_scroll.position.pixels>=_scroll.position.maxScrollExtent-400){ref.read(homeViewModelProvider.notifier).loadTrending();}});}
  @override void dispose(){_scroll.dispose();_searchCtrl.dispose();super.dispose();}
  @override
  Widget build(BuildContext context){
    final state=ref.watch(homeViewModelProvider);
    final isDark=Theme.of(context).brightness==Brightness.dark;
    final primary=Theme.of(context).colorScheme.primary;
    final hour=DateTime.now().hour;
    final greeting=hour<12?'Good morning 👋':hour<17?'Good afternoon 👋':'Good evening 👋';
    return Scaffold(backgroundColor:isDark?AppTheme.darkBackground:AppTheme.lightBackground,body:CustomScrollView(controller:_scroll,physics:const BouncingScrollPhysics(),slivers:[
      SliverToBoxAdapter(child:SafeArea(child:Padding(padding:const EdgeInsets.fromLTRB(20,16,20,8),child:Row(children:[
        Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(greeting,style:Theme.of(context).textTheme.bodyMedium?.copyWith(color:isDark?Colors.white60:Colors.black54)),Text('ShazzySnap',style:Theme.of(context).textTheme.headlineLarge?.copyWith(color:primary,fontWeight:FontWeight.w700))]).animate().fadeIn().slideX(begin:-0.2,end:0),
        const Spacer(),
        GlassCard(padding:const EdgeInsets.all(10),child:Icon(Icons.notifications_outlined,color:isDark?Colors.white70:Colors.black54,size:22)).animate().fadeIn(delay:200.ms),
      ])))),
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(16,8,16,12),child:Row(children:[
        Expanded(child:TextField(controller:_searchCtrl,onChanged:(v)=>ref.read(homeViewModelProvider.notifier).search(v),decoration:InputDecoration(hintText:'Search or paste URL...',prefixIcon:const Icon(Icons.search_rounded,size:20),suffixIcon:_searchCtrl.text.isNotEmpty?IconButton(icon:const Icon(Icons.clear_rounded,size:18),onPressed:(){_searchCtrl.clear();ref.read(homeViewModelProvider.notifier).search('');}):null))),
        const SizedBox(width:10),
        GlassCard(onTap:()async{final t=await FlutterClipboard.paste();if(t.startsWith('http')&&mounted)context.go('${AppRoutes.download}?url=${Uri.encodeComponent(t)}');},padding:const EdgeInsets.all(14),gradient:LinearGradient(colors:[primary.withOpacity(0.8),primary]),child:const Icon(Icons.content_paste_rounded,color:Colors.white,size:22)),
      ]))),
      if(state.searchQuery.isNotEmpty)
        SliverToBoxAdapter(child:state.isSearching?const Padding(padding:EdgeInsets.all(40),child:Center(child:CircularProgressIndicator())):ListView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:state.searchResults.length,itemBuilder:(ctx,i){final item=state.searchResults[i];return ListTile(leading:ClipRRect(borderRadius:BorderRadius.circular(8),child:Image.network(item.thumbnailUrl,width:60,height:40,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Container(width:60,height:40,color:Colors.grey.withOpacity(0.3),child:const Icon(Icons.video_library)))),title:Text(item.title,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontFamily:'Poppins',fontSize:13)),subtitle:Text(item.platform,style:TextStyle(color:primary,fontSize:11)),trailing:const Icon(Icons.download_rounded,size:20),onTap:()=>context.go('${AppRoutes.download}?url=${Uri.encodeComponent(item.sourceUrl)}'));})  )
      else ...[
        SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(16,0,16,8),child:_Categories(state:state,primary:primary).animate().fadeIn(delay:200.ms))),
        SliverToBoxAdapter(child:TrendingSection(items:state.trendingItems,isLoading:state.isTrendingLoading).animate().fadeIn(delay:300.ms)),
        if(state.recentDownloads.isNotEmpty) SliverToBoxAdapter(child:RecentDownloadsSection(downloads:state.recentDownloads).animate().fadeIn(delay:400.ms)),
        const SliverToBoxAdapter(child:SizedBox(height:100)),
      ],
    ]));
  }
}

class _Categories extends ConsumerWidget {
  final HomeState state;final Color primary;
  const _Categories({required this.state,required this.primary});
  @override
  Widget build(BuildContext context,WidgetRef ref){
    const cats=['All','Nature','Music','Travel','Design','Education'];
    return SizedBox(height:40,child:ListView.builder(scrollDirection:Axis.horizontal,itemCount:cats.length,itemBuilder:(ctx,i){final cat=cats[i];final sel=(i==0&&state.selectedCategory==null)||state.selectedCategory==cat;return GestureDetector(onTap:()=>ref.read(homeViewModelProvider.notifier).selectCategory(i==0?null:cat),child:AnimatedContainer(duration:const Duration(milliseconds:200),margin:const EdgeInsets.only(right:8),padding:const EdgeInsets.symmetric(horizontal:16,vertical:8),decoration:BoxDecoration(color:sel?primary:primary.withOpacity(0.1),borderRadius:BorderRadius.circular(20)),child:Text(cat,style:TextStyle(color:sel?Colors.white:primary,fontSize:12,fontWeight:sel?FontWeight.w600:FontWeight.w400,fontFamily:'Poppins'))));},));
  }
}

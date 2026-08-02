import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/download_entity.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});
  @override ConsumerState<LibraryScreen> createState()=>_State();
}
class _State extends ConsumerState<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override void initState(){super.initState();_tab=TabController(length:4,vsync:this);}
  @override void dispose(){_tab.dispose();super.dispose();}
  @override
  Widget build(BuildContext context){
    final isDark=Theme.of(context).brightness==Brightness.dark;
    final primary=Theme.of(context).colorScheme.primary;
    return Scaffold(backgroundColor:isDark?AppTheme.darkBackground:AppTheme.lightBackground,body:NestedScrollView(headerSliverBuilder:(ctx,_)=>[
      SliverToBoxAdapter(child:SafeArea(child:Padding(padding:const EdgeInsets.fromLTRB(20,16,20,0),child:Text('Library',style:Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight:FontWeight.w700)).animate().fadeIn().slideX(begin:-0.2,end:0)))),
      SliverPersistentHeader(pinned:true,delegate:_TabBarDelegate(TabBar(controller:_tab,isScrollable:true,tabAlignment:TabAlignment.start,labelColor:primary,unselectedLabelColor:isDark?Colors.white38:Colors.black38,indicatorColor:primary,indicatorSize:TabBarIndicatorSize.label,labelStyle:const TextStyle(fontFamily:'Poppins',fontWeight:FontWeight.w600,fontSize:13),unselectedLabelStyle:const TextStyle(fontFamily:'Poppins',fontSize:13),padding:const EdgeInsets.symmetric(horizontal:12),tabs:const[Tab(icon:Icon(Icons.videocam_rounded,size:16),text:'Videos'),Tab(icon:Icon(Icons.music_note_rounded,size:16),text:'Audio'),Tab(icon:Icon(Icons.favorite_rounded,size:16),text:'Favorites'),Tab(icon:Icon(Icons.history_rounded,size:16),text:'History')]),isDark:isDark)),
    ],body:TabBarView(controller:_tab,children:[_DownloadList(filter:0),_DownloadList(filter:1),_DownloadList(filter:2),_DownloadList(filter:3)])));
  }
}

class _DownloadList extends ConsumerWidget {
  final int filter;
  const _DownloadList({required this.filter});
  @override
  Widget build(BuildContext context,WidgetRef ref){
    final repo=ref.watch(downloadRepositoryProvider);
    return FutureBuilder<List<DownloadEntity>>(
      future:_get(repo),
      builder:(ctx,snap){
        if(snap.connectionState==ConnectionState.waiting) return const Center(child:CircularProgressIndicator());
        final items=snap.data??[];
        if(items.isEmpty) return _Empty(filter:filter);
        return ListView.builder(padding:const EdgeInsets.fromLTRB(16,12,16,100),physics:const BouncingScrollPhysics(),itemCount:items.length,itemBuilder:(ctx,i){
          final d=items[i];
          return Dismissible(key:Key(d.id),direction:DismissDirection.endToStart,background:Container(alignment:Alignment.centerRight,padding:const EdgeInsets.only(right:20),decoration:BoxDecoration(color:Colors.red.withOpacity(0.8),borderRadius:BorderRadius.circular(16)),child:const Icon(Icons.delete_outline_rounded,color:Colors.white,size:26)),onDismissed:(_)=>repo.deleteDownload(d.id,deleteFile:true),child:_DownloadItem(d:d,repo:repo));
        });
      },
    );
  }
  Future<List<DownloadEntity>> _get(dynamic repo) async {
    switch(filter){
      case 0:final all=await repo.getCompletedDownloads();return all.where((d)=>d.mediaType==MediaType.video).toList();
      case 1:final all=await repo.getCompletedDownloads();return all.where((d)=>d.mediaType==MediaType.audio).toList();
      case 2:return await repo.getFavorites();
      default:return await repo.getHistory();
    }
  }
}

class _DownloadItem extends StatelessWidget {
  final DownloadEntity d;final dynamic repo;
  const _DownloadItem({required this.d,required this.repo});
  @override
  Widget build(BuildContext context){
    final isDark=Theme.of(context).brightness==Brightness.dark;
    final primary=Theme.of(context).colorScheme.primary;
    return GestureDetector(onTap:(){if(d.filePath!=null)context.go('${AppRoutes.player}?path=${Uri.encodeComponent(d.filePath!)}&title=${Uri.encodeComponent(d.title)}');},child:Container(margin:const EdgeInsets.only(bottom:10),decoration:BoxDecoration(color:isDark?Colors.white.withOpacity(0.05):Colors.white.withOpacity(0.85),borderRadius:BorderRadius.circular(16),border:Border.all(color:isDark?Colors.white10:Colors.black.withOpacity(0.05))),child:Row(children:[
      ClipRRect(borderRadius:const BorderRadius.horizontal(left:Radius.circular(16)),child:SizedBox(width:90,height:70,child:d.thumbnailUrl!=null?CachedNetworkImage(imageUrl:d.thumbnailUrl!,fit:BoxFit.cover,errorWidget:(_,__,___)=>_thumb(isDark)):_thumb(isDark))),
      Expanded(child:Padding(padding:const EdgeInsets.symmetric(horizontal:12,vertical:10),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(d.title,maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:12,fontWeight:FontWeight.w600,color:isDark?Colors.white:Colors.black87,fontFamily:'Poppins',height:1.3)),const SizedBox(height:4),Row(children:[_tag(d.quality,primary),const SizedBox(width:4),_tag(d.format.toUpperCase(),Colors.orange),if(d.fileSize!=null)...[const SizedBox(width:4),_tag(d.fileSizeFormatted,Colors.grey)]])]))),
      Column(mainAxisAlignment:MainAxisAlignment.center,children:[IconButton(icon:Icon(d.isFavorite?Icons.favorite_rounded:Icons.favorite_outline_rounded,size:20,color:d.isFavorite?Colors.red:Colors.grey),onPressed:()=>repo.toggleFavorite(d.id)),Icon(_statusIcon(),size:16,color:_statusColor()),const SizedBox(height:8)]),
    ])).animate().fadeIn().slideX(begin:0.1,end:0));
  }
  Widget _thumb(bool isDark)=>Container(color:isDark?Colors.white10:Colors.grey.shade100,child:Icon(d.mediaType==MediaType.audio?Icons.music_note_rounded:Icons.video_library_rounded,color:Colors.grey,size:28));
  Widget _tag(String l,Color c)=>Container(padding:const EdgeInsets.symmetric(horizontal:5,vertical:2),decoration:BoxDecoration(color:c.withOpacity(0.12),borderRadius:BorderRadius.circular(4)),child:Text(l,style:TextStyle(color:c,fontSize:9,fontWeight:FontWeight.w700,fontFamily:'Poppins')));
  IconData _statusIcon(){switch(d.status){case DownloadStatus.completed:return Icons.check_circle_rounded;case DownloadStatus.running:return Icons.downloading_rounded;case DownloadStatus.paused:return Icons.pause_circle_rounded;case DownloadStatus.failed:return Icons.error_rounded;default:return Icons.schedule_rounded;}}
  Color _statusColor(){switch(d.status){case DownloadStatus.completed:return Colors.green;case DownloadStatus.running:return Colors.blue;case DownloadStatus.paused:return Colors.orange;case DownloadStatus.failed:return Colors.red;default:return Colors.grey;}}
}

class _Empty extends StatelessWidget {
  final int filter;
  const _Empty({required this.filter});
  @override
  Widget build(BuildContext context){
    final isDark=Theme.of(context).brightness==Brightness.dark;
    final data=[('No videos yet','Downloaded videos appear here',Icons.videocam_outlined),('No audio yet','Downloaded audio appears here',Icons.music_note_outlined),('No favorites','Mark downloads as favorite',Icons.favorite_outline_rounded),('No history','Your download history appears here',Icons.history_rounded)][filter];
    return Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Container(width:90,height:90,decoration:BoxDecoration(color:isDark?Colors.white.withOpacity(0.05):Colors.grey.withOpacity(0.1),shape:BoxShape.circle),child:Icon(data.$3,size:44,color:Colors.grey)),const SizedBox(height:16),Text(data.$1,style:Theme.of(context).textTheme.titleMedium?.copyWith(color:isDark?Colors.white54:Colors.black54)),const SizedBox(height:6),Text(data.$2,style:TextStyle(color:isDark?Colors.white30:Colors.black30,fontSize:13,fontFamily:'Poppins'))]).animate().fadeIn(delay:200.ms).scale(begin:const Offset(0.9,0.9)));
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;final bool isDark;
  _TabBarDelegate(this.tabBar,{required this.isDark});
  @override Widget build(BuildContext context,double s,bool o)=>Container(color:isDark?AppTheme.darkBackground:AppTheme.lightBackground,child:tabBar);
  @override double get maxExtent=>tabBar.preferredSize.height+8;
  @override double get minExtent=>tabBar.preferredSize.height+8;
  @override bool shouldRebuild(covariant SliverPersistentHeaderDelegate _)=>true;
}

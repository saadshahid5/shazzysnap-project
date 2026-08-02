import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/download_entity.dart';

class RecentDownloadsSection extends StatelessWidget {
  final List<DownloadEntity> downloads;
  const RecentDownloadsSection({super.key,required this.downloads});
  @override
  Widget build(BuildContext context){
    final isDark=Theme.of(context).brightness==Brightness.dark;
    final primary=Theme.of(context).colorScheme.primary;
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Padding(padding:const EdgeInsets.fromLTRB(20,16,20,12),child:Row(children:[Text('Recent Downloads',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w700)),const Spacer(),GestureDetector(onTap:()=>context.go(AppRoutes.library),child:Text('See all',style:TextStyle(color:primary,fontSize:13,fontWeight:FontWeight.w500,fontFamily:'Poppins')))])),
      SizedBox(height:110,child:ListView.builder(scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:16),itemCount:downloads.length,itemBuilder:(ctx,i){
        final d=downloads[i];
        return GestureDetector(onTap:(){if(d.filePath!=null)ctx.go('${AppRoutes.player}?path=${Uri.encodeComponent(d.filePath!)}&title=${Uri.encodeComponent(d.title)}');},child:Container(width:140,margin:const EdgeInsets.only(right:10),decoration:BoxDecoration(color:isDark?Colors.white.withOpacity(0.05):Colors.white.withOpacity(0.8),borderRadius:BorderRadius.circular(12),border:Border.all(color:isDark?Colors.white10:Colors.black.withOpacity(0.05))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:ClipRRect(borderRadius:const BorderRadius.vertical(top:Radius.circular(12)),child:d.thumbnailUrl!=null?CachedNetworkImage(imageUrl:d.thumbnailUrl!,fit:BoxFit.cover,width:double.infinity,errorWidget:(_,__,___)=>Container(color:isDark?Colors.white10:Colors.grey.shade200,child:const Icon(Icons.video_library,color:Colors.grey))):Container(color:isDark?Colors.white10:Colors.grey.shade200,child:const Icon(Icons.video_library,color:Colors.grey)))),Padding(padding:const EdgeInsets.all(6),child:Text(d.title,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:10,fontWeight:FontWeight.w500,color:isDark?Colors.white70:Colors.black87,fontFamily:'Poppins')))])));
      })),
    ]);
  }
}

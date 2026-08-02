import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/trending_entity.dart';

class TrendingSection extends StatelessWidget {
  final List<TrendingEntity> items;final bool isLoading;
  const TrendingSection({super.key,required this.items,required this.isLoading});
  @override
  Widget build(BuildContext context){
    final isDark=Theme.of(context).brightness==Brightness.dark;
    final primary=Theme.of(context).colorScheme.primary;
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Padding(padding:const EdgeInsets.fromLTRB(20,16,20,12),child:Text('Trending Now',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w700))),
      if(isLoading&&items.isEmpty)
        ListView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),padding:const EdgeInsets.symmetric(horizontal:16),itemCount:5,itemBuilder:(_,__)=>Shimmer.fromColors(baseColor:isDark?Colors.white10:Colors.grey.shade200,highlightColor:isDark?Colors.white24:Colors.grey.shade100,child:Container(margin:const EdgeInsets.only(bottom:12),height:75,decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16)))))
      else
        ListView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),padding:const EdgeInsets.symmetric(horizontal:16),itemCount:items.length,itemBuilder:(ctx,i){
          final item=items[i];
          return GestureDetector(onTap:()=>ctx.go('${AppRoutes.download}?url=${Uri.encodeComponent(item.sourceUrl)}'),child:Container(margin:const EdgeInsets.only(bottom:12),decoration:BoxDecoration(color:isDark?Colors.white.withOpacity(0.05):Colors.white.withOpacity(0.8),borderRadius:BorderRadius.circular(16),border:Border.all(color:isDark?Colors.white10:Colors.black.withOpacity(0.05))),child:Row(children:[
            ClipRRect(borderRadius:const BorderRadius.horizontal(left:Radius.circular(16)),child:Stack(children:[CachedNetworkImage(imageUrl:item.thumbnailUrl,width:110,height:75,fit:BoxFit.cover,errorWidget:(_,__,___)=>Container(width:110,height:75,color:isDark?Colors.white10:Colors.grey.shade200,child:const Icon(Icons.video_library,color:Colors.grey))),if(item.duration!=null)Positioned(bottom:4,right:4,child:Container(padding:const EdgeInsets.symmetric(horizontal:5,vertical:2),decoration:BoxDecoration(color:Colors.black.withOpacity(0.7),borderRadius:BorderRadius.circular(4)),child:Text(item.durationFormatted,style:const TextStyle(color:Colors.white,fontSize:10,fontFamily:'Poppins'))))])),
            Expanded(child:Padding(padding:const EdgeInsets.symmetric(horizontal:12,vertical:8),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(item.title,maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:13,fontWeight:FontWeight.w600,color:isDark?Colors.white:Colors.black87,fontFamily:'Poppins',height:1.3)),const SizedBox(height:4),Row(children:[Container(padding:const EdgeInsets.symmetric(horizontal:6,vertical:2),decoration:BoxDecoration(color:primary.withOpacity(0.15),borderRadius:BorderRadius.circular(4)),child:Text(item.platform,style:TextStyle(color:primary,fontSize:10,fontWeight:FontWeight.w600,fontFamily:'Poppins'))),const SizedBox(width:6),Expanded(child:Text(item.license,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:10,color:isDark?Colors.white38:Colors.black38,fontFamily:'Poppins')))])]))),
            Padding(padding:const EdgeInsets.only(right:12),child:Icon(Icons.download_rounded,color:primary,size:22)),
          ])).animate().fadeIn(delay:Duration(milliseconds:i*60)).slideX(begin:0.1,end:0));
        }),
      if(isLoading&&items.isNotEmpty) const Padding(padding:EdgeInsets.all(16),child:Center(child:CircularProgressIndicator())),
    ]);
  }
}

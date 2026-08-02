import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/video_entity.dart';
import '../../viewmodels/download_viewmodel.dart';

class DownloadScreen extends ConsumerStatefulWidget {
  final String? initialUrl;
  const DownloadScreen({super.key,this.initialUrl});
  @override ConsumerState<DownloadScreen> createState()=>_State();
}
class _State extends ConsumerState<DownloadScreen> {
  final _ctrl=TextEditingController();
  @override void initState(){super.initState();if(widget.initialUrl!=null){_ctrl.text=widget.initialUrl!;WidgetsBinding.instance.addPostFrameCallback((_)=>_analyze(widget.initialUrl!));}}
  @override void dispose(){_ctrl.dispose();super.dispose();}
  void _analyze(String url){if(url.trim().isEmpty)return;ref.read(downloadViewModelProvider.notifier).analyzeUrl(url.trim());}
  @override
  Widget build(BuildContext context){
    final state=ref.watch(downloadViewModelProvider);
    final isDark=Theme.of(context).brightness==Brightness.dark;
    final primary=Theme.of(context).colorScheme.primary;
    return Scaffold(backgroundColor:isDark?AppTheme.darkBackground:AppTheme.lightBackground,body:SafeArea(child:CustomScrollView(physics:const BouncingScrollPhysics(),slivers:[
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(20,16,20,0),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Download',style:Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight:FontWeight.w700)).animate().fadeIn().slideX(begin:-0.2,end:0),Text('Paste URL from authorized platforms only',style:Theme.of(context).textTheme.bodyMedium?.copyWith(color:isDark?Colors.white38:Colors.black38)).animate().fadeIn(delay:100.ms)]))),
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(16,16,16,0),child:Column(children:[
        TextField(controller:_ctrl,onSubmitted:_analyze,decoration:InputDecoration(hintText:'https://pixabay.com/videos/...',prefixIcon:Padding(padding:const EdgeInsets.all(12),child:Icon(Icons.link_rounded,color:primary,size:22)),suffixIcon:Row(mainAxisSize:MainAxisSize.min,children:[if(_ctrl.text.isNotEmpty)IconButton(icon:const Icon(Icons.clear_rounded,size:18),onPressed:(){_ctrl.clear();ref.read(downloadViewModelProvider.notifier).reset();}),IconButton(icon:Icon(Icons.content_paste_rounded,color:primary,size:20),onPressed:()async{final d=await Clipboard.getData(Clipboard.kTextPlain);if(d?.text!=null){_ctrl.text=d!.text!;_analyze(d.text!);}})]),)),
        const SizedBox(height:12),
        SizedBox(width:double.infinity,child:ElevatedButton.icon(onPressed:()=>_analyze(_ctrl.text),icon:const Icon(Icons.search_rounded,size:20),label:const Text('Analyze URL'),style:ElevatedButton.styleFrom(padding:const EdgeInsets.symmetric(vertical:14)))),
      ]).animate().fadeIn(delay:150.ms).slideY(begin:0.2,end:0))),
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(16,16,16,0),child:Wrap(spacing:8,runSpacing:6,children:[for(final p in['Pixabay','Pexels','Archive.org','ccMixter','Mixkit','Jamendo'])Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:4),decoration:BoxDecoration(color:isDark?Colors.white.withOpacity(0.06):Colors.grey.withOpacity(0.1),borderRadius:BorderRadius.circular(8),border:Border.all(color:isDark?Colors.white10:Colors.black.withOpacity(0.07))),child:Text(p,style:TextStyle(fontSize:11,color:isDark?Colors.white54:Colors.black54,fontFamily:'Poppins')))]).animate().fadeIn(delay:200.ms))),
      SliverFillRemaining(hasScrollBody:false,child:_buildBody(state,isDark,primary)),
    ])));
  }
  Widget _buildBody(DownloadState state,bool isDark,Color primary){
    if(state is DownloadInitial) return Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[const SizedBox(height:40),Icon(Icons.cloud_download_outlined,size:64,color:isDark?Colors.white24:Colors.black26),const SizedBox(height:16),Text('Paste a URL to get started',style:TextStyle(color:isDark?Colors.white38:Colors.black38,fontSize:15,fontFamily:'Poppins'))]).animate().fadeIn(delay:300.ms));
    if(state is DownloadAnalyzing) return Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[SizedBox(width:60,height:60,child:CircularProgressIndicator(strokeWidth:3,color:primary)).animate(onPlay:(c)=>c.repeat()).rotate(duration:1000.ms),const SizedBox(height:24),const Text('Analyzing URL...',style:TextStyle(fontSize:16,fontWeight:FontWeight.w500,fontFamily:'Poppins'))]).animate().fadeIn());
    if(state is DownloadError) return Center(child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Container(width:80,height:80,decoration:BoxDecoration(color:Colors.red.withOpacity(0.1),shape:BoxShape.circle),child:const Icon(Icons.error_outline_rounded,color:Colors.red,size:40)),const SizedBox(height:20),const Text('Oops! Something went wrong',style:TextStyle(fontSize:17,fontWeight:FontWeight.w600,fontFamily:'Poppins')),const SizedBox(height:10),Text(state.message,textAlign:TextAlign.center,style:TextStyle(color:isDark?Colors.white54:Colors.black54,fontSize:13,fontFamily:'Poppins',height:1.5)),const SizedBox(height:24),ElevatedButton.icon(onPressed:()=>_analyze(_ctrl.text),icon:const Icon(Icons.refresh_rounded),label:const Text('Try Again'))]).animate().fadeIn().scale(begin:const Offset(0.9,0.9))));
    if(state is DownloadAnalyzed) return _AnalyzedView(state:state);
    if(state is DownloadInProgress) return _ProgressView(state:state,isDark:isDark,primary:primary);
    return const SizedBox.shrink();
  }
}

class _AnalyzedView extends ConsumerWidget {
  final DownloadAnalyzed state;
  const _AnalyzedView({required this.state});
  @override
  Widget build(BuildContext context,WidgetRef ref){
    final isDark=Theme.of(context).brightness==Brightness.dark;
    final primary=Theme.of(context).colorScheme.primary;
    final v=state.video;
    return Padding(padding:const EdgeInsets.fromLTRB(16,16,16,20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      // Video info card
      Container(decoration:BoxDecoration(color:isDark?Colors.white.withOpacity(0.05):Colors.white,borderRadius:BorderRadius.circular(20),border:Border.all(color:isDark?Colors.white10:Colors.black.withOpacity(0.06))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        if(v.thumbnailUrl!=null)ClipRRect(borderRadius:const BorderRadius.vertical(top:Radius.circular(20)),child:Stack(children:[CachedNetworkImage(imageUrl:v.thumbnailUrl!,width:double.infinity,height:180,fit:BoxFit.cover,errorWidget:(_,__,___)=>Container(height:180,color:isDark?Colors.white10:Colors.grey.shade100,child:const Icon(Icons.video_library,size:48))),Positioned(top:10,left:10,child:Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),decoration:BoxDecoration(color:primary.withOpacity(0.9),borderRadius:BorderRadius.circular(6)),child:Text(v.platform.toUpperCase(),style:const TextStyle(color:Colors.white,fontSize:10,fontWeight:FontWeight.w700,fontFamily:'Poppins',letterSpacing:0.5)))),if(v.duration!=null)Positioned(bottom:10,right:10,child:Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),decoration:BoxDecoration(color:Colors.black.withOpacity(0.75),borderRadius:BorderRadius.circular(6)),child:Text(_fmt(v.duration!),style:const TextStyle(color:Colors.white,fontSize:12,fontFamily:'Poppins'))))])),
        Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(v.title,maxLines:2,overflow:TextOverflow.ellipsis,style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w600)),if(v.author!=null)...[const SizedBox(height:4),Text(v.author!,style:TextStyle(color:isDark?Colors.white54:Colors.black54,fontSize:12,fontFamily:'Poppins'))],const SizedBox(height:10),Row(children:[_chip(Icons.movie_outlined,'${v.formats.length} formats',primary),const SizedBox(width:8),_chip(Icons.verified_outlined,'Authorized',Colors.green)])]))
      ])),
      const SizedBox(height:20),
      Text('Select Quality & Format',style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w700)),
      const SizedBox(height:12),
      ...v.formats.asMap().entries.map((e){
        final f=e.value;final sel=state.selectedFormat?.id==f.id;
        return GestureDetector(onTap:()=>ref.read(downloadViewModelProvider.notifier).selectFormat(f),child:AnimatedContainer(duration:const Duration(milliseconds:200),margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:sel?primary.withOpacity(0.12):isDark?Colors.white.withOpacity(0.04):Colors.grey.withOpacity(0.06),borderRadius:BorderRadius.circular(14),border:Border.all(color:sel?primary:Colors.transparent,width:1.5)),child:Row(children:[Container(width:58,padding:const EdgeInsets.symmetric(vertical:6),decoration:BoxDecoration(color:sel?primary:primary.withOpacity(0.15),borderRadius:BorderRadius.circular(8)),alignment:Alignment.center,child:Text(f.quality,style:TextStyle(color:sel?Colors.white:primary,fontSize:12,fontWeight:FontWeight.w700,fontFamily:'Poppins'))),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(f.displayQuality,style:TextStyle(fontSize:13,fontWeight:FontWeight.w600,color:isDark?Colors.white:Colors.black87,fontFamily:'Poppins')),if(f.codec!=null)Text(f.codec!,style:TextStyle(fontSize:11,color:isDark?Colors.white38:Colors.black38,fontFamily:'Poppins'))])),Text(f.fileSizeFormatted,style:TextStyle(fontSize:12,fontWeight:FontWeight.w600,color:isDark?Colors.white70:Colors.black70,fontFamily:'Poppins'))])).animate().fadeIn(delay:Duration(milliseconds:e.key*50)));
      }),
      const SizedBox(height:20),
      SizedBox(width:double.infinity,child:ElevatedButton.icon(onPressed:state.selectedFormat!=null?()=>ref.read(downloadViewModelProvider.notifier).startDownload():null,icon:const Icon(Icons.download_rounded,size:22),label:Text(state.selectedFormat!=null?'Download ${state.selectedFormat!.quality}':'Select a format first',style:const TextStyle(fontSize:16,fontWeight:FontWeight.w600,fontFamily:'Poppins')),style:ElevatedButton.styleFrom(padding:const EdgeInsets.symmetric(vertical:16),backgroundColor:state.selectedFormat!=null?primary:Colors.grey))).animate().fadeIn(delay:400.ms).slideY(begin:0.3,end:0),
      const SizedBox(height:10),
      Center(child:Text('✓ Only authorized content is downloaded',style:TextStyle(color:Colors.green.shade400,fontSize:11,fontFamily:'Poppins'))),
    ]).animate().fadeIn(delay:200.ms));
  }
  Widget _chip(IconData icon,String label,Color color)=>Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),decoration:BoxDecoration(color:color.withOpacity(0.12),borderRadius:BorderRadius.circular(6)),child:Row(mainAxisSize:MainAxisSize.min,children:[Icon(icon,size:12,color:color),const SizedBox(width:4),Text(label,style:TextStyle(color:color,fontSize:11,fontWeight:FontWeight.w600,fontFamily:'Poppins'))]));
  String _fmt(Duration d){final h=d.inHours;final m=d.inMinutes.remainder(60);final s=d.inSeconds.remainder(60);if(h>0)return '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';}
}

class _ProgressView extends StatelessWidget {
  final DownloadInProgress state;final bool isDark;final Color primary;
  const _ProgressView({required this.state,required this.isDark,required this.primary});
  @override
  Widget build(BuildContext context){
    final d=state.download;
    return Padding(padding:const EdgeInsets.all(16),child:Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:isDark?Colors.white.withOpacity(0.05):Colors.white,borderRadius:BorderRadius.circular(20),border:Border.all(color:isDark?Colors.white10:Colors.black.withOpacity(0.06))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[Container(width:44,height:44,decoration:BoxDecoration(color:primary.withOpacity(0.15),borderRadius:BorderRadius.circular(12)),child:Icon(Icons.downloading_rounded,color:primary,size:22)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(d.title,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:14,fontWeight:FontWeight.w600,color:isDark?Colors.white:Colors.black87,fontFamily:'Poppins')),Text('${d.quality} • ${d.format.toUpperCase()}',style:TextStyle(fontSize:11,color:isDark?Colors.white38:Colors.black38,fontFamily:'Poppins'))]))]),
      const SizedBox(height:20),
      LinearPercentIndicator(percent:d.progress.clamp(0.0,1.0),lineHeight:8,backgroundColor:isDark?Colors.white12:Colors.grey.shade200,progressColor:primary,barRadius:const Radius.circular(4),padding:EdgeInsets.zero,animation:false),
      const SizedBox(height:10),
      Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(d.statusLabel,style:TextStyle(fontSize:12,color:primary,fontWeight:FontWeight.w600,fontFamily:'Poppins')),if(d.fileSize!=null)Text(d.fileSizeFormatted,style:TextStyle(fontSize:12,color:isDark?Colors.white38:Colors.black38,fontFamily:'Poppins'))]),
    ])).animate().fadeIn().slideY(begin:0.2,end:0));
  }
}

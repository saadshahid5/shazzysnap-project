import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class PlayerScreen extends StatefulWidget {
  final String filePath,title;
  const PlayerScreen({super.key,required this.filePath,required this.title});
  @override State<PlayerScreen> createState()=>_State();
}
class _State extends State<PlayerScreen> {
  VideoPlayerController? _video;
  ChewieController? _chewie;
  bool _ready=false;
  String? _error;
  @override void initState(){super.initState();_init();SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.landscapeLeft,DeviceOrientation.landscapeRight]);}
  Future<void> _init() async {
    try {
      _video=VideoPlayerController.file(File(widget.filePath));
      await _video!.initialize();
      _chewie=ChewieController(videoPlayerController:_video!,autoPlay:true,looping:false,allowFullScreen:true,allowMuting:true,materialProgressColors:ChewieProgressColors(playedColor:Theme.of(context).colorScheme.primary,handleColor:Theme.of(context).colorScheme.primary,bufferedColor:Colors.white30,backgroundColor:Colors.white12));
      if(mounted) setState(()=>_ready=true);
    } catch(e){if(mounted) setState(()=>_error='Cannot play file: $e');}
  }
  @override void dispose(){_video?.dispose();_chewie?.dispose();SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);super.dispose();}
  @override
  Widget build(BuildContext context)=>Scaffold(backgroundColor:Colors.black,appBar:AppBar(backgroundColor:Colors.black,foregroundColor:Colors.white,title:Text(widget.title,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:15,fontFamily:'Poppins')),actions:[IconButton(icon:const Icon(Icons.share_rounded),onPressed:(){})]),body:Center(child:_error!=null?Column(mainAxisAlignment:MainAxisAlignment.center,children:[const Icon(Icons.error_outline,color:Colors.red,size:60),const SizedBox(height:16),Text(_error!,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white70,fontFamily:'Poppins')),const SizedBox(height:20),ElevatedButton(onPressed:()=>Navigator.pop(context),child:const Text('Go Back'))]):_ready?Chewie(controller:_chewie!):const CircularProgressIndicator(color:Colors.white)));
}

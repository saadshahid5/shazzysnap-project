import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection_container.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/download_entity.dart';
import '../../domain/entities/trending_entity.dart';
import '../../domain/repositories/download_repository.dart';
import '../../domain/repositories/video_repository.dart';

class HomeState {
  final List<TrendingEntity> trendingItems, searchResults, favorites;
  final List<DownloadEntity> recentDownloads;
  final bool isTrendingLoading, isSearching, isRecentLoading;
  final String? error, selectedCategory;
  final String searchQuery;
  final int trendingPage;
  final bool hasMoreTrending;
  const HomeState({this.trendingItems=const[],this.recentDownloads=const[],this.favorites=const[],this.searchResults=const[],this.isTrendingLoading=false,this.isSearching=false,this.isRecentLoading=false,this.error,this.searchQuery='',this.selectedCategory,this.trendingPage=1,this.hasMoreTrending=true});
  HomeState copyWith({List<TrendingEntity>? trendingItems,List<DownloadEntity>? recentDownloads,List<TrendingEntity>? favorites,List<TrendingEntity>? searchResults,bool? isTrendingLoading,bool? isSearching,bool? isRecentLoading,String? error,String? searchQuery,String? selectedCategory,int? trendingPage,bool? hasMoreTrending}) => HomeState(trendingItems:trendingItems??this.trendingItems,recentDownloads:recentDownloads??this.recentDownloads,favorites:favorites as List<TrendingEntity>??this.favorites,searchResults:searchResults??this.searchResults,isTrendingLoading:isTrendingLoading??this.isTrendingLoading,isSearching:isSearching??this.isSearching,isRecentLoading:isRecentLoading??this.isRecentLoading,error:error,searchQuery:searchQuery??this.searchQuery,selectedCategory:selectedCategory??this.selectedCategory,trendingPage:trendingPage??this.trendingPage,hasMoreTrending:hasMoreTrending??this.hasMoreTrending);
}

class HomeViewModel extends StateNotifier<HomeState> {
  final VideoRepository _videoRepo;
  final DownloadRepository _downloadRepo;
  HomeViewModel(this._videoRepo,this._downloadRepo):super(const HomeState()){ _load(); }
  Future<void> _load() async { await Future.wait([loadTrending(refresh:true),loadRecent()]); }
  Future<void> loadTrending({bool refresh=false}) async {
    if(state.isTrendingLoading) return;
    final page=refresh?1:state.trendingPage;
    state=state.copyWith(isTrendingLoading:true,trendingPage:page,trendingItems:refresh?[]:state.trendingItems);
    try {
      final items=await _videoRepo.getTrending(page:page,category:state.selectedCategory);
      state=state.copyWith(trendingItems:refresh?items:[...state.trendingItems,...items],isTrendingLoading:false,trendingPage:page+1,hasMoreTrending:items.isNotEmpty);
    } catch(_) { state=state.copyWith(isTrendingLoading:false,trendingItems:refresh?_mock():state.trendingItems); }
  }
  Future<void> loadRecent() async {
    try { final d=await _downloadRepo.getHistory(limit:10); state=state.copyWith(recentDownloads:d); } catch(_) {}
  }
  Future<void> search(String q) async {
    if(q.isEmpty){state=state.copyWith(searchQuery:'',searchResults:[],isSearching:false);return;}
    state=state.copyWith(searchQuery:q,isSearching:true);
    try { final r=await _videoRepo.search(q); state=state.copyWith(searchResults:r,isSearching:false); }
    catch(_) { state=state.copyWith(isSearching:false); }
  }
  void selectCategory(String? c) { state=state.copyWith(selectedCategory:c); loadTrending(refresh:true); }
  void clearError() => state=state.copyWith(error:null);
  List<TrendingEntity> _mock() => [
    TrendingEntity(id:'1',title:'Beautiful Nature Timelapse - Free Stock',thumbnailUrl:'https://images.pexels.com/photos/417074/pexels-photo-417074.jpeg',sourceUrl:'https://pixabay.com/videos/nature-1/',platform:'Pixabay',author:'NatureFilms',viewCount:125000,duration:const Duration(minutes:12,seconds:34),category:'Nature',publishedAt:DateTime.now().subtract(const Duration(days:3)),isDownloadable:true,license:'Pixabay License'),
    TrendingEntity(id:'2',title:'City Night Time-lapse 4K',thumbnailUrl:'https://images.pexels.com/photos/1707820/pexels-photo-1707820.jpeg',sourceUrl:'https://pixabay.com/videos/city-2/',platform:'Pixabay',author:'UrbanLens',viewCount:89000,duration:const Duration(minutes:3,seconds:45),category:'Travel',publishedAt:DateTime.now().subtract(const Duration(days:1)),isDownloadable:true,license:'Pixabay License'),
    TrendingEntity(id:'3',title:'Relaxing Ocean Ambient Music - CC',thumbnailUrl:'https://images.pexels.com/photos/1001682/pexels-photo-1001682.jpeg',sourceUrl:'https://freemusicarchive.org/music/ocean',platform:'Free Music Archive',author:'AmbientSounds',viewCount:234000,duration:const Duration(minutes:45),category:'Music',publishedAt:DateTime.now().subtract(const Duration(days:7)),isDownloadable:true,license:'CC BY 4.0'),
    TrendingEntity(id:'4',title:'Abstract Motion Graphics Pack',thumbnailUrl:'https://images.pexels.com/photos/3075993/pexels-photo-3075993.jpeg',sourceUrl:'https://mixkit.co/free-stock-video/abstract-1/',platform:'Mixkit',author:'MotionDesign',viewCount:67000,duration:const Duration(seconds:30),category:'Design',publishedAt:DateTime.now().subtract(const Duration(days:2)),isDownloadable:true,license:'Mixkit License'),
    TrendingEntity(id:'5',title:'Epic Orchestral Score - Creative Commons',thumbnailUrl:'https://images.pexels.com/photos/164745/pexels-photo-164745.jpeg',sourceUrl:'https://ccmixter.org/files/epic-1',platform:'ccMixter',author:'OrchestraPro',viewCount:156000,duration:const Duration(minutes:4,seconds:12),category:'Music',publishedAt:DateTime.now().subtract(const Duration(days:5)),isDownloadable:true,license:'CC BY 3.0'),
    TrendingEntity(id:'6',title:'Mountain Drone Footage 4K',thumbnailUrl:'https://images.pexels.com/photos/417173/pexels-photo-417173.jpeg',sourceUrl:'https://coverr.co/videos/mountains-1',platform:'Coverr',author:'AerialVision',viewCount:198000,duration:const Duration(minutes:6,seconds:28),category:'Travel',publishedAt:DateTime.now().subtract(const Duration(days:4)),isDownloadable:true,license:'Coverr License'),
  ];
}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel,HomeState>((ref) => HomeViewModel(ref.watch(videoRepositoryProvider),ref.watch(downloadRepositoryProvider)));

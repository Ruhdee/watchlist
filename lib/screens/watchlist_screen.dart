import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watchlist/data/api_service.dart';
import 'package:watchlist/data/movie_model.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  List<int> items = List<int>.generate(20, (int index) => index);
  List<Movie> moviesList = [];
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollProgress);
    loadMoviesList();
  }

  void _updateScrollProgress() {
    if (_scrollController.hasClients) {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      setState(() {
        _scrollProgress = maxScroll > 0
            ? (currentScroll / maxScroll).clamp(0.0, 1.0)
            : 0.0;
      });
    }
  }

  void loadMovie() async {
    while (true) {
      try {
        var result = await apiService.getJson('movie/559');
        print('Success: $result');

        break; // Exit loop on success
      } catch (e) {
        print('Failed to fetch data, retrying... Error: $e');
        await Future.delayed(
          Duration(milliseconds: 2),
        ); // Wait 2 seconds before retry
      }
    }
  }

  Future<void> loadMoviesList() async {
    while (true) {
      try {
        var result = await apiService.getJson('movie/559');
        setState(() {
          moviesList.add(Movie.fromJson(result));
        });
        print('Success: $result');
        break;
      } catch (e) {
        print('Failed to fetch data, retrying... Error: $e');
        await Future.delayed(Duration(milliseconds: 2));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Stack(
            children: [
              AppBar(
                title: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'WATCHLIST',
                    style: TextStyle(color: Colors.white, fontSize: 32),
                  ),
                ),
                actions: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.search)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.tune)),
                ],
                backgroundColor: Colors.black,
              ),
              Positioned(
                top: 0,
                left: 32,
                child: Container(
                  height: 3,
                  width: MediaQuery.of(context).size.width * _scrollProgress,
                  decoration: BoxDecoration(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        body: ListView.builder(
          controller: _scrollController,
          itemCount: moviesList.length,
          itemBuilder: (context, index) => Dismissible(
            key: ValueKey(moviesList[index]),
            onDismissed: (DismissDirection direction) {
              setState(() {
                moviesList.removeAt(index);
              });
            },
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    apiService.getImageUrl(moviesList[index].backdropPath),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(0),
                minTileHeight: 100,
                title: Row(children: [Text(moviesList[index].title)]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

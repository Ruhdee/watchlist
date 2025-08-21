import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watchlist/data/api_service.dart';
import 'package:watchlist/data/movie_model.dart';
import 'package:watchlist/screens/search_screen.dart';

import '../data/movie_storage.dart';

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
    loadMoviesFromStorage();
  }

  Future<void> loadMoviesFromStorage() async {
    // First, load from local storage for instant display
    final cachedMovies = await MovieStorage.loadMovies();
    if (cachedMovies.isNotEmpty) {
      setState(() {
        moviesList = cachedMovies;
      });
    }
  }

  void removeMovie(int index) async {
    setState(() {
      moviesList.removeAt(index);
    });
    await MovieStorage.saveMovies(moviesList); // Update storage
  }

  Future<void> addMovie(String endpoint) async {
    while (true) {
      try {
        var result = await apiService.getJson(endpoint);
        Movie resultMovie = Movie.fromJson(result);

        setState(() {
          moviesList.add(resultMovie);
        });
        print('Success: $result');
        break;
      } catch (e) {
        print('Failed to fetch data, retrying... Error: $e');
        await Future.delayed(Duration(milliseconds: 2));
      }
    }
    await MovieStorage.saveMovies(moviesList); // Update storage
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SearchScreen(onMovieSelected: addMovie),
                        ),
                      );
                    },
                    icon: Icon(Icons.search, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.tune, color: Colors.white),
                  ),
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
                removeMovie(index);
              });
            },
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    apiService.getImageUrl(
                      moviesList[index].backdropPath ?? '',
                    ),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(0),
                minTileHeight: 200,
                title: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moviesList[index].title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                              offset: Offset(0.5, 0.5),
                              blurRadius: 2,
                              color: Colors.black.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        moviesList[index].releaseDate!.substring(0, 4),
                        style: TextStyle(
                          shadows: [
                            Shadow(
                              offset: Offset(0.5, 0.5),
                              blurRadius: 2,
                              color: Colors.black.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Color(0xffD3D3D3),
                            size: 14,
                            shadows: [
                              Shadow(
                                offset: Offset(0.5, 0.5),
                                blurRadius: 2,
                                color: Colors.black.withValues(alpha: 0.7),
                              ),
                            ],
                          ),
                          Text(
                            moviesList[index].runtime.toString(),
                            style: TextStyle(
                              color: Color(0xffD3D3D3),
                              fontSize: 14,
                              shadows: [
                                Shadow(
                                  offset: Offset(0.5, 0.5),
                                  blurRadius: 2,
                                  color: Colors.black.withValues(alpha: 0.7),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${moviesList[index].genres![0].name}, ${moviesList[index].genres![1].name}',
                        style: TextStyle(
                          color: Color(0xffD3D3D3),
                          fontSize: 14,
                          shadows: [
                            Shadow(
                              offset: Offset(0.5, 0.5),
                              blurRadius: 2,
                              color: Colors.black.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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

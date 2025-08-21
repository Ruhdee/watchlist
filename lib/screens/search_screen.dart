import 'package:flutter/material.dart';
import 'package:watchlist/data/api_service.dart';

import '../data/movie_model.dart';

class SearchScreen extends StatefulWidget {
  final Function(String) onMovieSelected;

  const SearchScreen({super.key, required this.onMovieSelected});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  ApiService apiService = ApiService();
  List<Movie> searchMoviesList = [];
  String _lastQuery = '';

  Future<void> searchMovies(String query) async {
    while (true) {
      try {
        var result = await apiService.getJson(
          'search/movie?query=$query&include_adult=false',
        );
        for (int i = 0; i < 20; i++) {
          setState(() {
            searchMoviesList.add(Movie.searchFromJson(result['results'][i]));
          });
        }
        print('Success: $result');
        break;
      } catch (e) {
        print('Failed to fetch data, retrying... Error: $e');
        await Future.delayed(Duration(milliseconds: 2));
      }
    }
  }

  void searchChangeListener() {
    String currentQuery = _searchController.text.trim();

    // Only search if the query actually changed
    if (currentQuery != _lastQuery) {
      _lastQuery = currentQuery;

      setState(() {
        searchMoviesList.clear();
      });

      if (currentQuery.isNotEmpty) {
        searchMovies(currentQuery);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _searchController.addListener(searchChangeListener);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Column(
            children: [
              TextField(controller: _searchController),
              Expanded(
                child: ListView.builder(
                  itemCount: searchMoviesList.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      String movieEndpoint =
                          'movie/${searchMoviesList[index].id}';
                      widget.onMovieSelected(movieEndpoint);
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          height: 100,
                          width: 67,
                          child: Image.network(
                            apiService.getImageUrl(
                              searchMoviesList[index].posterPath ?? '',
                              size: 'w92',
                            ),
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[800],
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey,
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            searchMoviesList[index].title,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(
      searchChangeListener,
    ); // Remove listener first
    _searchController.dispose();
    super.dispose();
  }
}

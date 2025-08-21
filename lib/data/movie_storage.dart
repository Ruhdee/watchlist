import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:watchlist/data/movie_model.dart';

class MovieStorage {
  static const String _moviesKey = 'movies_list';

  // Save movies list to local storage
  static Future<void> saveMovies(List<Movie> movies) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert movies to JSON strings
    List<String> moviesJson = movies
        .map((movie) => jsonEncode(movie.toJson()))
        .toList();

    await prefs.setStringList(_moviesKey, moviesJson);
  }

  // Load movies list from local storage
  static Future<List<Movie>> loadMovies() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? moviesJson = prefs.getStringList(_moviesKey);

    if (moviesJson == null) return [];

    return moviesJson
        .map((movieStr) => Movie.fromJson(jsonDecode(movieStr)))
        .toList();
  }

  // Clear saved movies
  static Future<void> clearMovies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_moviesKey);
  }
}

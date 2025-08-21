class Movie {
  final int id;
  final int runtime;
  final String title;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final List<Genre> genres;

  Movie({
    required this.id,
    required this.runtime,
    required this.title,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.genres,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      runtime: json['runtime'],
      title: json['title'],
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      releaseDate: json['release_date'] ?? 'Unknown',
      genres: (json['genres'] as List).map((g) => Genre.fromJson(g)).toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'runtime': runtime,
      'release_date': releaseDate,
      'genres': genres.map((genre) => genre.toJson()).toList(),
    };
  }
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(id: json['id'], name: json['name']);
  }
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

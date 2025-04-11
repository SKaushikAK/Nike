/// For this create a file assets/movies.json seperately in the and 
/// save this content there
/// [
//   {
//     "title": "Inception",
//     "genre": "Sci-Fi",
//     "rating": 4.5,
//     "description": "A mind-bending thriller by Christopher Nolan.",
//     "imageUrl": "https://image.tmdb.org/t/p/w500/qmDpIHrmpJINaRKAfWQfftjCdyi.jpg"
//   },
//   {
//     "title": "Interstellar",
//     "genre": "Adventure",
//     "rating": 4.8,
//     "description": "A space exploration journey beyond time.",
//     "imageUrl": "https://image.tmdb.org/t/p/w500/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg"
//   },
//   {
//     "title": "The Dark Knight",
//     "genre": "Action",
//     "rating": 4.9,
//     "description": "The legendary Batman faces off against Joker.",
//     "imageUrl": "https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg"
//   }
// ]
///
///update the pubspec.yaml
///
/// flutter:
///     assets:
///     assets/movies.json
///
///Now run the app

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MovieRatingApp());
}

class MovieRatingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Rating App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: MovieCatalog(),
    );
  }
}

class MovieCatalog extends StatefulWidget {
  @override
  _MovieCatalogState createState() => _MovieCatalogState();
}

class _MovieCatalogState extends State<MovieCatalog> {
  List<Map<String, dynamic>> movies = [];

  @override
  void initState() {
    super.initState();
    loadMovies();
  }

  Future<File> getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/movies.json');
  }

  Future<void> loadMovies() async {
    final file = await getLocalFile();

    if (await file.exists()) {
      final contents = await file.readAsString();
      setState(() {
        movies = List<Map<String, dynamic>>.from(json.decode(contents));
      });
    } else {
      // Load from assets on first run
      final assetData =
          await DefaultAssetBundle.of(context).loadString('assets/movies.json');
      await file.writeAsString(assetData);
      setState(() {
        movies = List<Map<String, dynamic>>.from(json.decode(assetData));
      });
    }
  }

  Future<void> updateRating(int index, double newRating) async {
    movies[index]['rating'] = newRating;
    final file = await getLocalFile();
    await file.writeAsString(json.encode(movies));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Movie Catalog')),
      body: movies.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: Image.network(movie['imageUrl'],
                        width: 50, height: 80, fit: BoxFit.cover),
                    title: Text(movie['title']),
                    subtitle: Text("Genre: ${movie['genre']}"),
                    trailing: RatingBarIndicator(
                      rating: movie['rating']?.toDouble() ?? 0,
                      itemBuilder: (context, _) =>
                          Icon(Icons.star, color: Colors.amber),
                      itemCount: 5,
                      itemSize: 20.0,
                    ),
                    onTap: () async {
                      final updatedRating = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetail(
                            movie: movie,
                            index: index,
                            onRatingChanged: updateRating,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class MovieDetail extends StatefulWidget {
  final Map<String, dynamic> movie;
  final int index;
  final Function(int, double) onRatingChanged;

  const MovieDetail({
    required this.movie,
    required this.index,
    required this.onRatingChanged,
  });

  @override
  _MovieDetailState createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  late double selectedRating;

  @override
  void initState() {
    super.initState();
    selectedRating = widget.movie['rating']?.toDouble() ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(widget.movie['imageUrl'], height: 200),
            ),
            SizedBox(height: 20),
            Text("Genre: ${widget.movie['genre']}",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Description: ${widget.movie['description']}",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 30),
            Text("Your Rating:", style: TextStyle(fontSize: 18)),
            RatingBar.builder(
              initialRating: selectedRating,
              minRating: 1,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 32.0,
              glow: false,
              itemBuilder: (context, _) =>
                  Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  selectedRating = rating;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onRatingChanged(widget.index, selectedRating);
                Navigator.pop(context);
              },
              child: Text("Submit Review"),
            )
          ],
        ),
      ),
    );
  }
}

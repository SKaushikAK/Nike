import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
  List<Map<String, dynamic>> movies = [
    {
      'title': 'Inception',
      'genre': 'Sci-Fi',
      'rating': 4.5,
      'description': 'A mind-bending thriller by Christopher Nolan.',
      'imageUrl':
          'https://m.media-amazon.com/images/M/MV5BMjAxMzY3NjcxNF5BMl5BanBnXkFtZTcwNTI5OTM0Mw@@._V1_FMjpg_UX1000_.jpg'
    },
    {
      'title': 'Interstellar',
      'genre': 'Adventure',
      'rating': 4.8,
      'description': 'A space exploration journey beyond time.',
      'imageUrl':
          'https://m.media-amazon.com/images/M/MV5BYzdjMDAxZGItMjI2My00ODA1LTlkNzItOWFjMDU5ZDJlYWY3XkEyXkFqcGc@._V1_.jpg'
    },
    {
      'title': 'The Dark Knight',
      'genre': 'Action',
      'rating': 4.9,
      'description': 'The legendary Batman faces off against Joker.',
      'imageUrl':
          'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg'
    },
  ];

  void updateRating(int index, double newRating) {
    setState(() {
      movies[index]['rating'] = newRating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Movie Catalog')),
      body: ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              leading: Image.network(
                movie['imageUrl'],
                width: 50,
                height: 80,
                fit: BoxFit.cover,
              ),
              title: Text(movie['title']),
              subtitle: Text("Genre: ${movie['genre']}"),
              trailing: RatingBarIndicator(
                rating: movie['rating'],
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
                      currentRating: movie['rating'],
                    ),
                  ),
                );

                if (updatedRating != null) {
                  updateRating(index, updatedRating);
                }
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
  final double currentRating;

  const MovieDetail({
    super.key,
    required this.movie,
    required this.index,
    required this.currentRating,
  });

  @override
  _MovieDetailState createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  double? selectedRating;

  @override
  void initState() {
    super.initState();
    selectedRating = widget.currentRating;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie['title']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie poster
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.movie['imageUrl'],
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Description: ${widget.movie['description']}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 30),
              Text("Your Rating:", style: TextStyle(fontSize: 18)),
              RatingBar.builder(
                initialRating: selectedRating!,
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
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, selectedRating);
                  },
                  child: Text("Submit Review"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

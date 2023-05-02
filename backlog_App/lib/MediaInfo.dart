import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MediaInformationScreen extends StatelessWidget {
  final String title;
  final String releaseDate;
  final String overview;
  final String imageUrl;
  final String tvID;
  final String numberOfEpisodes;
  final String numberOfSeasons;
  MediaInformationScreen({super.key,
    required this.title,
    required this.releaseDate,
    required this.overview,
    required this.imageUrl,
    required this.tvID,
    required this.numberOfEpisodes,
    required this.numberOfSeasons
  });
  final databaseRef = FirebaseDatabase.instance.ref("Users/${FirebaseAuth.instance.currentUser!.uid}/Lists");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner image
          Image.network(
            imageUrl,
            height: 300,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace){
              return Container(
                color: Colors.grey,
                alignment: Alignment.center,
                child: const Text('No Image Found', style: TextStyle(fontSize: 10),),
              );
            },
          ),
          // Release date
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Release Date: $releaseDate',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Overview
          Flexible(
            child: Text(
              overview,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          // Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    DatabaseReference databaseRefCheck = FirebaseDatabase.instance.ref("Users/${FirebaseAuth.instance.currentUser!.uid}/Lists");
                    String iD = DateTime.now().millisecondsSinceEpoch.toString(); //getting this now to be safe since somehow when creating one i ran into an issue of the IDs being off by 1 (i don't know)
                    databaseRef.child(iD).set({
                      'Title' : title,
                      'id' : iD,
                      'imgURL' : "https://image.tmdb.org/t/p/w500$imageUrl",
                      'onEpisode': 1,
                      'tvID': tvID,
                      'numberOfEpisodes' : numberOfEpisodes,
                      'numberOfSeasons' : numberOfSeasons,
                      'releaseDate' : releaseDate,
                      'overview': overview
                    });
                    int count = 0;
                    Navigator.popUntil(context, (route) {
                      return count++ == 2;
                    });
                  },
                  child: const Text('Add to list'),
                ),
              ),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

  }
}

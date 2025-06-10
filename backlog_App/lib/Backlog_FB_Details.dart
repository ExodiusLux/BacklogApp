import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
class MediaInformationScreen extends StatefulWidget {
  final String title;
  final String releaseDate;
  final String overview;
  final String imgURL;
  final String numberOfEpisodes;
  final String numberOfSeasons;
  final String onEpisode;
  final String tvID;
  final String iD;

  const MediaInformationScreen({super.key,
    required this.title,
    required this.releaseDate,
    required this.overview,
    required this.imgURL,
    required this.numberOfEpisodes,
    required this.numberOfSeasons,
    required this.onEpisode,
    required this.tvID,
    required this.iD
  });

  @override
  _MediaInformationScreenState createState() => _MediaInformationScreenState();
}

class _MediaInformationScreenState extends State<MediaInformationScreen> {
  late int _currentEpisode;
  final databaseRef = FirebaseDatabase.instance.ref("Users/${FirebaseAuth.instance.currentUser!.uid}/Lists");
  final apiKey = Platform.environment['TMDB_API_KEY'];
  Future<Map<String,dynamic>> getEpisodeInfoNew() async{
    Map<String, dynamic> allEpisodesData = {};
    List<dynamic> episodes = [];
    for (int seasonNumber = 1; seasonNumber <= int.parse(widget.numberOfSeasons); seasonNumber++) {
      final response = await http.get(Uri.parse("https://api.themoviedb.org/3/tv/${widget.tvID}/season/$seasonNumber?api_key=$apiKey&language=en-US"));
      if (response.statusCode == 200) {
        Map<String, dynamic> seasonData = json.decode(response.body);
        episodes.addAll(seasonData["episodes"]) ;

      } else {
        throw Exception('Failed to fetch episodes');
      }
    }
    allEpisodesData["episodes"] = episodes;
    return allEpisodesData;
  }



  @override
  void initState() {
    super.initState();
    getEpisodeInfoNew();
    _currentEpisode = int.parse(widget.onEpisode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top banner
          Container(
            height: 300,
            color: Colors.blue,
            child:Image.network(
              widget.imgURL,
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
          ),
          // Title section
          SizedBox(
            height: 100,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Seasons: ${widget.numberOfSeasons} | Episodes: ${widget.numberOfEpisodes}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Synopsis section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.overview,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          // Counter section
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _currentEpisode > 1
                      ? () {
                    setState(() {
                      _currentEpisode--;
                    });
                  }
                      : null,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                Text(
                  'Episode $_currentEpisode',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _currentEpisode < int.parse(widget.numberOfEpisodes)
                      ? () {
                    setState(() {
                      _currentEpisode++;
                    });
                  }
                      : null,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          // Episode synopsis section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: FutureBuilder<Map<String,dynamic>>(
                  future: getEpisodeInfoNew(),
                  builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Center(child: CircularProgressIndicator());
                    }
                    else if(snapshot.hasData){
                        try {
                          return Column(
                            children: [
                              Text(
                                " ${snapshot.data!['episodes'][_currentEpisode -
                                    1]['name']}\n",
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              Text(
                                  "${snapshot
                                      .data!['episodes'][_currentEpisode -
                                      1]['overview']}"
                              )
                            ],
                          );
                        }
                        catch (e){
                          return Column(
                            children: const [
                              Text("No Data Available")
                            ],
                          );
                        }
                    }
                    else{
                      return const Center(child: Text('Failed to load Media Data'));
                    }
                  },
                ),
              ),
            ),

          ElevatedButton(
            child: const Text(
              "Return"
            ),
            onPressed: (){
              databaseRef.child(widget.iD).set({
                'Title' : widget.title,
                'id' : widget.iD,
                'imgURL' : widget.imgURL,
                'onEpisode': _currentEpisode,
                'tvID': widget.tvID,
                'numberOfEpisodes' : widget.numberOfEpisodes,
                'numberOfSeasons' : widget.numberOfSeasons,
                'releaseDate' : widget.releaseDate,
                'overview': widget.overview
              });
              Navigator.pop(context);
            },
          )
        ],
      ),
    ));
  }
}

import 'package:backlog_app/MediaInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchMedia extends StatefulWidget {
  const SearchMedia({Key? key}) : super(key: key);

  @override
  State<SearchMedia> createState() => _SearchMediaState();
}

class _SearchMediaState extends State<SearchMedia> {
  final TextEditingController _searchController = TextEditingController();
  final databaseRef = FirebaseDatabase.instance.ref("Users/${FirebaseAuth.instance.currentUser!.uid}/Lists");
  String apiKey = '142bd74481cb8b85f7026d6c6028a731';
  List<dynamic> _searchResults = [];
  late var data;
  late int numberOfEpisodes = 0;
  late int numberOfSeasons = 0;


  void _fetchSearchResults(String query) async{
    String apiKey = '142bd74481cb8b85f7026d6c6028a731';
    String url = 'https://api.themoviedb.org/3/search/multi?api_key=$apiKey&language=en-US&page=1&query=$query&include_adult=false';
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200){
      Map<String,dynamic> data = json.decode(response.body);
      setState(() {
        _searchResults = data['results'];
      });
    }
    else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<Map<String, dynamic>> fetchMediaInfo(String tvID) async{
    String apiKey = '142bd74481cb8b85f7026d6c6028a731';
    var url = Uri.https('api.themoviedb.org', '/3/tv/$tvID', {'api_key': apiKey, 'language': 'en-US'});
    var response = await http.get(url);
    if (response.statusCode == 200) {
        data = await jsonDecode(response.body);
        return data;
    } else {
      print('Failed to load TV show: ${response.statusCode}');
      return {};
    }

  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: "Search for a TV Show",
          ),
          onChanged: (String query) {
            _fetchSearchResults(query);
          },
        )
      ),
      body: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (BuildContext context, int index){
          String title = _searchResults[index]['title'] ?? _searchResults[index]['name'];
          String imgURL = _searchResults[index]['backdrop_path'] ?? '';
          String releaseDate = _searchResults[index]['release_date'] ?? _searchResults[index]['first_air_date'] ?? '';
          return ListTile(
            leading: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
                maxWidth: 104,
                maxHeight: 104,
              ),
              child: Image.network("https://image.tmdb.org/t/p/w500$imgURL",
              errorBuilder: (context, error, stackTrace){
                return Container(
                  color: Colors.grey,
                  alignment: Alignment.center,
                  child: const Text('No Image Found', style: TextStyle(fontSize: 10),),
                );
              }
                ,)
            ),
            title: Text(title),
            subtitle: Text('Release date: $releaseDate'),
            onTap: ()  {
              String selectedTitle = _searchResults[index]['title'] ?? _searchResults[index]['name'];
              String selectedReleaseDate = _searchResults[index]['release_date'] ?? _searchResults[index]['first_air_date'];
              String selectedOverView = _searchResults[index]['overview'];
              String tvId;
              if(_searchResults[index]['media_type'] == "tv"){
                 tvId = _searchResults[index]['id'].toString();
              }
              else{
                 tvId = ' ';
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  FutureBuilder<Map<String,dynamic>>(
                    future: fetchMediaInfo(tvId.toString()),
                    builder: (context, snapshot){
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return const Center(child: CircularProgressIndicator());
                      }
                      else if(snapshot.hasData){
                        int numOfEpisodes = snapshot.data?['number_of_episodes'] ?? 0;
                        int numOfSeasons = snapshot.data?['number_of_seasons'] ?? 0;
                        return MediaInformationScreen(
                          title: selectedTitle,
                          releaseDate: selectedReleaseDate,
                          overview: selectedOverView,
                          imageUrl: "https://image.tmdb.org/t/p/w500$imgURL",
                          tvID: tvId,
                          numberOfEpisodes: numOfEpisodes.toString(),
                          numberOfSeasons: numOfSeasons.toString()
                        );
                      }
                      else{
                        return const Center(child: Text('Failed to load Media Data'));
                      }
                    },
                  )
              ) );
            },
          );
        },
      ),
    );
  }
}


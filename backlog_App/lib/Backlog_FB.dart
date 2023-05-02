import 'package:backlog_app/Search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'Backlog_FB_Details.dart';

class MyFBBacklogList extends StatefulWidget{
  const MyFBBacklogList({super.key});

  @override
  _MyFBBacklogListState createState() => _MyFBBacklogListState();
}

class _MyFBBacklogListState extends State<MyFBBacklogList> {

  final auth = FirebaseAuth.instance;
  final userUID = FirebaseAuth.instance.currentUser?.uid.toString();
  final ref = FirebaseDatabase.instance.ref("Users/${FirebaseAuth.instance.currentUser!.uid}/Lists");
  final refChild = FirebaseDatabase.instance.ref("Users/${FirebaseAuth.instance.currentUser!.uid}");
  late int childrenCount;
  @override

  Widget build(BuildContext context){
    return  Scaffold(
      appBar: AppBar(
        title: const Text("Your Backlog"),
        actions: <Widget>[
          IconButton(
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchMedia())
                );
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: Column(
        children: [
            Expanded(
              child: FirebaseAnimatedList(
                query: ref,
                defaultChild: const Text("Loading"),
                itemBuilder: (context, snapshot, animation, index){
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    leading: Container(
                      constraints: const BoxConstraints(minWidth: 100, maxHeight: 100, maxWidth: 100, minHeight: 100),
                      child: Image.network(snapshot.child("imgURL").value.toString()),
                    ),
                    title: Text(snapshot.child("Title").value.toString()),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  MediaInformationScreen(
                            title: snapshot.child("Title").value.toString(),
                            releaseDate: snapshot.child('releaseDate').value.toString(),
                            overview: snapshot.child("overview").value.toString(),
                            imgURL: snapshot.child("imgURL").value.toString(),
                            numberOfEpisodes: snapshot.child("numberOfEpisodes").value.toString(),
                            numberOfSeasons: snapshot.child("numberOfSeasons").value.toString(),
                            onEpisode: snapshot.child("onEpisode").value.toString(),
                            tvID: snapshot.child("tvID").value.toString(),
                            iD: snapshot.child("id").value.toString()
                          ))
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: (){

                        ref.child(snapshot.child('id').value.toString()).remove();

                        setState(() {
                        });
                      },
                    ),
                  );
                }

              ),
            )
         ],
         ),
    );
  }
}




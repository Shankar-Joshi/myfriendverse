import 'package:chatapp/models/user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/auth.dart';
import 'package:chatapp/chat.dart';

class UserAppBarClick extends StatefulWidget {
  final String peerId;
  final String id;

  UserAppBarClick(this.peerId, this.id);

  _UserAppBarClick createState() => _UserAppBarClick(this.peerId, this.id);

}

class _UserAppBarClick extends State<UserAppBarClick>{
  final String peerId;
  final String currentuserid;

  _UserAppBarClick(@required this.peerId, @required this.currentuserid);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StreamBuilder(
      stream: Firestore.instance.collection('insta_users').document(peerId).snapshots(),
      builder: (BuildContext context, snapshot){
        if(!snapshot.hasData){
          return new Text("Loading");
        }
        var document = snapshot.data;

        _onlinestatus(){
          if(document['onlinetime'] == 'online'){
            return 'Online';
          } else if(document['onlinetime'] == 'On Mobile'){
            return 'On Mobile';
          } else {
            return 'last seen at ${DateFormat('dd MMM kk:mm')
                .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document['onlinetime'])))}';
          }
        }

        return new Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 300.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      "${document['displayName']}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.0,
                      ),
                    ),
                    background: Image.network(
                      "${document['photoUrl']}",
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              ];
            },
            body: Container(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      child: ListView(
                          children: ListTile.divideTiles(
                              context: context,
                              tiles: [
                                ListTile(
                                  leading: Icon(Icons.person,
                                  color: Colors.lightBlue,),
                                  title: Text('${document['displayName']}'),
                                  subtitle: Text('${_onlinestatus()}'),
                                ),
                                ListTile(
                                  leading: Icon(Icons.email,
                                  color: Colors.lightBlue,),
                                  title: Text("${document['email']}"),
                                ),
                                ListTile(
                                  leading: Icon(Icons.create,
                                  color: Colors.lightBlue,),
                                  title: Text('${document['bio']}'),
                                )
                              ]
                          ).toList()
                      ),
                    ),
                  ),
                ],
              ),
            )
          ),
        );
      }
    );
  }

}
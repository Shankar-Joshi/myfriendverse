import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'chat_home.dart';
import 'const.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'settings.dart';
import 'dart:io';

class ChatMainHome extends StatefulWidget {
  final String currentUserId;
  final VoidCallback onSignedOut;

  ChatMainHome({Key key, @required this.currentUserId, this.onSignedOut}) : super(key: key);

  @override
  State createState() => ChatMainHomeScreenState(currentUserId: currentUserId);
}

class ChatMainHomeScreenState extends State<ChatMainHome> {
  ChatMainHomeScreenState({Key key, @required this.currentUserId});

  final String currentUserId;

  bool isLoading = false;
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Settings', icon: Icons.settings),
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
  ];

  @override
  void initState() {
    super.initState();
  }


  void onItemMenuPress(Choice choice) {
    if (choice.title == 'Log out') {
      handleSignOut();
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Settings(currentUserId)));
    }
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: themeColor,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'CANCEL',
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'YES',
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
        break;
    }
  }

  Future<Null> handleSignOut() async {
    this.setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.signOut();
    widget.onSignedOut();

    this.setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Chats',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: <Widget>[
            PopupMenuButton<Choice>(
              onSelected: onItemMenuPress,
              itemBuilder: (BuildContext context) {
                return choices.map((Choice choice) {
                  return PopupMenuItem<Choice>(
                      value: choice,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            choice.icon,
                            color: primaryColor,
                          ),
                          Container(
                            width: 10.0,
                          ),
                          Text(
                            choice.title,
                            style: TextStyle(color: primaryColor),
                          ),
                        ],
                      ));
                }).toList();
              },
            ),
          ],
          bottom: TabBar(tabs: [
            Tab(icon: Icon(Icons.chat_bubble)),
            Tab(icon: Icon(Icons.contacts)),
            Tab(icon: Icon(Icons.child_friendly)),
          ]),
        ),
      body: TabBarView(children: [
        ChatHome(currentUserId: currentUserId, onSignedOut: this.widget.onSignedOut,),
        Icon(Icons.directions_boat),
        Icon(Icons.directions_transit),
      ]),
        )),);
//@override
//Widget build(BuildContext context) {
//return MaterialApp(
//home: DefaultTabController(
//length: 3,
//child: Scaffold(
//appBar: AppBar(
//  centerTitle: true,
//title: Text('Chat'),
//bottom: TabBar(tabs: [
//Tab(icon: Icon(Icons.chat_bubble)),
//Tab(icon: Icon(Icons.contacts)),
//Tab(icon: Icon(Icons.child_friendly)),
//]),
//),
//body: TabBarView(children: [
//ChatHome(currentUserId: currentUserId, onSignedOut: this.onSignedOut,),
//Icon(Icons.directions_boat),
//Icon(Icons.directions_transit),
//]),
//),
//),
//);
//}
}
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}
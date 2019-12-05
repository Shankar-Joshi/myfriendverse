import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/chat/settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../chat/chat.dart';
import 'package:chatapp/const.dart';
import 'package:intl/intl.dart';


class ChatHome extends StatefulWidget {
  final String currentUserId;
  final VoidCallback onSignedOut;

  ChatHome({Key key, @required this.currentUserId, this.onSignedOut}) : super(key: key);

  @override
  State createState() => ChatHomeScreenState(currentUserId: currentUserId);
}

class ChatHomeScreenState extends State<ChatHome> {
  ChatHomeScreenState({Key key, @required this.currentUserId});

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
    return Scaffold(
//      appBar: AppBar(
//        title: Text(
//          'Chats',
//          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
//        ),
//        centerTitle: true,
//        actions: <Widget>[
//          PopupMenuButton<Choice>(
//            onSelected: onItemMenuPress,
//            itemBuilder: (BuildContext context) {
//              return choices.map((Choice choice) {
//                return PopupMenuItem<Choice>(
//                    value: choice,
//                    child: Row(
//                      children: <Widget>[
//                        Icon(
//                          choice.icon,
//                          color: primaryColor,
//                        ),
//                        Container(
//                          width: 10.0,
//                        ),
//                        Text(
//                          choice.title,
//                          style: TextStyle(color: primaryColor),
//                        ),
//                      ],
//                    ));
//              }).toList();
//            },
//          ),
//        ],
//      ),
      body: Stack(
          children: <Widget>[
            // List
            Container(
              child: StreamBuilder(
                stream: Firestore.instance.collection('follow_details').document(currentUserId).collection("friends").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) => buildItem(context, snapshot.data.documents[index]),
                      itemCount: snapshot.data.documents.length,
                    );
                  }
                },
              ),
            ),

            // Loading
            Positioned(
              child: isLoading
                  ? Container(
                child: Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
                ),
                color: Colors.white.withOpacity(0.8),
              )
                  : Container(),
            )
          ],
        ),
//        onWillPop: onBackPress,

    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {

    String groupChatId;

    if (currentUserId.hashCode <= (document.documentID).hashCode) {
      groupChatId = '$currentUserId-${document.documentID}';
    } else {
      groupChatId = '${document.documentID}-$currentUserId';
    }

//    String groupChatId = '$currentUserId-${document.documentID}';

    return StreamBuilder(
        stream: Firestore.instance.collection('messages').document(groupChatId).collection(groupChatId).snapshots(),
        builder: (BuildContext context, snapshot) {
          int count;
          String lastmsg;
          String timestamp;
          String msgtype;
          if (!snapshot.hasData) {
            return new Text("Loading");
          }
          var dc = snapshot.data;
          int dclength = snapshot.data.documents.length;
          int dclengthafterupdate = dclength - 1;

          if(dclengthafterupdate < 0){
            count = 0;
          } else {
            count = dclengthafterupdate;
          }
          if(count != 0){
            msgtype = dc.documents[count]['type'].toString();
            if(msgtype == '1') {
              String lmsg;
              String currenname = dc.documents[count]['sendTo'];
              if(currenname == document['displayName']){
                lmsg = 'You sent a picture.';
                if (lmsg.length >= 30) {
                  lastmsg = '${lmsg.substring(0, 30)}...';
                } else {
                  lastmsg = 'You sent a picture.';
                }
                timestamp = DateFormat('dd MMM kk:mm')
                    .format(DateTime.fromMillisecondsSinceEpoch(
                    int.parse(dc.documents[count]['timestamp'])));
//              lastmsg = '${document['username']} sent you a picture.';
              } else {
                lmsg = 'You received a picture.';
                if (lmsg.length >= 30) {
                  lastmsg = '${lmsg.substring(0, 30)}...';
                } else {
                  lastmsg = 'You received a picture.';
                }
                timestamp = DateFormat('dd MMM kk:mm')
                    .format(DateTime.fromMillisecondsSinceEpoch(
                    int.parse(dc.documents[count]['timestamp'])));
//              lastmsg = '${document['username']} sent you a picture.';
              }
            } else if(msgtype == '0') {
              String lmsg;
              lmsg = dc.documents[count]['content'];
              if (lmsg.length >= 30) {
                lastmsg = '${lmsg.substring(0, 30)}...';
              } else {
                lastmsg = lmsg;
              }
              timestamp = DateFormat('dd MMM kk:mm')
                  .format(DateTime.fromMillisecondsSinceEpoch(
                  int.parse(dc.documents[count]['timestamp'])));
//            print('value of last msg is ${dc.documents[count]['content']}');
            } else {
              String lmsg;
              String currenname = dc.documents[count]['sendTo'];
              if(currenname == document['displayName']){
                lmsg = 'You sent an emoji.';
                if (lmsg.length >= 30) {
                  lastmsg = '${lmsg.substring(0, 30)}...';
                } else {
                  lastmsg = 'You sent an emoji.';
                }
                timestamp = DateFormat('dd MMM kk:mm')
                    .format(DateTime.fromMillisecondsSinceEpoch(
                    int.parse(dc.documents[count]['timestamp'])));
//              lastmsg = '${document['username']} sent you a picture.';
              } else {
                lmsg = 'You received an emoji.';
                if (lmsg.length >= 30) {
                  lastmsg = '${lmsg.substring(0, 30)}...';
                } else {
                  lastmsg = 'You received an emoji.';
                }
                timestamp = DateFormat('dd MMM kk:mm')
                    .format(DateTime.fromMillisecondsSinceEpoch(
                    int.parse(dc.documents[count]['timestamp'])));
//              lastmsg = '${document['username']} sent you a picture.';
              }
            }
          }
//          print('items of number of data ${count}');
          if (document['id'] == currentUserId) {
            return Container();
          } else {
            return Container(
              child: FlatButton(
                child: Row(
                  children: <Widget>[
                    Material(
                      child: document['photoUrl'] != null
                          ? CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                          ),
                          width: 50.0,
                          height: 50.0,
                          padding: EdgeInsets.all(15.0),
                        ),
                        imageUrl: document['photoUrl'],
                        width: 50.0,
                        height: 50.0,
                        fit: BoxFit.cover,
                      )
                          : Icon(
                        Icons.account_circle,
                        size: 50.0,
                        color: greyColor,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    Flexible(
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      '${document['username']}',
                                      style: TextStyle(color: primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                                  ),
                                  Container(
                                    child: Text(
                                      '${timestamp ?? ''}',
                                      style: TextStyle(color: primaryColor),
                                    ),
                                    alignment: Alignment.centerRight,
                                  )
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      '${lastmsg ?? ''}',
                                      style: TextStyle(color: primaryColor),
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        margin: EdgeInsets.only(left: 20.0),
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Chat(
                            peerId: document.documentID,
                            peerAvatar: document['photoUrl'],
                            username: document['displayName'],
                            id: currentUserId,
                          )));
                },
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
            );
          }
        }
        );


//    Firestore.instance.collection('messages').document(groupChatId).collection(groupChatId).where('timestamp', isGreaterThan: )

//    if (document['id'] == currentUserId) {
//      return Container();
//    } else {
//      return Container(
//        child: FlatButton(
//          child: Row(
//            children: <Widget>[
//              Material(
//                child: document['photoUrl'] != null
//                    ? CachedNetworkImage(
//                  placeholder: (context, url) => Container(
//                    child: CircularProgressIndicator(
//                      strokeWidth: 1.0,
//                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
//                    ),
//                    width: 50.0,
//                    height: 50.0,
//                    padding: EdgeInsets.all(15.0),
//                  ),
//                  imageUrl: document['photoUrl'],
//                  width: 50.0,
//                  height: 50.0,
//                  fit: BoxFit.cover,
//                )
//                    : Icon(
//                  Icons.account_circle,
//                  size: 50.0,
//                  color: greyColor,
//                ),
//                borderRadius: BorderRadius.all(Radius.circular(25.0)),
//                clipBehavior: Clip.hardEdge,
//              ),
//              Flexible(
//                child: Container(
//                  child: Column(
//                    children: <Widget>[
//                      Container(
//                        child: Text(
//                          '${document['username']}',
//                          style: TextStyle(color: primaryColor,
//                          fontWeight: FontWeight.bold),
//                        ),
//                        alignment: Alignment.centerLeft,
//                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
//                      ),
//                      Container(
//                        child: Text(
//                          '${document['bio'] ?? ''}',
//                          style: TextStyle(color: primaryColor),
//                        ),
//                        alignment: Alignment.centerLeft,
//                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
//                      )
//                    ],
//                  ),
//                  margin: EdgeInsets.only(left: 20.0),
//                ),
//              ),
//            ],
//          ),
//          onPressed: () {
//            Navigator.push(
//                context,
//                MaterialPageRoute(
//                    builder: (context) => Chat(
//                      peerId: document.documentID,
//                      peerAvatar: document['photoUrl'],
//                      username: document['displayName'],
//                      id: currentUserId,
//                    )));
//          },
//          color: Colors.white,
//          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
//          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
//        ),
//        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
//      );
//    }
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}
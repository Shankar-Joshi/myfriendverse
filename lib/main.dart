import 'package:chatapp/chat/ChatMainHome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'feed.dart';
import 'upload_page.dart';
import 'dart:async';
import 'chat/ChatMainHome.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_page.dart';
import 'search_page.dart';
import 'activity_feed.dart';
import 'package:chatapp/root_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;
import 'models/user.dart';
import 'package:chatapp/auth.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

final auth = FirebaseAuth.instance;
final googleSignIn = GoogleSignIn();
final ref = Firestore.instance.collection('insta_users');
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();


User currentUserModel;

Future<Null> _setUpNotifications(String id) async {
  if (Platform.isAndroid) {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );

    _firebaseMessaging.getToken().then((token) {
      print("Firebase Messaging Token: " + token);

      Firestore.instance
          .collection("insta_users")
          .document(id)
          .updateData({"androidNotificationToken": token});
    });

    print("user id in notification is: $id");
  }
}
void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Friendverse',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new RootPage(auth: new Auth()));
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, @required this.id, @required this.auth, this.mUser, this.onSignedOut}) : super(key: key);
  final String title;
  final String id;
  final Auth auth;
  final User mUser;
  final VoidCallback onSignedOut;

  @override
  _HomePageState createState() => _HomePageState();
}

PageController pageController;

class _HomePageState extends State<HomePage> with WidgetsBindingObserver{
  int _page = 0;
  bool triedSilentLogin = false;
  bool setupNotifications = false;
  String timenow = DateTime.now().millisecondsSinceEpoch.toString();
  String statusonline = 'Online';
  AppLifecycleState appLifecycleState;

  onlinetimestatus() async {

    Firestore.instance.collection('insta_users').document(widget.id).updateData({'onlinetime': timenow});

    setState(() {});
  }

  pausedstatus() async {

    Firestore.instance.collection('insta_users').document(widget.id).updateData({'onlinetime': 'On Mobile'});

    setState(() {});
  }

  statusonlilnetime() async{
    Firestore.instance.collection('insta_users').document(widget.id).updateData({'onlinetime': 'online'});
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {

    setUpNotifications(widget.id);

    return Scaffold(
            body: PageView(
              children: [
                Container(
                  color: Colors.white,
                  child: Feed(widget.id),
                ),
                Container(color: Colors.white, child: SearchPage()),
                Container(
                  color: Colors.white,
                  child: Uploader(widget.mUser),
                ),
                Container(
                    color: Colors.white, child: ActivityFeedPage(widget.mUser)),
                Container(
                    color: Colors.white,
                    child: ProfilePage(
                      userId: widget.id, auth: widget.auth, mUserpro: widget.mUser)),
                Container(
                  color: Colors.white,
                  child: ChatMainHome(currentUserId: widget.id, onSignedOut: widget.onSignedOut,),
                )
              ],
              controller: pageController,
              physics: NeverScrollableScrollPhysics(),
              onPageChanged: onPageChanged,
            ),
            bottomNavigationBar: CurvedNavigationBar(
                backgroundColor: Colors.lightBlue,
                items: <Widget>[
                  Icon(Icons.home,
                  color: (_page == 0) ? Colors.black : Colors.grey,),
                  Icon(Icons.search,
                          color: (_page == 1) ? Colors.black : Colors.grey),
                      Icon(Icons.add_circle,
                          color: (_page == 2) ? Colors.black : Colors.grey),
                      Icon(Icons.star,
                          color: (_page == 3) ? Colors.black : Colors.grey),
                      Icon(Icons.person,
                          color: (_page == 4) ? Colors.black : Colors.grey),
                      Icon(Icons.chat,
                        color: (_page == 5) ? Colors.black: Colors.grey,),

                ],
                onTap: (index){
                  navigationTapped(index);
                }
            )
//            CupertinoTabBar(
//              activeColor: Colors.orange,
//              items: <BottomNavigationBarItem>[
//                BottomNavigationBarItem(
//                    icon: Icon(Icons.home,
//                        color: (_page == 0) ? Colors.black : Colors.grey),
//                    title: Container(height: 0.0),
//                    backgroundColor: Colors.white),
//                BottomNavigationBarItem(
//                    icon: Icon(Icons.search,
//                        color: (_page == 1) ? Colors.black : Colors.grey),
//                    title: Container(height: 0.0),
//                    backgroundColor: Colors.white),
//                BottomNavigationBarItem(
//                    icon: Icon(Icons.add_circle,
//                        color: (_page == 2) ? Colors.black : Colors.grey),
//                    title: Container(height: 0.0),
//                    backgroundColor: Colors.white),
//                BottomNavigationBarItem(
//                    icon: Icon(Icons.star,
//                        color: (_page == 3) ? Colors.black : Colors.grey),
//                    title: Container(height: 0.0),
//                    backgroundColor: Colors.white),
//                BottomNavigationBarItem(
//                    icon: Icon(Icons.person,
//                        color: (_page == 4) ? Colors.black : Colors.grey),
//                    title: Container(height: 0.0),
//                    backgroundColor: Colors.white),
//                BottomNavigationBarItem(
//                  icon: Icon(Icons.chat,
//                  color: (_page == 5) ? Colors.black: Colors.grey,),
//                  title: Container(height: 0.0,),
//                  backgroundColor: Colors.white
//                )
//              ],
//              onTap: navigationTapped,
//              currentIndex: _page,
//            ),
          );
  }

  void login() async {
//    await _ensureLoggedIn(context);
    setState(() {
      triedSilentLogin = true;
    });
  }

  void setUpNotifications(String mid) {
    _setUpNotifications(mid);
//    setState(() {
//      setupNotifications = true;
//    });
  }

  void silentLogin(BuildContext context) async {
//    await _silentLogin(context);
    setState(() {
      triedSilentLogin = true;
    });
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    WidgetsBinding.instance.addObserver(this);

    setState(() {
      currentUserModel = widget.mUser;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    if(state == AppLifecycleState.resumed){
      setState(() => appLifecycleState = state);
      print('state of the app: $appLifecycleState');
      statusonlilnetime();
    }else{
      setState(() => appLifecycleState = state);
      onlinetimestatus();
    }
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

}

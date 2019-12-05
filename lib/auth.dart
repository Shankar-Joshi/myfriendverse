import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'models/user.dart';
import 'package:chatapp/create_account.dart';
import 'dart:io' show Platform;

final ref = Firestore.instance.collection('insta_users');
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
final Auth auth = Auth();

User signedcurrentUserModel;

abstract class BaseAuth {

  Future<String> currentUser();
  Future<String> signIn(String email, String password);
  Future<Null> createUser(String email, String password, String fullName,
  String phonenumber, String username, String imageUrl, String dateofBirth, BuildContext context);
   Future<String>coverPicUploadToFirebase(String url);
   Future<String>profilePicUploadToFirebase(String url);
  Future<void> signOut();
  Future<String> getEmail();
  Future<bool> isSignedIn();
  Future<String> getcoverpicture();
  Future<String> getUserFullname();
  Future<User>firestoreUser();
  Future<Null> setUpNotifications();
  Future<FirebaseUser> getCurrentUser();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String fulnamee;

  Future<String> signIn(String email, String password) async {

    final currUs = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

//    setUpNotifications();

    return currUs.toString();

  }
  Future<User>firestoreUser() async{

    final currentUser = await _firebaseAuth.currentUser();

    DocumentSnapshot dsnap = await ref.document(currentUser.uid).get();

    signedcurrentUserModel = User.fromDocument(dsnap);

    return signedcurrentUserModel;

  }

  Future<Null> createUser(String email, String password, String fullName,
  String phonenumber, String username, String imageUrl, String dateofBirth, BuildContext context) async {
    
    final databasereference = FirebaseDatabase.instance.reference();
    FirebaseUser firebaseUser = (await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).user;

    await databasereference.child("users").child(firebaseUser.uid).set({
      "email": email,
      "fullname": fullName,
      "phone_number": phonenumber,
      "username": username,
      "imageURL": imageUrl,
      "dateofBirth": dateofBirth,
    });

    DocumentSnapshot userRecord = await ref.document(firebaseUser.uid).get();
    if (userRecord.data == null) {
      // no user record exists, time to create

      String userName = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Center(
              child: Scaffold(
                  appBar: AppBar(
                    leading: Container(),
                    title: Text('Fill out missing data',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.white,
                  ),
                  body: ListView(
                    children: <Widget>[
                      Container(
                        child: CreateAccount(),
                      ),
                    ],
                  )),
            )),
      );

      if (userName != null || userName.length != 0) {
        ref.document(firebaseUser.uid).setData({
          "id": firebaseUser.uid,
          "username": userName,
          "photoUrl": imageUrl,
          "email": email,
          "displayName": fullName,
          "bio": "",
          "onlinetime": "online",
          "followers": {},
          "following": {firebaseUser.uid: true}, // add current user so they can see their own posts in feed,
        });
      }
      userRecord = await ref.document(firebaseUser.uid).get();
    }
    signedcurrentUserModel = User.fromDocument(userRecord);

    Navigator.push(context, MaterialPageRoute(builder: (context){
      setUpNotifications();
      return HomePage(id: firebaseUser.uid, auth: auth, mUser: signedcurrentUserModel,);
    }));
    return;
  }

  Future<Null> setUpNotifications() async {
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
            .document(signedcurrentUserModel.id)
            .updateData({"androidNotificationToken": token});
      });
    }
  }

   Future<String>coverPicUploadToFirebase(String url) async{
     final databasereference = FirebaseDatabase.instance.reference();
     final FirebaseUser user = await FirebaseAuth.instance.currentUser();
     await databasereference.child("users").child(user.uid).set({
       "cover_pic": url,
     });
     return user.uid;
   }

   Future<String>profilePicUploadToFirebase(String url) async{
     final databasereference = FirebaseDatabase.instance.reference();
     final FirebaseUser user = await FirebaseAuth.instance.currentUser();
     await databasereference.child("users").child(user.uid).set({
       "profile_pic": url,
     });
     return user.uid;
   }
 
  Future<String> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user != null ? user.uid : null;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<bool> isSignedIn() async {
    final currentUser = await _firebaseAuth.currentUser();
    return currentUser != null;
  }

  Future<String> getEmail() async{
    return (await _firebaseAuth.currentUser()).email;
  }

  Future<String> getcoverpicture() async{
    final currentUser = await _firebaseAuth.currentUser();
    final databasereference = FirebaseDatabase.instance.reference().child("users").child(currentUser.uid).child("cover_pic");
    
    DataSnapshot dataSnapshot = await databasereference.once();

    return dataSnapshot.value;
  }

  Future<String> getUserFullname() async{
    
    final currentUser = await _firebaseAuth.currentUser();
    final databasereference = FirebaseDatabase.instance.reference().child("users").child(currentUser.uid).child("fullname");
    
    DataSnapshot dataSnapshot = await databasereference.once();
    return dataSnapshot.value;
  }

}
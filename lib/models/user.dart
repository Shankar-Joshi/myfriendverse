import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  final String id;
  final String email;
  final String photoUrl;
  final String username;
  final String profilepicture;
  final String coverpicture;
  final String status;
  final String fullname;
  final String displayName;
  final String bio;
  final String onlinetime;
  final Map followers;
  final Map following;

  const User(
    {
      this.id,
      this.email,
      this.username,
      this.fullname,
      this.profilepicture,
      this.coverpicture,
      this.photoUrl,
      this.status,
      this.displayName,
      this.followers,
      this.following,
      this.bio,
      this.onlinetime,
    }
  );

  factory User.fromDocument(DocumentSnapshot document){
    return User(
      id: document['id'],
      email: document['email'],
      username: document['username'],
      fullname: document['fullname'],
      profilepicture: document['profilepicture'],
      coverpicture: document['coverpicture'],
      photoUrl: document['photoUrl'],
      status: document['status'],
      displayName: document['displayName'],
      followers: document['followers'],
      following: document['following'],
      bio: document['bio'],
      onlinetime: document['onlinetime'],
    );
  }
}
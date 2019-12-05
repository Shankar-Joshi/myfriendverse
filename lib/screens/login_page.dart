import 'package:chatapp/main.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/auth.dart';

import 'package:chatapp/screens/SignUpScreen.dart';


class LoginScreen extends StatefulWidget{

  LoginScreen({Key key, this.title, this.auth, this.onSignIn}) : super(key: key);

  final String title;
  final BaseAuth auth;
  final VoidCallback onSignIn;

  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState(this.auth);
  }

}

class _LoginScreenState extends State<LoginScreen>{

  _LoginScreenState(this._auth);

  static final formKey = new GlobalKey<FormState>();


  String _email;
  String _password;
  String _authHint = '';

  final BaseAuth _auth;


  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
  void validateAndSubmit() async{
    if (validateAndSave()) {
      try{
        String userId =  await widget.auth.signIn(_email, _password);
        if (userId.length > 0 && userId != null) {
          widget.onSignIn();
        }
      }catch(e){
        setState(() {
          _authHint = 'Sign In Error\n\n${e.toString()}';
        });
        print(e);
      }

    }
  }


  @override
  Widget build(BuildContext context) {

    final emailField = TextFormField(
      key: new Key('email'),
      autocorrect: false,
      validator: (val) => val.isEmpty ? 'Email can\'t be empty.' : null,
      onSaved: (val) => _email = val,
      decoration: InputDecoration(
          labelText: "Email",
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final passwordField = TextFormField(
      key: new Key('password'),
      obscureText: true,
      validator: (val) => val.isEmpty ? 'Password can\'t be empty.': null,
      onSaved: (val) => _password = val,
      decoration: InputDecoration(
          labelText: "Password",
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: (){validateAndSubmit();},
        child: Text("Login",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
    final registerButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return SignupScreen();
          }));
        },
        child: Text("Register",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text("Login"),),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                new Container(
                  padding: const EdgeInsets.all(16.0),
                  child: new Form(
                    key: formKey,
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text("Welcome to Friendverse", style: TextStyle(fontSize: 30.0,
                        fontWeight: FontWeight.bold, fontStyle: FontStyle.italic) ,),
                        SizedBox(height: 80.0,),
                        emailField,
                        SizedBox(height: 25.0,),
                        passwordField,
                        SizedBox(height: 30.0,),
                        loginButon,
                        SizedBox(height: 30.0,),
                        registerButton,
                      ],
                    ),
                  ),
                )
              ],
            ),
        )
          ),
        ),
      ),
    );
  }

}
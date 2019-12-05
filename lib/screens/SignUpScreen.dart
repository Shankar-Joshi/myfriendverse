import 'package:flutter/material.dart';
import 'package:chatapp/screens/login_page.dart';
import 'package:chatapp/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

final ref = Firestore.instance.collection('insta_users');
class SignupScreen extends StatefulWidget{
  
  final BaseAuth auth = Auth();

  @override
  State<StatefulWidget> createState() {
    return _SignupScreenState();
  }
}

class _SignupScreenState extends State<SignupScreen>{

  static final formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _fullname;
  String _phonenumber;
  String _username;
  String imageurl;
  String _dateofbirth;
  String _selected;

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
      print("button clicked");
      await widget.auth.createUser(_email, _password ,_fullname, _phonenumber, _username, "", "", context);
    }catch(e){
      setState(() {
          
        });
        print(e);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final fullnameField = TextFormField(
      key: new Key('fullname'),
      obscureText: false,
      validator: (val) => val.isEmpty ? 'Name can\'t be empty.': null,
      onSaved: (val) => _fullname = val,
          decoration: InputDecoration(
            icon: const Icon(Icons.person),
            labelText: "Full Name",
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: "Full Name",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final emailField = TextFormField(
        key: new Key('email'),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Email can\'t be empty.' : null,
        onSaved: (val) => _email = val,
        decoration: InputDecoration(
          icon: const Icon(Icons.email),
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
            icon: const Icon(Icons.security),
              labelText: "Password",
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: "Password",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
        );
          final phoneNumber = TextFormField(
            key: new Key('Phone Number'),
            maxLength: 10,
            keyboardType: TextInputType.phone,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly,
            ],
            validator: (val) => val.length<10 ? 'Phone number is not valid': null,
            onSaved: (val) => _phonenumber = val,
            decoration: InputDecoration(
                labelText: "Phone Number",
                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                hintText: "Phone Number",
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
          );

    final dateOfBirth = TextFormField(
      key: new Key('dateofbirth'),
      maxLength: 10,
      keyboardType: TextInputType.datetime,
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly,
      ],
      validator: (val) => val.isEmpty ? 'Date of birth is not valid': null,
      onSaved: (val) => _dateofbirth = val,
      decoration: InputDecoration(
          icon: const Icon(Icons.calendar_today),
          labelText: "Date of Birth",
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "MM/DD/YYYY",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
        final registerButton = Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(30.0),
          color: Color(0xff01A0C7),
          child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            onPressed: () {
              validateAndSubmit();
            },
            child: Text("Register",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
        final loginButon = Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(30.0),
          color: Color(0xff01A0C7),
          child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Already have an account?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );


    return Scaffold(
      appBar: AppBar(title: Text("Signup"),),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
        child: Container(
          color: Colors.white,
          child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Container(
                      padding: const EdgeInsets.all(10.0),
                      child: new Form(
                        key: formKey,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                      Text("Welcome to Friendverse", style: TextStyle(fontSize: 30.0,
                      fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
                      SizedBox(height: 15.0),
                      fullnameField,
                      SizedBox(height: 15.0,),
                      emailField,
                      SizedBox(height: 15.0,),
                      Container(
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: CountryCodePicker(
                              onChanged: (text) {
                                print("selected country code is: $text");
                                _selected = text.toString();
                              },
                              initialSelection: 'US',
                              showCountryOnly: false,
                              showOnlyCountryWhenClosed: false,
                              alignLeft: false,
                            ), width: 80.0,
                          ),
                          Container(
                            child: phoneNumber,
                            width: 250.0,
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 15.0,),
                    Container(
                      child: DateTimePickerFormField(
                        inputType: InputType.date,
                        format: DateFormat("yyyy-MM-dd"),
                        initialDate: DateTime(2019, 1, 1),
                        editable: true,
                        decoration: InputDecoration(
                            labelText: 'Date',
                            hasFloatingPlaceholder: false
                        ),
                        onChanged: (dt) {
                          setState(() => _dateofbirth = dt.toString());
                          print('Selected date: $_dateofbirth');
                        },
                      ),
                    ),
                    SizedBox(height: 15.0,),
                    passwordField,
                    SizedBox(height: 15.0,),
                    registerButton,
                    SizedBox(height: 15.0,),
                    loginButon,
                    SizedBox(height: 15.0,),
                  ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
  }
  
}
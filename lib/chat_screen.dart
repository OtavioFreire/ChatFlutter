import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chat_flutter/text.composing.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'chatMessage.dart';

// ignore: camel_case_types
class chatScreen extends StatefulWidget {
  @override
  chatScreenState createState() => chatScreenState();
}

// ignore: camel_case_types
class chatScreenState extends State<chatScreen> {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();

  FirebaseUser _currentUser;
  bool _isLoading = false;

  @override
  void initState(){
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<FirebaseUser> _getUser() async{
    if(_currentUser != null) return _currentUser;

    try{
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken, 
        accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult = await FirebaseAuth.instance.signInWithCredential(credential);

      final FirebaseUser user = await authResult.user;

      return user;
    }catch(error){

    }
  }

   void sendFB({String text, File imgFile}) async {
     final FirebaseUser user = await _getUser();

    if(user == null){
      _scaffold.currentState.showSnackBar(
        SnackBar(
          content: Text('Não foi possivel fazer login'),
          backgroundColor: Colors.red,
        )
      );
    }

    Map<String, dynamic> data = {
      "uid" : user.uid,
      "senderName": user.displayName,
      "senderPhotoURL" : user.photoUrl,
      "time" : Timestamp.now()
    };
    if (imgFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imgFile);
      setState(() {
        _isLoading = true;
      });
      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl'] = url;
      setState(() {
        _isLoading = false;
      });
    }
    if (text != null) {
      data['text'] = text;
    }
    Firestore.instance.collection("mensagens").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key:_scaffold,
        appBar: AppBar(
          centerTitle: true,
          title: Text(_currentUser != null ? 'Olá, ${_currentUser.displayName}' : 'ChatApp',),
          elevation: 0,
          actions: <Widget>[
            _currentUser != null ? IconButton(
               icon: Icon(Icons.exit_to_app),
               onPressed: (){
                 FirebaseAuth.instance.signOut();
                 googleSignIn.signOut();
                 _scaffold.currentState.showSnackBar(
                SnackBar(
                  content: Text('Você deslogou com Sucesso!'),
                  )
                );
               }
            ) : Container(),
          ],
        ),
        body: Column(children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('mensagens').orderBy('time').snapshots(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                default:
                  List<DocumentSnapshot> documents = snapshot.data.documents.reversed.toList();

                  return ListView.builder(
                    itemCount: documents.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      return ChatMessage(documents[index].data, documents[index].data['uid'] == _currentUser?.uid );
                    },
                  );
              }
            },
          )),
          _isLoading ? LinearProgressIndicator() : Container(),
          textComposing(sendFB),
        ]));
  }
}

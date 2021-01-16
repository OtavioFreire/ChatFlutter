import 'package:chat_flutter/chat_screen.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  runApp(MyApp());

  /*Firestore.instance
      .collection("mensagens")
      .document()
      .collection("arquivos")
      .document("arquivos")
      .setData({"texto":"foto.png"});
    DocumentSnapshot snapshot =  await Firestore.instance.collection("mensagens").document("fDlVctPL151f6tbanejO").get();
    print(snapshot.data);
    Firestore.instance.collection("mensagens").snapshots().listen((dado) {dado.documents.forEach((d) {print(d.data); });});
    Firestore.instance.collection("mensagens").document("fDlVctPL151f6tbanejO").snapshots().listen((dado) {print(dado.data); });*/

}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatBot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        iconTheme: IconThemeData(color: Colors.blue),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: chatScreen(),
    );
  }
}

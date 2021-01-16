import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ignore: camel_case_types, must_be_immutable
class textComposing extends StatefulWidget {
  textComposing(this.sendMessage);

  final Function({String text, File imgFile}) sendMessage;

  @override
  textComposingState createState() => textComposingState();
}

// ignore: camel_case_types
class textComposingState extends State<textComposing> {
  final TextEditingController _controller = TextEditingController();

  bool _isComposing = false;

  void textClear() {
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.photo_camera,
            color: Colors.blue,
          ),
          onPressed: () async {
           final File imgFile = await ImagePicker.pickImage(source: ImageSource.camera);
            if(imgFile == null)return;
            widget.sendMessage(imgFile : imgFile);
          },
        ),
        Expanded(
            child: TextField(
          controller: _controller,
          decoration:
              InputDecoration.collapsed(hintText: "Envie uma Mensagem!"),
          onChanged: (text) {
            setState(() {
              _isComposing = text.isNotEmpty;
            });
          },
          onSubmitted: (text) {
            widget.sendMessage(text: text);
            textClear();
          },
        )),
        IconButton(
          icon: Icon(
            Icons.send,
          ),
          onPressed: _isComposing
              ? () {
                  widget.sendMessage( text: _controller.text);
                  textClear();
                }
              : null,
        )
      ]),
    );
  }
}

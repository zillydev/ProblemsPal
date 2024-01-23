import 'package:flutter/material.dart';

class CustomDialog {
  final BuildContext context;
  final String title;
  final TextEditingController controller;
  final FocusNode node;
  final List profiles;
  final Function(String) onSubmit;
  String? errorMessage;

  CustomDialog({
    required this.context,
    required this.title,
    required this.controller,
    required this.node,
    required this.profiles,
    required this.onSubmit,
  });

  void dialog() {
    String? errorMessage;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                  titlePadding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
                  contentPadding: const EdgeInsets.all(15),
                  title: Text(title),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        focusNode: node,
                        controller: controller,
                        maxLength: 15,
                        decoration: InputDecoration(errorText: errorMessage),
                        onChanged: (String value) {
                          // Remove error message if there is one
                          if (errorMessage != null) {
                            setState(() {
                              errorMessage = null;
                            });
                          }
                        },
                        onSubmitted: (String value) {
                          submit(value, setState);
                        },
                      ),
                      Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: ElevatedButton(
                                onPressed: () {
                                  submit(controller.text, setState);
                                },
                                child: const Text("Ok")),
                          ))
                    ],
                  ));
            },
          );
        });
    node.requestFocus();
  }

  void submit(String value, Function setState) {
    if (profiles.contains(value)) {
      setState(() {
        errorMessage = "Profile already exists";
      });
      node.requestFocus();
    } else if (value == "") {
      setState(() {
        errorMessage = "Profile name cannot be empty";
      });
      node.requestFocus();
    } else {
      onSubmit(value);
      Navigator.pop(context);
    }
  }
}

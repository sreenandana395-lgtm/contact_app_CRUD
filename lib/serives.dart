import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

Future<void> addcontact(
  String name,
  String number,
  BuildContext context,
) async {
  await FirebaseFirestore.instance.collection("contactdata").add({
    "name": name,
    "number": number,
  });
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text("ADDED SUCCESSFULLY!")));
}



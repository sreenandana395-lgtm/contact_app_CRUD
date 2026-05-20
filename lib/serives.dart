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
  ).showSnackBar(SnackBar(content: Text("ADDED SUCCESSFULLY")));
}

Stream<QuerySnapshot> getcontactdata() {
  return FirebaseFirestore.instance.collection("contactdata").snapshots();
}

Future<void> updatecontact(
  String id,
  String name,
  String number,
  BuildContext context,
) async {
  await FirebaseFirestore.instance.collection("contactdata").doc(id).update({
    "name": name,
    "number": number,
  });
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text("UPDATE SUCCESSFULLY")));
}

Future<void> deletecontact(String id, BuildContext context) async {
  await FirebaseFirestore.instance.collection("contactdata").doc(id).delete();
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UserProvider with ChangeNotifier {
  late String _id = '';
  String get id => _id;

  Future<UserCredential> login() async {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    debugPrint("Signed in response => $userCredential");
    _id = userCredential.user!.uid;
    notifyListeners();
    return userCredential;
  }

  Future<dynamic> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<dynamic> addWeightToFirebaseCollection(
      {required double weight}) async {
    var map = <String, dynamic>{};
    map['weight'] = weight;
    map['date'] = DateTime.now().toString();
    await FirebaseFirestore.instance
        .collection("weight_collection")
        .doc(_id)
        .set({
      "weight": FieldValue.arrayUnion([map])
    }, SetOptions(merge: true));
    notifyListeners();
  }

  Future<dynamic> editSpecificWeight({required List<dynamic> data}) async {
    await FirebaseFirestore.instance
        .collection("weight_collection")
        .doc(_id)
        .update(
      {
        "weight": data,
      },
    );
    notifyListeners();
  }
}

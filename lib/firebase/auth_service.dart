import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password,
      );
      return userCredential;
    } catch (e) { rethrow; }
  }

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password,
      );
      return userCredential;
    } catch (e) { rethrow; }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) { rethrow; }
  }

  Future<void> updateFullProfile({
    required String uid,
    required Map<String, dynamic> data,
    required List<File?> imageFiles,
  }) async {
    List<String> imageUrls = [];

    // Com que les regles prohibeixen el 'read' al propi usuari,
    // no podem fer un .get() aquí si l'usuari és qui executa l'app.
    // Si necessites mantenir URLs antigues, passa-les com a argument 'data'.

    for (int i = 0; i < imageFiles.length; i++) {
      File? file = imageFiles[i];
      if (file != null) {
        try {
          final storageRef = _storage.ref().child('users/$uid/foto_$i.jpg');

          final uploadTask = await storageRef.putFile(
            file,
            SettableMetadata(contentType: 'image/jpeg'),
          );

          String url = await uploadTask.ref.getDownloadURL();
          imageUrls.add(url);
        } catch (e) {
          print("Error pujant foto $i: $e");
        }
      }
    }

    try {
      final Map<String, dynamic> finalData = {
        ...data,
        'ultimaActualitzacio': FieldValue.serverTimestamp(),
      };

      if (imageUrls.isNotEmpty) {
        finalData['photoUrls'] = imageUrls;
        finalData['photoUrl'] = imageUrls[0];
      }

      await _db.collection('users').doc(uid).set(finalData, SetOptions(merge: true));
    } catch (e) {
      print("Error guardant perfil a Firestore: $e");
      rethrow;
    }
  }
}
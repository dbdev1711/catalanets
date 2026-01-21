import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UserCredential?> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential?> signUp(String email, String password, String nom) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password
    );

    if (credential.user != null) {
      String uid = credential.user!.uid;

      // 1. Creem el perfil de l'usuari a la col·lecció 'users'
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'nom': nom,
        'edat': 0,
        'interessos': [],
        'photoUrls': [],
        'fuma': '',
        'beu': '',
        'exercici': '',
        'animals': '',
        'fills': '',
        'volFills': '',
        'alimentacio': '',
      });

      // 2. Creem el registre legal a la col·lecció 'acceptacions_normativa'
      await _firestore.collection('acceptacions_normativa').doc(uid).set({
        'uid': uid,
        'acceptat': true,
        'data_acceptacio': FieldValue.serverTimestamp(),
      });
    }
    return credential;
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateFullProfile({
    required String uid,
    required Map<String, dynamic> data,
    required List<dynamic> photos,
  }) async {
    List<String> finalUrls = [];

    for (int i = 0; i < photos.length; i++) {
      var item = photos[i];

      if (item is XFile) {
        String fileName = "photo_$i.jpg";
        Reference ref = _storage.ref().child('users').child(uid).child(fileName);

        final bytes = await item.readAsBytes();

        await ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );

        String url = await ref.getDownloadURL();
        finalUrls.add(url);
      }
      else if (item is String) {
        finalUrls.add(item);
      }
    }

    data['photoUrls'] = finalUrls;

    await _firestore.collection('users').doc(uid).set(
      data,
      SetOptions(merge: true)
    );
  }

  Future<void> reauthenticateAndDelete(String password) async {
    User? user = _auth.currentUser;
    if (user == null || user.email == null) return;

    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);
    await deleteUserAccount();
  }

  Future<void> deleteUserAccount() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    String uid = user.uid;

    try {
      final ListResult result = await _storage.ref().child('users').child(uid).listAll();
      for (var file in result.items) {
        await file.delete();
      }

      await _firestore.collection('users').doc(uid).delete();
      await _firestore.collection('acceptacions_normativa').doc(uid).delete();
      await user.delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async => await _auth.signOut();
}
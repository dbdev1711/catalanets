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
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
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

    for (var item in photos) {
      if (item is XFile) {
        String fileName = "${DateTime.now().millisecondsSinceEpoch}_${item.name}";
        Reference ref = _storage.ref().child('users').child(uid).child(fileName);

        final bytes = await item.readAsBytes();
        await ref.putData(bytes);

        String url = await ref.getDownloadURL();
        finalUrls.add(url);
      } else if (item is String) {
        finalUrls.add(item);
      }
    }

    data['photoUrls'] = finalUrls;

    await _firestore.collection('users').doc(uid).set(
      data,
      SetOptions(merge: true)
    );
  }

  Future<void> signOut() async => await _auth.signOut();
}
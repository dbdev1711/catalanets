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
        'edat': 18,
        'bio': '',
        'interessos': [],
        'photoUrls': [],
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
    XFile? imageFile,
  }) async {
    List<String> photoUrls = List<String>.from(data['photoUrls'] ?? []);

    if (imageFile != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('users').child(uid).child(fileName);

      final bytes = await imageFile.readAsBytes();
      await ref.putData(bytes);

      String url = await ref.getDownloadURL();
      photoUrls.add(url);
    }

    data['photoUrls'] = photoUrls;

    await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Future<bool> enviarLike(String toUid) async {
    final fromUid = _auth.currentUser?.uid;
    if (fromUid == null) return false;
    await _firestore.collection('likes').doc('${fromUid}_$toUid').set({
      'from': fromUid,
      'to': toUid,
      'timestamp': FieldValue.serverTimestamp(),
    });
    final matchDoc = await _firestore.collection('likes').doc('${toUid}_$fromUid').get();
    if (matchDoc.exists) {
      await _firestore.collection('matches').doc('${fromUid}_$toUid').set({
        'users': [fromUid, toUid],
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    }
    return false;
  }

  Future<void> bloquejarUsuari(String blockedUid) async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) return;
    await _firestore.collection('users').doc(currentUid).update({
      'bloquejats': FieldValue.arrayUnion([blockedUid]),
    });
  }

  Future<void> reportarUsuari({required String reportedUid, required String motiu}) async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) return;
    await _firestore.collection('reports').add({
      'from': currentUid,
      'reportedUser': reportedUid,
      'motiu': motiu,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> eliminarCompte() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final uid = user.uid;
    await _firestore.collection('users').doc(uid).delete();
    await user.delete();
  }

  Future<void> signOut() async => await _auth.signOut();
}
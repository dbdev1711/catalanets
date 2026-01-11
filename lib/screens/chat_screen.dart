import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class ChatScreen extends StatefulWidget {
  final UserModel otherUser;
  final String matchId;

  const ChatScreen({super.key, required this.otherUser, required this.matchId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final currentUid = FirebaseAuth.instance.currentUser?.uid;

  void _enviarMissatge() async {
    if (_messageController.text.trim().isEmpty) return;

    final text = _messageController.text.trim();
    _messageController.clear();

    await FirebaseFirestore.instance
        .collection('matches')
        .doc(widget.matchId)
        .collection('messages')
        .add({
      'senderId': currentUid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundImage: widget.otherUser.photoUrls.isNotEmpty
                  ? NetworkImage(widget.otherUser.photoUrls.first)
                  : null,
              child: widget.otherUser.photoUrls.isEmpty
                  ? const Icon(Icons.person, size: 18)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(widget.otherUser.nom),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('matches')
                  .doc(widget.matchId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error al carregar missatges"));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final msg = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    final isMe = msg['senderId'] == currentUid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.orange[400] : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(15),
                            topRight: const Radius.circular(15),
                            bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(15),
                          ),
                        ),
                        child: Text(
                          msg['text'] ?? "",
                          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Escriu un missatge...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.orange),
                  onPressed: _enviarMissatge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
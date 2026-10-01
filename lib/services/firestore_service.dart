import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream notes for logged-in user
  Stream<List<NoteModel>> getNotes(String userId) {
    return _db
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NoteModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Create Note
  Future<void> addNote(NoteModel note) async {
    await _db.collection('notes').add(note.toMap());
  }

  // Update Note
  Future<void> updateNote(NoteModel note) async {
    await _db.collection('notes').doc(note.id).update(note.toMap());
  }

  // Toggle Saved / Bookmark
  Future<void> toggleSaveNote(String noteId, bool currentSaved) async {
    await _db.collection('notes').doc(noteId).update({
      'isSaved': !currentSaved,
    });
  }

  // Delete Note
  Future<void> deleteNote(String noteId) async {
    await _db.collection('notes').doc(noteId).delete();
  }
}

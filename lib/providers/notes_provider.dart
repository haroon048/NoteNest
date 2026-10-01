import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/note_model.dart';

enum NoteSortOption { newest, oldest, alphabetical }

class NotesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<NoteModel> _notes = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isGridView = true;
  NoteSortOption _sortOption = NoteSortOption.newest;

  List<NoteModel> get notes => _notes;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isGridView => _isGridView;
  NoteSortOption get sortOption => _sortOption;

  // Toggle Grid / List view
  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  // Set Sort Option
  void setSortOption(NoteSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  // Update Search Query
  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  // Update Category Filter
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Filtered & Sorted Notes
  List<NoteModel> get filteredNotes {
    final list = _notes.where((note) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          note.title.toLowerCase().contains(_searchQuery) ||
          note.content.toLowerCase().contains(_searchQuery) ||
          note.category.toLowerCase().contains(_searchQuery);

      final matchesCategory =
          _selectedCategory == 'All' ||
          note.category.toLowerCase() == _selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();

    switch (_sortOption) {
      case NoteSortOption.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case NoteSortOption.oldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case NoteSortOption.alphabetical:
        list.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
    }

    return list;
  }

  // Bookmarked Notes
  List<NoteModel> get savedNotes {
    return _notes.where((note) => note.isSaved).toList();
  }

  // Category counts map
  Map<String, int> get categoryCounts {
    final counts = <String, int>{'All': _notes.length};
    for (final note in _notes) {
      counts[note.category] = (counts[note.category] ?? 0) + 1;
    }
    return counts;
  }

  // 1. Fetch Notes from Firestore
  Future<void> fetchNotes() async {
    final user = _auth.currentUser;
    if (user == null) {
      _notes = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .orderBy('createdAt', descending: true)
          .get();

      _notes = snapshot.docs
          .map((doc) => NoteModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching notes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Add New Note
  Future<void> addNote(
    String title,
    String content,
    String category,
    int colorHex,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final now = DateTime.now();
      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .add({
            'title': title,
            'content': content,
            'category': category,
            'colorHex': colorHex,
            'isSaved': false,
            'createdAt': FieldValue.serverTimestamp(),
          });

      final newNote = NoteModel(
        id: docRef.id,
        title: title,
        content: content,
        category: category,
        colorHex: colorHex,
        isSaved: false,
        createdAt: now,
      );

      _notes.insert(0, newNote);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding note: $e');
      rethrow;
    }
  }

  // 3. Update Note
  Future<void> updateNote(
    String noteId,
    String title,
    String content,
    String category,
    int colorHex,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final now = DateTime.now();
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(noteId)
          .update({
            'title': title,
            'content': content,
            'category': category,
            'colorHex': colorHex,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      final index = _notes.indexWhere((note) => note.id == noteId);
      if (index != -1) {
        _notes[index] = _notes[index].copyWith(
          title: title,
          content: content,
          category: category,
          colorHex: colorHex,
          updatedAt: now,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating note: $e');
      rethrow;
    }
  }

  // 4. Delete Note
  Future<void> deleteNote(String noteId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(noteId)
          .delete();

      _notes.removeWhere((note) => note.id == noteId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting note: $e');
      rethrow;
    }
  }

  // 5. Toggle Bookmark / Save
  Future<void> toggleSave(NoteModel note) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final newStatus = !note.isSaved;

    // Optimistic UI update
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(isSaved: newStatus);
      notifyListeners();
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(note.id)
          .update({'isSaved': newStatus});
    } catch (e) {
      // Revert if error
      if (index != -1) {
        _notes[index] = _notes[index].copyWith(isSaved: !newStatus);
        notifyListeners();
      }
      debugPrint('Error toggling save: $e');
      rethrow;
    }
  }
}

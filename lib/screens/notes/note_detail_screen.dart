import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/note_model.dart';
import '../../providers/notes_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import 'add_edit_note_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final NoteModel note;

  const NoteDetailScreen({super.key, required this.note});

  String _calculateReadTime(String text) {
    final words = text.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
    final minutes = (words / 200).ceil();
    return '$words words • ${minutes < 1 ? 1 : minutes} min read';
  }

  void _copyToClipboard(BuildContext context) {
    final fullText = '${note.title}\n\n${note.content}';
    Clipboard.setData(ClipboardData(text: fullText));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        title: const Text('Delete Note?'),
        content: const Text(
          'Are you sure you want to delete this note? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(88, 40),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      await context.read<NotesProvider>().deleteNote(note.id);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note deleted permanently'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep reference updated if note was modified or toggled
    final notesProvider = context.watch<NotesProvider>();
    final currentNote = notesProvider.notes.firstWhere(
      (n) => n.id == note.id,
      orElse: () => note,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final createdDateStr = DateFormat('MMMM d, yyyy  •  h:mm a').format(currentNote.createdAt);
    final categoryColor =
        AppColors.categoryColors[currentNote.category] ?? AppColors.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              currentNote.isSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              color: currentNote.isSaved ? AppColors.primary : null,
            ),
            tooltip: currentNote.isSaved ? 'Remove Bookmark' : 'Bookmark Note',
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<NotesProvider>().toggleSave(currentNote);
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 20),
            tooltip: 'Copy text',
            onPressed: () => _copyToClipboard(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            tooltip: 'Delete Note',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditNoteScreen(
                noteId: currentNote.id,
                initialTitle: currentNote.title,
                initialContent: currentNote.content,
                initialCategory: currentNote.category,
                initialColorHex: currentNote.colorHex,
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
        label: const Text(
          'Edit Note',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.screenHorizontalPadding,
          vertical: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category & Read Stats Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    currentNote.category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _calculateReadTime(currentNote.content),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Note Title
            SelectableText(
              currentNote.title,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                letterSpacing: -0.5,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 8),

            // Timestamps
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
                const SizedBox(width: 4),
                Text(
                  createdDateStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
                if (currentNote.updatedAt != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '• Edited',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 20),

            Divider(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),

            const SizedBox(height: 18),

            // Selectable Note Content
            SelectableText(
              currentNote.content.isEmpty
                  ? 'No additional content provided.'
                  : currentNote.content,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppColors.textPrimaryDark : const Color(0xFF334155),
                height: 1.7,
                fontStyle: currentNote.content.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),

            // Bottom space for FAB clearance
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}


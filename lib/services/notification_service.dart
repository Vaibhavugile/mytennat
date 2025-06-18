// services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  Stream<int> get unreadMatchesCountStream {
    _currentUser = _auth.currentUser;
    if (_currentUser == null) {
      return Stream.value(0); // No user, no unread matches
    }

    // Listen to matches where current user is a participant and has unread status
    return _firestore
        .collection('matches')
        .where('participants', arrayContains: _currentUser!.uid)
        .snapshots()
        .map((snapshot) {
      int unreadCount = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('readBy') && data['readBy'] is Map) {
          final Map<String, dynamic> readBy = Map<String, dynamic>.from(data['readBy']);
          if (readBy[_currentUser!.uid] == false) {
            unreadCount++;
          }
        }
      }
      return unreadCount;
    });
  }

  // Method to mark a match as read
  Future<void> markMatchAsRead(String matchId) async {
    _currentUser = _auth.currentUser;
    if (_currentUser == null) return;

    // Update the specific user's read status for this match
    await _firestore.collection('matches').doc(matchId).update({
      'readBy.${_currentUser!.uid}': true,
    });
  }
}
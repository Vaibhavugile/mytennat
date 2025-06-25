// screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:flutter/scheduler.dart'; // For post-frame callbacks

// Custom Colors for a modern look
const Color kPrimaryColor = Color(0xFF6B7280); // Softer Grey/Blue
const Color kAccentColor = Color(0xFF5CF694); // Vibrant Purple
const Color kLightGrey = Color(0xFFF3F4F6); // Light background for received messages
const Color kDarkGrey = Color(0xFF6B7280); // For text and icons
const Color kReadTickColor = Color(0xFF3B82F6); // Blue for read ticks

class ChatScreen extends StatefulWidget {
  final String chatPartnerId;
  final String chatPartnerName;
  final String? chatPartnerImageUrl;
  final String? chatRoomId; // Make it nullable

  const ChatScreen({
    Key? key,
    required this.chatPartnerId,
    required this.chatPartnerName,
    this.chatPartnerImageUrl,
    this.chatRoomId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  User? _currentUser;
  String? _chatRoomId;
  bool _showScrollToBottomButton = false; // New state for scroll button visibility

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _findOrCreateChatRoom();
    WidgetsBinding.instance.addObserver(this);

    // Listener for scroll button visibility
    _scrollController.addListener(() {
      if (_scrollController.position.pixels < _scrollController.position.maxScrollExtent - 200 && !_showScrollToBottomButton) {
        // If scrolled up significantly and button is not shown
        setState(() {
          _showScrollToBottomButton = true;
        });
      } else if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && _showScrollToBottomButton) {
        // If scrolled near bottom and button is shown
        setState(() {
          _showScrollToBottomButton = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _markVisibleMessagesAsRead();
    }
  }

  Future<void> _findOrCreateChatRoom() async {
    if (_currentUser == null) return;

    List<String> participants = [_currentUser!.uid, widget.chatPartnerId]..sort();
    final potentialChatRoomId = '${participants[0]}_${participants[1]}';

    DocumentSnapshot matchDoc = await _firestore.collection('matches').doc(potentialChatRoomId).get();

    if (matchDoc.exists && matchDoc.data() != null) {
      setState(() {
        _chatRoomId = (matchDoc.data() as Map<String, dynamic>)['chatRoomId'];
      });
      _markVisibleMessagesAsRead();
    } else {
      print('Error: Match document not found for chat room creation.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load chat. Please try again.')),
      );
      Navigator.of(context).pop();
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUser == null || _chatRoomId == null) {
      return;
    }

    String messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      await _firestore
          .collection('chats')
          .doc(_chatRoomId)
          .collection('messages')
          .add({
        'senderId': _currentUser!.uid,
        'receiverId': widget.chatPartnerId,
        'content': messageText,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
        'readBy': [_currentUser!.uid],
        'delivered': false, // Placeholder
      });

      await _firestore.collection('chats').doc(_chatRoomId).set(
        {
          'lastMessage': messageText,
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
          'participants': [_currentUser!.uid, widget.chatPartnerId],
        },
        SetOptions(merge: true),
      );

      _scrollController.animateTo(
        0.0, // Scroll to the top of the reversed list (latest message)
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  void _markMessageAsRead(String messageId) async {
    if (_currentUser == null || _chatRoomId == null) return;

    try {
      await _firestore
          .collection('chats')
          .doc(_chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({
        'readBy': FieldValue.arrayUnion([_currentUser!.uid]),
      });
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  void _markVisibleMessagesAsRead() {
    if (_chatRoomId == null || _currentUser == null) return;

    // Schedule the marking after the current frame to ensure messages are rendered
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _firestore
          .collection('chats')
          .doc(_chatRoomId)
          .collection('messages')
          .where('receiverId', isEqualTo: _currentUser!.uid)
          .limit(20) // Limit to a reasonable number to avoid too many writes
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          final messageData = doc.data();
          final List<dynamic> readByList = (messageData['readBy'] as List<dynamic>?) ?? [];
          if (!readByList.contains(_currentUser!.uid)) {
            _markMessageAsRead(doc.id);
          }
        }
      }).catchError((e) {
        print("Error fetching messages to mark as read: $e");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryColor, kAccentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            if (widget.chatPartnerImageUrl != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.chatPartnerImageUrl!),
                  radius: 20,
                ),
              ),
            Text(
              widget.chatPartnerName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {},
            tooltip: 'Audio Call',
          ),
          IconButton(
            icon: const Icon(Icons.video_call, color: Colors.white),
            onPressed: () {},
            tooltip: 'Video Call',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {},
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'view_profile',
                child: Text('View Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'block_user',
                child: Text('Block User'),
              ),
            ],
          ),
        ],
      ),
      body: _chatRoomId == null
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kAccentColor)))
          : Stack( // Use Stack to position the scroll-to-bottom button
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('chats')
                      .doc(_chatRoomId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kAccentColor)));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 60, color: kDarkGrey),
                            SizedBox(height: 15),
                            Text('Start your conversation! 🎉', style: TextStyle(fontSize: 18, color: kDarkGrey)),
                            SizedBox(height: 5),
                            Text('No messages yet. Send one to begin.', style: TextStyle(fontSize: 14, color: kDarkGrey)),
                          ],
                        ),
                      );
                    }

                    final messages = snapshot.data!.docs;

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(12.0),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final messageData = message.data() as Map<String, dynamic>; // Cast here
                        final bool isMe = messageData['senderId'] == _currentUser!.uid;
                        final Timestamp? timestamp = messageData['timestamp'] as Timestamp?;
                        final List<dynamic> readBy = messageData['readBy'] as List<dynamic>? ?? [];
                        final bool isRead = readBy.contains(widget.chatPartnerId) && isMe;

                        String timeFormatted = '';
                        DateTime? messageDateTime;
                        if (timestamp != null) {
                          messageDateTime = timestamp.toDate();
                          timeFormatted = DateFormat('hh:mm a').format(messageDateTime);
                        }

                        // Determine if a date separator is needed
                        bool showDateSeparator = false;
                        if (index == messages.length - 1) { // First message in reversed list is the oldest
                          showDateSeparator = true;
                        } else {
                          final prevMessage = messages[index + 1]; // Next message in reversed list is older
                          // Corrected line: Explicitly cast data() to Map<String, dynamic>
                          final prevTimestamp = (prevMessage.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                          if (messageDateTime != null && prevTimestamp != null) {
                            final prevDateTime = prevTimestamp.toDate();
                            if (messageDateTime.day != prevDateTime.day ||
                                messageDateTime.month != prevDateTime.month ||
                                messageDateTime.year != prevDateTime.year) {
                              showDateSeparator = true;
                            }
                          }
                        }

                        return Column(
                          children: [
                            if (showDateSeparator && messageDateTime != null)
                              _DateSeparator(date: messageDateTime),
                            Row(
                              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end, // Align avatar and bubble bottom
                              children: [
                                if (!isMe && widget.chatPartnerImageUrl != null)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(widget.chatPartnerImageUrl!),
                                      radius: 14, // Smaller avatar next to messages
                                    ),
                                  ),
                                _MessageBubble(
                                  message: messageData['content'],
                                  time: timeFormatted,
                                  isMe: isMe,
                                  isRead: isRead,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              _MessageInput(
                controller: _messageController,
                onSendMessage: _sendMessage,
              ),
            ],
          ),
          // Scroll to Bottom Button
          if (_showScrollToBottomButton)
            Positioned(
              bottom: 80.0, // Adjust position above the input field
              right: 20.0,
              child: FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(
                    0.0, // Scroll to the very bottom (top of reversed list)
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                  setState(() {
                    _showScrollToBottomButton = false;
                  });
                },
                backgroundColor: kAccentColor.withOpacity(0.9),
                mini: true, // Make it smaller
                child: const Icon(Icons.arrow_downward_rounded, color: Colors.white),
                shape: const CircleBorder(), // Ensure it's perfectly round
                elevation: 4,
              ),
            ),
        ],
      ),
    );
  }
}

// Extracted Message Bubble Widget
class _MessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe;
  final bool isRead;

  const _MessageBubble({
    Key? key,
    required this.message,
    required this.time,
    required this.isMe,
    required this.isRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      decoration: BoxDecoration(
        color: isMe ? kAccentColor.withOpacity(0.9) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(6),
          bottomRight: isMe ? const Radius.circular(6) : const Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            message,
            style: TextStyle(
              color: isMe ? Colors.white : kDarkGrey,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 11.0,
                  color: isMe ? Colors.white70 : Colors.grey[600],
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 4),
                Icon(
                  isRead ? Icons.done_all : Icons.done,
                  size: 15,
                  color: isRead ? kReadTickColor : (isMe ? Colors.white70 : Colors.grey[600]),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// New Date Separator Widget
class _DateSeparator extends StatelessWidget {
  final DateTime date;

  const _DateSeparator({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        DateFormat('MMMM d, y').format(date),
        style: const TextStyle(
          color: kDarkGrey,
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}


// Extracted Message Input Widget
class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendMessage;

  const _MessageInput({
    Key? key,
    required this.controller,
    required this.onSendMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: kPrimaryColor, size: 28),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Attachment functionality coming soon!')),
              );
            },
            tooltip: 'Attach File',
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: kLightGrey,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined, color: kPrimaryColor),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Emoji picker coming soon!')),
                    );
                  },
                  tooltip: 'Emoji',
                ),
              ),
              onSubmitted: (value) => onSendMessage(),
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.text,
              maxLines: null,
              minLines: 1,
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            decoration: const BoxDecoration(
              color: kAccentColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: onSendMessage,
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              tooltip: 'Send message',
            ),
          ),
        ],
      ),
    );
  }
}
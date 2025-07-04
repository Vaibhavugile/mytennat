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
  final String chatPartnerId; // The UID of the chat partner
  final String chatPartnerName;
  final String? chatPartnerImageUrl;
  final String? chatRoomId; // This might be null if it's a new chat, we will create it

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
  String? _chatRoomId; // This will hold the actual chat room ID, confirmed after creation/finding
  bool _showScrollToBottomButton = false;
  bool _isLoadingChat = true; // New state to indicate chat room loading/creation

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    WidgetsBinding.instance.addObserver(this);
    _initializeChatRoom(); // Call the new initialization method

    _scrollController.addListener(() {
      if (_scrollController.position.pixels < _scrollController.position.maxScrollExtent - 200 && !_showScrollToBottomButton) {
        setState(() {
          _showScrollToBottomButton = true;
        });
      } else if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && _showScrollToBottomButton) {
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

  // NEW: Function to find or create the chat room document
  Future<void> _initializeChatRoom() async {
    if (_currentUser == null) {
      print('[_initializeChatRoom] Current user is null. Cannot initialize chat.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in. Please log in again.')),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    // Determine a consistent chat room ID based on both UIDs
    List<String> participants = [_currentUser!.uid, widget.chatPartnerId];
    participants.sort(); // Sort to ensure consistent ID regardless of who initiated
    String generatedChatRoomId = participants.join('_'); // e.g., 'uid1_uid2'

    setState(() {
      _chatRoomId = widget.chatRoomId ?? generatedChatRoomId; // Use provided ID if available, else generate
    });

    print('[_initializeChatRoom] Initializing chat room. Proposed ID: $_chatRoomId');

    try {
      // Check if the chat room document already exists
      DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(_chatRoomId).get();

      if (!chatDoc.exists) {
        // If it doesn't exist, create it with initial data
        print('[_initializeChatRoom] Chat room $_chatRoomId does not exist. Creating...');
        await _firestore.collection('chats').doc(_chatRoomId).set({
          'createdAt': FieldValue.serverTimestamp(),
          'participants': participants, // Initialize with both UIDs
          'lastMessage': '',
          'lastMessageTimestamp': null,
          'lastMessageSenderId': '',
        });
        print('[_initializeChatRoom] Chat room $_chatRoomId created successfully.');
      } else {
        print('[_initializeChatRoom] Chat room $_chatRoomId already exists. Merging participants if needed.');
        // If it exists, ensure the participants array is correct (merge in case it was old or missing participants)
        await _firestore.collection('chats').doc(_chatRoomId).set(
          {
            'participants': FieldValue.arrayUnion(participants), // Ensure both UIDs are in the array
          },
          SetOptions(merge: true),
        );
        print('[_initializeChatRoom] Chat room $_chatRoomId participants ensured.');
      }
      _markVisibleMessagesAsRead(); // Mark messages as read after chat room is confirmed
    } catch (e) {
      print('[_initializeChatRoom] Error initializing chat room: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting up chat: $e')),
        );
        Navigator.of(context).pop();
      }
    } finally {
      setState(() {
        _isLoadingChat = false; // Chat room initialization complete
      });
    }
  }


  void _sendMessage() async {
    // Add these print statements at the very beginning to capture current state
    print('[_sendMessage] Attempting to send message...');
    print('[_sendMessage] Current User UID: ${_currentUser?.uid}');
    print('[_sendMessage] Chat Room ID: $_chatRoomId');
    print('[_sendMessage] Message Text: ${_messageController.text.trim()}');
    print('[_sendMessage] Chat Partner ID (receiver): ${widget.chatPartnerId}');


    if (_messageController.text.trim().isEmpty || _currentUser == null || _chatRoomId == null) {
      print('[_sendMessage] Pre-check failed: Message empty, currentUser null, or chatRoomId null. Aborting send.');
      return;
    }

    String messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      // Define the message data map here to print it before sending
      final Map<String, dynamic> messageData = {
        'senderId': _currentUser!.uid,
        'receiverId': widget.chatPartnerId,
        'content': messageText,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
        'readBy': [_currentUser!.uid],
        'delivered': false, // Placeholder
      };
      print('[_sendMessage] Message data being added: $messageData');

      await _firestore
          .collection('chats')
          .doc(_chatRoomId)
          .collection('messages')
          .add(messageData);

      print('[_sendMessage] Message added to subcollection successfully.');

      // Update the chat document with the last message and participants
      // This part is now redundant for 'participants' because it's handled in _initializeChatRoom,
      // but keeping it for 'lastMessage' and 'lastMessageTimestamp' for convenience.
      await _firestore.collection('chats').doc(_chatRoomId).set(
        {
          'lastMessage': messageText,
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
          // 'participants': [_currentUser!.uid, widget.chatPartnerId], // Removed from here as handled in _initializeChatRoom
          'lastMessageSenderId': _currentUser!.uid, // Add this to track last message sender
        },
        SetOptions(merge: true),
      );

      print('[_sendMessage] Chat document updated successfully (last message).');

      _scrollController.animateTo(
        0.0, // Scroll to the top of the reversed list (latest message)
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      print('[_sendMessage] Scroll animation initiated.');

    } catch (e) {
      print('[_sendMessage] *** ERROR SENDING MESSAGE: $e ***'); // More prominent error log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  void _markMessageAsRead(String messageId) async {
    print('[_markMessageAsRead] Attempting to mark message $messageId as read.');
    print('[_markMessageAsRead] Current User UID: ${_currentUser?.uid}');
    print('[_markMessageAsRead] Chat Room ID: $_chatRoomId');

    if (_currentUser == null || _chatRoomId == null) {
      print('[_markMessageAsRead] Pre-check failed: currentUser null or chatRoomId null. Aborting.');
      return;
    }

    try {
      await _firestore
          .collection('chats')
          .doc(_chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({
        'readBy': FieldValue.arrayUnion([_currentUser!.uid]),
      });
      print('[_markMessageAsRead] Successfully marked message $messageId as read.');
    } catch (e) {
      print('[_markMessageAsRead] Error marking message $messageId as read: $e'); // Added messageId to log
    }
  }

  void _markVisibleMessagesAsRead() {
    print('[_markVisibleMessagesAsRead] Checking for visible messages to mark as read...');
    print('[_markVisibleMessagesAsRead] Current User UID: ${_currentUser?.uid}');
    print('[_markVisibleMessagesAsRead] Chat Room ID: $_chatRoomId');


    if (_chatRoomId == null || _currentUser == null) {
      print('[_markVisibleMessagesAsRead] Pre-check failed: chatRoomId null or currentUser null. Aborting.');
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      print('[_markVisibleMessagesAsRead] Post-frame callback triggered. Fetching messages.');
      _firestore
          .collection('chats')
          .doc(_chatRoomId)
          .collection('messages')
          .where('receiverId', isEqualTo: _currentUser!.uid)
          .limit(20) // Consider increasing limit if many messages might be unread
          .get()
          .then((snapshot) {
        if (snapshot.docs.isEmpty) {
          print('[_markVisibleMessagesAsRead] No messages found for current user to mark as read.');
          return;
        }
        print('[_markVisibleMessagesAsRead] Found ${snapshot.docs.length} messages to check.');
        for (var doc in snapshot.docs) {
          final messageData = doc.data();
          final List<dynamic> readByList = (messageData['readBy'] as List<dynamic>?) ?? [];
          if (!readByList.contains(_currentUser!.uid)) {
            print('[_markVisibleMessagesAsRead] Message ${doc.id} not yet read by current user. Marking...');
            _markMessageAsRead(doc.id);
          } else {
            print('[_markVisibleMessagesAsRead] Message ${doc.id} already read by current user.');
          }
        }
      }).catchError((e) {
        print("[_markVisibleMessagesAsRead] Error fetching messages to mark as read: $e");
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
            if (widget.chatPartnerImageUrl != null && widget.chatPartnerImageUrl!.isNotEmpty) // Check for empty string too
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
      body: _isLoadingChat // Show loading indicator while chat room is being initialized
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kAccentColor)))
          : Stack(
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
                        final messageData = message.data() as Map<String, dynamic>;
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

                        bool showDateSeparator = false;
                        if (index == messages.length - 1) {
                          showDateSeparator = true;
                        } else {
                          final prevMessage = messages[index + 1];
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
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (!isMe && widget.chatPartnerImageUrl != null && widget.chatPartnerImageUrl!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(widget.chatPartnerImageUrl!),
                                      radius: 14,
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
          if (_showScrollToBottomButton)
            Positioned(
              bottom: 80.0,
              right: 20.0,
              child: FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                  setState(() {
                    _showScrollToBottomButton = false;
                  });
                },
                backgroundColor: kAccentColor.withOpacity(0.9),
                mini: true,
                child: const Icon(Icons.arrow_downward_rounded, color: Colors.white),
                shape: const CircleBorder(),
                elevation: 4,
              ),
            ),
        ],
      ),
    );
  }
}

// Extracted Message Bubble Widget (no changes needed)
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

// New Date Separator Widget (no changes needed)
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


// Extracted Message Input Widget (no changes needed)
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
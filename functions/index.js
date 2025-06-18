// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
// This allows your Cloud Function to interact with other Firebase services
admin.initializeApp();

// This Cloud Function will be triggered every time a new document is created
// in the Firestore path 'user_likes/{likerId}/likes/{likedUserId}'.
// This represents one user liking another.
exports.sendLikeNotification = functions.firestore
    .document('user_likes/{likerId}/likes/{likedUserId}')
    .onCreate(async (snapshot, context) => {
        // Extract the IDs of the user who performed the like (likerId)
        // and the user who was liked (likedUserId) from the Firestore path.
        const likerId = context.params.likerId;
        const likedUserId = context.params.likedUserId;

        console.log(`New like created: ${likerId} liked ${likedUserId}`);

        // Optional: Prevent a user from getting a notification if they liked their own profile.
        // This is generally good practice to avoid unnecessary notifications.
        if (likerId === likedUserId) {
            console.log('Self-like detected, skipping notification.');
            return null; // Exit the function gracefully
        }

        try {
            // --- Step 1: Get the profile of the person who was liked (the recipient of the notification) ---
            const likedUserDoc = await admin.firestore().collection('users').doc(likedUserId).get();
            if (!likedUserDoc.exists) {
                console.log(`Liked user profile not found for ${likedUserId}`);
                return null; // Cannot send notification if user doesn't exist
            }
            const likedUserData = likedUserDoc.data();
            // Retrieve the FCM (Firebase Cloud Messaging) token for the liked user's device.
            // This token is essential for sending targeted push notifications.
            const likedUserFcmToken = likedUserData.fcmToken;
            const likedUserDisplayName = likedUserData.displayName || 'Someone'; // Fallback name

            if (!likedUserFcmToken) {
                console.log(`No FCM token found for liked user ${likedUserId}. Cannot send notification.`);
                return null; // Cannot send notification without a token
            }

            // --- Step 2: Get the profile of the person who sent the like (the sender of the interaction) ---
            const likerDoc = await admin.firestore().collection('users').doc(likerId).get();
            const likerData = likerDoc.data();
            const likerDisplayName = likerData.displayName || 'A user'; // Fallback name


            // --- Step 3: Check for a mutual match ---
            // We check if the liked user has also liked the current user.
            const mutualLikeDoc = await admin.firestore()
                .collection('user_likes')
                .doc(likedUserId) // Look in the liked user's 'likes' subcollection
                .collection('likes')
                .doc(likerId) // Check if they liked the original liker
                .get();

            let notificationTitle;
            let notificationBody;
            let dataPayload = {}; // Custom data to send with the notification

            if (mutualLikeDoc.exists) {
                // If a mutual like is found, it's a MATCH!
                notificationTitle = '🎉 It\'s a Match!';
                notificationBody = `${likerDisplayName} also liked you! Start chatting now.`;
                dataPayload = {
                    type: 'match', // Custom type to handle in Flutter app
                    senderId: likerId,
                    chatPartnerId: likerId, // The ID of the person they matched with
                    chatPartnerName: likerDisplayName,
                    // Reconstruct the chatRoomId using sorted UIDs for consistency
                    chatRoomId: [likerId, likedUserId].sort().join('_'),
                };
            } else {
                // No mutual like yet, just a regular like notification
                notificationTitle = '❤️ New Like!';
                notificationBody = `${likerDisplayName} liked your profile.`;
                dataPayload = {
                    type: 'like', // Custom type
                    senderId: likerId,
                    // You might choose to send less data for a simple like notification
                };
            }

            // --- Step 4: Construct and Send the FCM Message ---
            const message = {
                notification: {
                    title: notificationTitle,
                    body: notificationBody,
                },
                data: dataPayload, // This is where you pass custom data to your app
                token: likedUserFcmToken, // The device token to send the notification to
            };

            // Send the message using the Firebase Admin SDK
            const response = await admin.messaging().send(message);
            console.log('Successfully sent message:', response);
            return { success: true, response: response };

        } catch (error) {
            console.error('Error sending notification:', error);
            // Important: If you return null here, Firebase will retry the function if it's an unhandled error.
            // Returning a structured error can be useful for logging.
            return { success: false, error: error.message };
        }
    });
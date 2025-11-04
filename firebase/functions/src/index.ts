import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as express from 'express';
import * as cors from 'cors';

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();

// Initialize Express app
const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).send('Katya AI REChain Mesh API is running');
});

// User Profile Endpoints
app.get('/users/:userId', async (req, res) => {
  try {
    const userDoc = await db.collection('users').doc(req.params.userId).get();
    if (!userDoc.exists) {
      return res.status(404).send('User not found');
    }
    return res.status(200).json(userDoc.data());
  } catch (error) {
    console.error('Error getting user:', error);
    return res.status(500).send('Internal server error');
  }
});

// Mesh Network Endpoints
app.post('/mesh/message', async (req, res) => {
  try {
    const { senderId, recipientIds, message, type = 'text' } = req.body;
    
    if (!senderId || !message) {
      return res.status(400).send('Missing required fields');
    }

    const messageData = {
      senderId,
      recipientIds: Array.isArray(recipientIds) ? recipientIds : [],
      message,
      type,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      status: 'sent'
    };

    const docRef = await db.collection('meshMessages').add(messageData);
    
    // TODO: Add push notification logic here
    
    return res.status(201).json({ id: docRef.id, ...messageData });
  } catch (error) {
    console.error('Error sending message:', error);
    return res.status(500).send('Failed to send message');
  }
});

// Export the API as a Firebase Cloud Function
export const api = functions.https.onRequest(app);

// Firestore Triggers
export const onUserCreated = functions.auth.user().onCreate(async (user) => {
  const userData = {
    uid: user.uid,
    email: user.email,
    displayName: user.displayName || '',
    photoURL: user.photoURL || '',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    lastSeen: admin.firestore.FieldValue.serverTimestamp(),
    status: 'online',
    deviceInfo: {}
  };

  await db.collection('users').doc(user.uid).set(userData, { merge: true });
  console.log(`User created: ${user.uid}`);
});

// Scheduled Functions
export const cleanUpOldMessages = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    const snapshot = await db
      .collection('meshMessages')
      .where('timestamp', '<', thirtyDaysAgo)
      .get();
    
    const batch = db.batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });
    
    await batch.commit();
    console.log(`Deleted ${snapshot.size} old messages`);
    return null;
  });

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionsCRUD {
  CollectionReference subscriptionCollection =
      FirebaseFirestore.instance.collection('subscription');

  Stream<QuerySnapshot> fetchSubscriptions() {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return subscriptionCollection
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Future<void> subscribe(String categoryId, String categoryName) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      await subscriptionCollection.add({
        'userId': userId,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'timestamp': Timestamp.now(),
      });
      print("Subscribed successfully");
    } catch (e) {
      print("Error subscribing: $e");
    }
  }

  Future<void> unsubscribe(String subscriptionId) async {
    try {
      await subscriptionCollection.doc(subscriptionId).delete();
      print("Unsubscribed successfully");
    } catch (e) {
      print("Error unsubscribing: $e");
    }
  }
}

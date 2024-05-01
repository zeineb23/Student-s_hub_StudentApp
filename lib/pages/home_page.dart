import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_7/components/app_bar_drawer.dart';
import 'package:flutter_application_7/pages/login_page.dart';
import 'package:flutter_application_7/pages/messages_page.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key});

  final User? user = FirebaseAuth.instance.currentUser;

  final CollectionReference categoryCollection =
      FirebaseFirestore.instance.collection('categorie');

  final CollectionReference subscriptionCollection =
      FirebaseFirestore.instance.collection('subscription');

  Stream<QuerySnapshot> fetchCategories() {
    return categoryCollection.snapshots();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        user: FirebaseAuth.instance.currentUser,
        signOut: () {
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        },
      ),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Mes abonnements',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: fetchSubscriptions(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> subscriptionSnapshot) {
                if (subscriptionSnapshot.hasError) {
                  return Text('Error: ${subscriptionSnapshot.error}');
                }

                if (subscriptionSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: subscriptionSnapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data =
                        subscriptionSnapshot.data!.docs[index].data()
                            as Map<String, dynamic>;
                    String subscriptionId =
                        subscriptionSnapshot.data!.docs[index].id;
                    String categoryId = data['categoryId'];
                    String categoryName = data['categoryName'];
                    Timestamp? timestamp = data['timestamp'] as Timestamp?;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessagesPage(
                              categoryId: categoryId,
                              categoryName: categoryName,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 3,
                        margin: EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: ListTile(
                          title: Text(categoryName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Subscribed on: ${timestamp?.toDate() ?? 'Unknown'}'),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (BuildContext context) {
                              return [
                                PopupMenuItem(
                                  child: Text('Unsubscribe'),
                                  value: 'unsubscribe',
                                ),
                              ];
                            },
                            onSelected: (value) {
                              if (value == 'unsubscribe') {
                                unsubscribe(subscriptionId);
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Subscribe to Category'),
                    content: StreamBuilder<QuerySnapshot>(
                      stream: fetchCategories(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> categorySnapshot) {
                        if (categorySnapshot.hasError) {
                          return Text('Error: ${categorySnapshot.error}');
                        }

                        if (categorySnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        return SingleChildScrollView(
                          child: Column(
                            children: categorySnapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              Map<String, dynamic> data =
                                  document.data() as Map<String, dynamic>;
                              String categoryId = document.id;
                              String categoryName = data['nom_cat'];

                              return ListTile(
                                title: Text(categoryName),
                                onTap: () {
                                  subscribe(categoryId, categoryName);
                                  Navigator.of(context).pop();
                                },
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
            child: Text('Subscribe to Category'),
          ),
        ],
      ),
    );
  }
}

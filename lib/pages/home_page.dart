import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_7/components/app_bar_drawer.dart';
import 'package:flutter_application_7/pages/login_page.dart';
import 'package:flutter_application_7/pages/messages_page.dart';
import 'package:flutter_application_7/services/categories.dart';
import 'package:flutter_application_7/services/subscriptions.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;

  final CategoriesCRUD _categoriesCRUD = CategoriesCRUD();

  final SubscriptionsCRUD _subscriptionsCRUD = SubscriptionsCRUD();

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
              stream: _subscriptionsCRUD.fetchSubscriptions(),
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
                                _subscriptionsCRUD.unsubscribe(subscriptionId);
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
                      stream: _categoriesCRUD.fetchCategories(),
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
                                  _subscriptionsCRUD.subscribe(
                                      categoryId, categoryName);
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

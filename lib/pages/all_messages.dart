import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_7/components/app_bar_drawer.dart';
import 'package:intl/intl.dart';

class AllMessagesPage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  AllMessagesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        user: FirebaseAuth.instance.currentUser,
        signOut: () {
          FirebaseAuth.instance.signOut();
        },
      ),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          const SizedBox(height: 20), // Add some space at the top
          const Center(
            // Center the title
            child: Text(
              "Toutes les catégories",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20), // Add some space below the title
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categorie')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> categoryData =
                        document.data() as Map<String, dynamic>;

                    return FutureBuilder<QuerySnapshot>(
                      future: document.reference.collection('messages').get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> messagesSnapshot) {
                        if (messagesSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors
                                    .grey[200], // Couleur de fond de la bande
                                borderRadius: BorderRadius.circular(
                                    8), // Bord arrondi de la bande
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Catégorie: ${categoryData['nom_cat']}"),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      _showNewMessageDialog(context,
                                          document.id, categoryData['nom_cat']);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                                height:
                                    10), // Espace entre la bande et la liste des messages
                            ListView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: messagesSnapshot.data!.docs
                                  .map((DocumentSnapshot messageDocument) {
                                Map<String, dynamic> messageData =
                                    messageDocument.data()
                                        as Map<String, dynamic>;

                                return ListTile(
                                  title: Text(messageData['message']),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${messageData['message']}'),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Date de publication: ${DateFormat('yyyy-MM-dd HH:mm').format(messageData['timestamp'].toDate())}', // Date de publication
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const Divider(),
                          ],
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool isNewMessage(Timestamp timestamp) {
    DateTime currentDate = DateTime.now();

    DateTime messageDate = timestamp.toDate();

    int differenceInDays = currentDate.difference(messageDate).inDays;

    return differenceInDays <= 2;
  }

  String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _showNewMessageDialog(
      BuildContext context, String categoryId, String categoryName) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Abonnez-vous"),
          content: Text("Voulez vous s'inscrire à " + categoryName),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                // Ajouter subscription
                FirebaseFirestore.instance.collection('subscription').add({
                  'userId': userId,
                  'categoryId': categoryId,
                  'categoryName': categoryName,
                  'timestamp': Timestamp.now(),
                });

                Navigator.of(context).pop();
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
}

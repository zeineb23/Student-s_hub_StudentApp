import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesCRUD {
  final CollectionReference categoryCollection =
      FirebaseFirestore.instance.collection('categorie');

  Stream<QuerySnapshot> fetchCategories() {
    return categoryCollection.snapshots();
  }
}

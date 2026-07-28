import 'package:cloud_firestore/cloud_firestore.dart';

/// Antarmuka sumber data jarak jauh untuk Firebase Firestore.
abstract class RemoteFirestoreDataSource {
  Future<void> createDocument(String collection, String documentId, Map<String, dynamic> data);
  Future<void> updateDocument(String collection, String documentId, Map<String, dynamic> data);
  Future<void> deleteDocument(String collection, String documentId);
  Future<Map<String, dynamic>?> getDocument(String collection, String documentId);
}

/// Implementasi [RemoteFirestoreDataSource] menggunakan Firebase Firestore SDK.
class RemoteFirestoreDataSourceImpl implements RemoteFirestoreDataSource {
  final FirebaseFirestore _firestore;

  RemoteFirestoreDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createDocument(String collection, String documentId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(documentId).set(data);
  }

  @override
  Future<void> updateDocument(String collection, String documentId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(documentId).update(data);
  }

  @override
  Future<void> deleteDocument(String collection, String documentId) async {
    await _firestore.collection(collection).doc(documentId).delete();
  }

  @override
  Future<Map<String, dynamic>?> getDocument(String collection, String documentId) async {
    final doc = await _firestore.collection(collection).doc(documentId).get();
    return doc.data();
  }
}

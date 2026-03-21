import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreMapper {
  const FirestoreMapper._();

  static DateTime? toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static Timestamp? toTimestamp(DateTime? value) {
    if (value == null) return null;
    return Timestamp.fromDate(value);
  }
}

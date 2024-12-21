import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_order/src/model/reservation_model.dart';

class FirebaseChooseTableService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<bool> chooseTable(
      String restaurantId, String floorId, String tableId) async {
    try {
      final restaurantRef =
          _firestore.collection('restaurants').doc(restaurantId);
      final floorRef = restaurantRef.collection('floors').doc(floorId);
      final tableRef = floorRef.collection('tables').doc(tableId);
      final tableSnapshot = await tableRef.get();

      if (tableSnapshot.data()!['state'] == 1 &&
          tableSnapshot.data()!['userId'] != uid) {
        return false;
      } else if (tableSnapshot.data()!['state'] == 2) {
        return false;
      } else if (tableSnapshot.data()!['state'] == 1 &&
          tableSnapshot.data()!['userId'] == uid) {
        await cancelChooseTable(restaurantId, floorId, tableId);
        return true;
      } else if (tableSnapshot.data()!['state'] == 0) {
        await tableRef.update({
          'state': 1,
          'userId': uid,
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error choosing table: $e');
      return false;
    }
  }

  Future<bool> cancelChooseTable(
      String restaurantId, String floorId, String tableId) async {
    try {
      final restaurantRef =
          _firestore.collection('restaurants').doc(restaurantId);
      final floorRef = restaurantRef.collection('floors').doc(floorId);
      final tableRef = floorRef.collection('tables').doc(tableId);
      final tableSnapshot = await tableRef.get();

      if (tableSnapshot.data()!['state'] == 1 &&
          tableSnapshot.data()!['userId'] == uid) {
        await tableRef.update({
          'state': 0,
          'userId': '',
        });
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error canceling table: $e');
      return false;
    }
  }

  Future<String?> confirmChooseTable(
    String restaurantId,
    String floorId,
    String tableId,
    DateTime reservationDate,
    TimeOfDay startTime,
    TimeOfDay endTime,
    String additionalRequest,
  ) async {
    try {
      final restaurantRef =
          _firestore.collection('restaurants').doc(restaurantId);
      final floorRef = restaurantRef.collection('floors').doc(floorId);
      final tableRef = floorRef.collection('tables').doc(tableId);
      final tableSnapshot = await tableRef.get();

      if (tableSnapshot.data()!['state'] == 1 &&
          tableSnapshot.data()!['userId'] == uid) {
        ReservationModel reservationModel = ReservationModel(
          userId: uid,
          reservationDate: Timestamp.fromDate(reservationDate),
          startTime: Timestamp.fromDate(DateTime(
              reservationDate.year,
              reservationDate.month,
              reservationDate.day,
              startTime.hour,
              startTime.minute)),
          endTime: Timestamp.fromDate(DateTime(
              reservationDate.year,
              reservationDate.month,
              reservationDate.day,
              startTime.hour,
              startTime.minute)),
          status: 'Pending',
          notes: additionalRequest,
          createdAt: Timestamp.now(),
        );
        DocumentReference reservationRef = await tableSnapshot.reference.collection('reservations').add(
              reservationModel.toFirestore(),
            );
        await tableRef.update({
          'state': 2,
        });
        return reservationRef.id;
      }
      return null;
    } catch (e) {
      debugPrint('Error confirming table: $e');
      return null;
    }
  }
}

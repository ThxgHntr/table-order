import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_order/src/model/reservation_model.dart';
import 'package:table_order/src/utils/toast_utils.dart';

class FirebaseChooseTableService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> chooseTable(
      String restaurantId, String floorId, String tableId) async {
    final restaurantRef =
        _firestore.collection('restaurants').doc(restaurantId);
    final floorRef = restaurantRef.collection('floors').doc(floorId);
    final tableRef = floorRef.collection('tables').doc(tableId);
    final tableSnapshot = await tableRef.get();

    if (tableSnapshot.data()!['state'] == 1 &&
        tableSnapshot.data()!['userId'] != uid) {
      // toast
      showToast('Bàn đang được chọn');
    } else if (tableSnapshot.data()!['state'] == 2 &&
        tableSnapshot.data()!['userId'] != uid) {
      // toast
      showToast('Bàn đã được chọn');
    } else if (tableSnapshot.data()!['state'] == 0) {
      await tableRef.update({
        'state': 1,
        'userId': uid,
      });
    }
  }

  Future<void> cancelChooseTable(
      String restaurantId, String floorId, String tableId) async {
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
    }
  }

  Future<void> confirmChooseTable(
    String restaurantId,
    String floorId,
    String tableId,
    DateTime reservationDate,
    TimeOfDay startTime,
    TimeOfDay endTime,
    String additionalRequest,
  ) async {
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
      await tableSnapshot.reference.collection('reservations').add(
            reservationModel.toFirestore(),
          );
      await tableRef.update({
        'state': 2,
      });
    }
  }
}

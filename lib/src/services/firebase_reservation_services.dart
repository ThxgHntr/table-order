import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_order/src/model/reservation_model.dart';

class FirebaseReservationServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<List<ReservationModel>> getReservationListForUser() async {
    try {
      final query = _firestore
          .collectionGroup('reservations')
          .where('userId', isEqualTo: uid);

      final querySnapshot = await query.get();
      final reservationData = querySnapshot.docs
          .map((e) => ReservationModel.fromFirestore(e))
          .toList();

      return reservationData;
    } catch (e) {
      debugPrint('Error getting reservations: $e');
      return [];
    }
  }

  Future<ReservationModel?> getReservation(String reservationId) async {
    try {
      final reservationRef =
          _firestore.collection('reservations').doc(reservationId);
      final reservationSnapshot = await reservationRef.get();
      return ReservationModel.fromFirestore(reservationSnapshot);
    } catch (e) {
      debugPrint('Error getting reservation: $e');
      return null;
    }
  }
}

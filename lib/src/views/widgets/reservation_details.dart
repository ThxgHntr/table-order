import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReservationDetails extends StatelessWidget {
  final String restaurantName;
  final String floorName;
  final String tableName;
  final int seats;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String additionalRequest;

  const ReservationDetails({
    super.key,
    required this.restaurantName,
    required this.floorName,
    required this.tableName,
    required this.seats,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.additionalRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0), // Increase padding around the card
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurantName,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailText('Tầng:'),
                        const SizedBox(height: 10.0),
                        _buildDetailText('Mã bàn:'),
                        const SizedBox(height: 10.0),
                        _buildDetailText('Ngày:'),
                        const SizedBox(height: 10.0),
                        _buildDetailText('Từ:'),
                        const SizedBox(height: 10.0),
                        _buildDetailText('Đến:'),
                        const SizedBox(height: 10.0),
                        _buildDetailText('Yêu cầu bổ sung:'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailValue(floorName),
                        const SizedBox(height: 10.0),
                        _buildDetailValue(tableName),
                        const SizedBox(height: 10.0),
                        _buildDetailValue(
                            DateFormat('dd/MM/yyyy').format(date)),
                        const SizedBox(height: 10.0),
                        _buildDetailValue(startTime.format(context)),
                        const SizedBox(height: 10.0),
                        _buildDetailValue(endTime.format(context)),
                        const SizedBox(height: 10.0),
                        _buildDetailValue(additionalRequest, isWrapped: true),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildDetailValue(String value, {bool isWrapped = false}) {
    return isWrapped
        ? Text(
            value,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 5,
          )
        : Text(
            value,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
            ),
          );
  }
}

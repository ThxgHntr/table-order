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
      padding: const EdgeInsets.only(
          left: 20, right: 20, bottom: 20), // Increase padding around the card
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tên nhà hàng: $restaurantName',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailText('Tầng:'),
                        const SizedBox(height: 10),
                        _buildDetailText('Mã bàn:'),
                        const SizedBox(height: 10),
                        _buildDetailText('Ngày:'),
                        const SizedBox(height: 10),
                        _buildDetailText('Từ:'),
                        const SizedBox(height: 10),
                        _buildDetailText('Đến:'),
                        const SizedBox(height: 10),
                        _buildDetailText('Yêu cầu bổ sung:'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailValue(floorName),
                        const SizedBox(height: 10),
                        _buildDetailValue(tableName),
                        const SizedBox(height: 10),
                        _buildDetailValue(
                            DateFormat('dd/MM/yyyy').format(date)),
                        const SizedBox(height: 10),
                        _buildDetailValue(startTime.format(context)),
                        const SizedBox(height: 10),
                        _buildDetailValue(endTime.format(context)),
                        const SizedBox(height: 10),
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
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildDetailValue(String value, {bool isWrapped = false}) {
    return Text(
      value,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      overflow: isWrapped ? TextOverflow.ellipsis : TextOverflow.visible,
      maxLines: isWrapped ? 5 : null,
    );
  }
}

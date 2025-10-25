import 'package:flutter/material.dart';

class DonationRow extends StatelessWidget {
  final String donor;
  final String amount;
  final String date;
  final String status;
  final String transactionId;

  const DonationRow({
    super.key,
    required this.donor,
    required this.amount,
    required this.date,
    required this.status,
    required this.transactionId,
  });

  Color _statusColor() {
    final statusLower = status.toLowerCase();
    if (statusLower == "completed" || statusLower == "success") {
      return Colors.green;
    } else if (statusLower == "pending") {
      return Colors.orange;
    } else if (statusLower == "failed" || statusLower == "cancelled") {
      return Colors.red;
    }
    return Colors.grey;
  }

  String _formatStatus(String status) {
    if (status.isEmpty) return status;
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.withAlpha(26),
            child: Text(
              donor.isNotEmpty ? donor[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donor,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transactionId,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor().withAlpha((_statusColor().a * 255.0 * 0.1).round() & 0xff),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatStatus(status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _statusColor(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
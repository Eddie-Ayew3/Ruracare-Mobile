import 'package:flutter/material.dart';

class CampaignCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int progress; // 0 - 100
  final String change;

  const CampaignCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black12.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey[200],
              color: Colors.blue,
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 12),

          // Progress text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$progress% complete",
                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
              Text(change,
                  style: const TextStyle(fontSize: 14, color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }
}

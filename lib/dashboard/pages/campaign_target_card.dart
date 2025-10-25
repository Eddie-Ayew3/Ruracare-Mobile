import 'package:flutter/material.dart';
import 'package:ruracare/services/models.dart';

class CampaignTargetCard extends StatelessWidget {
  final TeamDetailed team;

  const CampaignTargetCard({
    super.key,
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    final progress = team.fundsRaised != null && team.fundRaisingGoal > 0
        ? (team.fundsRaised! / team.fundRaisingGoal).clamp(0.0, 1.0)
        : 0.0;
    
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campaign Header
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${team.participants ?? 0} members',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.7 ? Colors.green : Colors.blue,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Progress Text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '${_formatCurrency(team.fundsRaised?.toDouble() ?? 0)} of ${_formatCurrency(team.fundRaisingGoal.toDouble())}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Time Remaining
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 18,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 6),
              Text(
                _getTimeRemaining(team.createTime),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                'View Details',
                style: TextStyle(
                  color: Colors.blue.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.blue.shade600,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return 'GHS ${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  String _getTimeRemaining(String createTime) {
    try {
      final startDate = DateTime.parse(createTime);
      // Assuming a campaign lasts for 30 days from creation
      final endDate = startDate.add(const Duration(days: 30));
      final now = DateTime.now();
      final difference = endDate.difference(now);
      
      if (difference.isNegative) {
        return 'Ended';
      }
      
      if (difference.inDays > 0) {
        return '${difference.inDays} days left';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours left';
      } else {
        return 'Less than an hour left';
      }
    } catch (e) {
      return 'Ongoing';
    }
  }
}
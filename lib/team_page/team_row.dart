import 'package:flutter/material.dart';

class TeamRow extends StatelessWidget {
  final String teamName;
  final String cause;
  final int stepGoal;
  final String fundraisingGoal;
  final int participants;
  final String status;
  final VoidCallback onView;
  final VoidCallback onDelete;

  const TeamRow({
    super.key,
    required this.teamName,
    required this.cause,
    required this.stepGoal,
    required this.fundraisingGoal,
    required this.participants,
    required this.status,
    required this.onView,
    required this.onDelete,
  });

  Color _statusColor() {
    if (status.toLowerCase() == "active") return Colors.green;
    if (status.toLowerCase() == "pending") return Colors.orange;
    if (status.toLowerCase() == "completed") return Colors.blue;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Add this to prevent overflow
        children: [
          // Team Name Row
          Row(
            children: [
              Expanded(
                child: Text(
                  teamName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2196F3), // Updated to match theme
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4), // Reduced spacing

          // Cause and Details
          Text(
            cause,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 12), // Reduced spacing

          // Responsive layout for smaller screens
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                // Mobile layout - vertical stacking
                return _buildMobileLayout();
              } else {
                // Desktop layout - horizontal row
                return _buildDesktopLayout();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 60, // Ensure minimum height for the row
      ),
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Center(
            child: _buildDetailColumn(
              value: "$stepGoal steps",
              label: "Step Goal",
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: _buildDetailColumn(
              value: fundraisingGoal,
              label: "Fundraising Goal",
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: _buildDetailColumn(
              value: "$participants people",
              label: "Participants",
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(child: _buildStatusColumn()),
        ),
        Expanded(
          flex: 1,
          child: Center(child: _buildActionsColumn()),
        ),
      ],
    ),);
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min, // Prevent taking more space than needed
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildDetailColumn(
                  value: "$stepGoal steps",
                  label: "Step Goal",
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildDetailColumn(
                  value: fundraisingGoal,
                  label: "Fundraising Goal",
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildDetailColumn(
                  value: "$participants people",
                  label: "Participants",
                ),
              ),
            ),
            Expanded(
              child: Center(child: _buildStatusColumn()),
            ),
            Expanded(
              child: Center(child: _buildActionsColumn()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _statusColor().withAlpha((_statusColor().a * 255.0 * 0.1).round() & 0xff),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _statusColor(),
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Status",
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildActionsColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.visibility, size: 20),
          onPressed: onView,
          color: Colors.blue,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(height: 4),
        const Text(
          "Actions",
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDetailColumn({
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
      ],
    );
  }
}
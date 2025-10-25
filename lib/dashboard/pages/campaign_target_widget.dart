import 'package:flutter/material.dart';
import 'package:ruracare/services/api_service.dart';
import 'package:ruracare/services/models.dart';
import 'campaign_target_card.dart';

class CampaignTargetWidget extends StatefulWidget {
  const CampaignTargetWidget({super.key});

  @override
  State<CampaignTargetWidget> createState() => _CampaignTargetWidgetState();
}

class _CampaignTargetWidgetState extends State<CampaignTargetWidget> {
  final ApiService _apiService = ApiService();
  late final Future<UserTeamsDetailed?> _userTargetsFuture = _getUserTargets();

  @override
  void initState() {
    super.initState();
    // Future is now initialized with the field declaration
  }

  Future<UserTeamsDetailed?> _getUserTargets() async {
    try {
      debugPrint('Fetching user targets...');
      final targets = await _apiService.getUserTeamsDetailed();
      debugPrint('Targets response: $targets');
      debugPrint('Number of targets: ${targets.allTeams.length}');
      if (targets.allTeams.isNotEmpty) {
        debugPrint('First target: ${targets.allTeams.first.toJson()}');
      }
      return targets;
    } catch (e, stackTrace) {
      debugPrint('Error getting user targets: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow; // Rethrow the error to be handled by the caller
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: FutureBuilder<UserTeamsDetailed?>(
        future: _userTargetsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingCard();
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.allTeams.isEmpty) {
            return _buildNoTargetsCard();
          }

          final teams = snapshot.data!;
          return _buildHorizontalScroll(teams);
        },
      ),
    );
  }

  Widget _buildHorizontalScroll(UserTeamsDetailed teams) {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: teams.allTeams.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index == teams.allTeams.length - 1 ? 0 : 12,
              left: index == 0 ? 0 : 4,
            ),
            child: CampaignTargetCard(team: teams.allTeams[index]),
          );
        },
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildNoTargetsCard() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha((Colors.blue.a * 255.0 * 0.1).round() & 0xff),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.fitness_center, color: Colors.blue, size: 24),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No active campaigns',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Join or create a team to get started!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
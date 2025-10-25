import 'package:flutter/material.dart';
import 'package:ruracare/services/api_service.dart';
import 'package:ruracare/services/models.dart';

class TeamList extends StatefulWidget {
  final String token;
  final String userId;

  const TeamList({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  TeamListState createState() => TeamListState();
}

class TeamListState extends State<TeamList> {
  late final ApiService _apiService;
  late Future<UserTeamsDetailed> _teamsFuture;
  bool _isLoading = true;
  bool _isRefreshing = false;
  
  @override
  void initState() {
    super.initState();
    _initializeTeams();
  }
  
  void _initializeTeams() {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _isRefreshing = true;
      });
    }
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      // Get the auth token first
      final token = await _apiService.getAuthToken();
      if (token == null) {
        // Handle case where there's no token (user not logged in)
        if (mounted) {
          // You might want to navigate to login screen or show an error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to view teams')),
          );
        }
        return;
      }
      
      // Use a separate variable to store the future to avoid unnecessary rebuilds
      final teamsFuture = _apiService.getUserTeamsDetailed().then((teamsData) {
        if (mounted) {
          setState(() {
            _teamsFuture = Future.value(teamsData);
          });
        }
        return teamsData;
      }).catchError((error) {
        _handleError(error);
        throw error;
      });
      
      // Set the future in state only once
      if (mounted) {
        setState(() {
          _teamsFuture = teamsFuture;
        });
      }
      
      // Wait for the future to complete to handle loading states
      await teamsFuture;
      
    } catch (e) {
      _handleError(e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }
  
  void _handleError(dynamic error) {
    if (!mounted) return;
    
    String errorMessage = 'Failed to load teams';
    if (error.toString().contains('401')) {
      errorMessage = 'Session expired. Please log in again.';
      // Optionally navigate to login
      // if (mounted) {
      //   Navigator.pushReplacementNamed(context, '/login');
      //   return;
      // }
    } else if (error.toString().contains('No internet')) {
      errorMessage = 'No internet connection';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$errorMessage: ${error.toString()}'),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _initializeTeams,
        ),
      ),
    );
  }
  
  Future<void> _refreshTeams() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });
    await _loadTeams();
  }

  void _createNewTeam() {
    // Navigate to create team screen
    // Navigator.pushNamed(context, '/create-team');
  }

  void _joinTeam() {
    // Navigate to join team screen
    // Navigator.pushNamed(context, '/join-team');
  }

  Widget _buildTeamSection(List<TeamDetailed> teams, String title, IconData icon, Color color) {
    if (teams.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  teams.length.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Teams List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: teams.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final team = teams[index];
            return _buildTeamCard(team, color);
          },
        ),
        
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTeamCard(TeamDetailed team, Color color) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Calculate progress - using fundsRaised for fundraising and assuming steps progress
    final fundsRaised = team.fundsRaised ?? 0.0;
    final fundraisingGoal = team.fundRaisingGoal.toDouble();
    final currentSteps = 0.0; // You'll need to get actual current steps from your API
    final stepsGoal = team.stepsGoal.toDouble();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to team details
            // Navigator.pushNamed(context, '/team-details', arguments: team.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Team Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          team.name[0].toUpperCase(),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Team Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            team.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onBackground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (team.story != null && team.story!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                team.story!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Chevron
                    Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Goals Progress
                _buildGoalProgress(
                  label: 'Fundraising',
                  current: fundsRaised,
                  goal: fundraisingGoal,
                  prefix: 'GHS ',
                  color: Colors.green,
                ),
                
                const SizedBox(height: 12),
                
                _buildGoalProgress(
                  label: 'Steps',
                  current: currentSteps,
                  goal: stepsGoal,
                  suffix: ' steps',
                  color: Colors.blue,
                ),
                
                const SizedBox(height: 16),
                
                // Footer Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Members
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 16,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          team.participants != null ? '${team.participants} members' : 'No members',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: team.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        team.isActive ? 'Active' : 'Inactive',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: team.isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalProgress({
    required String label,
    required double current,
    required double goal,
    String prefix = '',
    String suffix = '',
    required Color color,
  }) {
    final percentage = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            Text(
              '$prefix${current.toStringAsFixed(0)}$suffix / $prefix${goal.toStringAsFixed(0)}$suffix',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Text(
          '${(percentage * 100).toStringAsFixed(1)}%',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Teams Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Join an existing team or create your own to start collaborating on fitness and fundraising goals.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _createNewTeam,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Team'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _joinTeam,
                  icon: const Icon(Icons.group_add),
                  label: const Text('Join Team'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Teams',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onBackground,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: theme.colorScheme.onBackground,
            ),
            onPressed: _isRefreshing ? null : _refreshTeams,
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              color: theme.colorScheme.onBackground,
            ),
            onPressed: _createNewTeam,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _refreshTeams,
              child: FutureBuilder<UserTeamsDetailed>(
                future: _teamsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load teams',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please check your connection and try again',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _refreshTeams,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || 
                      (snapshot.data!.allTeams.isEmpty && 
                       snapshot.data!.createdTeams.isEmpty && 
                       snapshot.data!.joinedTeams.isEmpty)) {
                    return _buildEmptyState();
                  }

                  final teamsData = snapshot.data!;
                  final createdTeams = teamsData.createdTeams;
                  final joinedTeams = teamsData.joinedTeams;
                  final allTeams = teamsData.allTeams;

                  // Filter other teams (teams that user didn't create or join)
                  final otherTeams = allTeams.where((team) => 
                    !createdTeams.any((t) => t.id == team.id) && 
                    !joinedTeams.any((t) => t.id == team.id)
                  ).toList();

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        _buildTeamSection(
                          createdTeams,
                          'My Created Teams',
                          Icons.star,
                          Colors.orange,
                        ),
                        _buildTeamSection(
                          joinedTeams,
                          'Joined Teams',
                          Icons.group,
                          Colors.blue,
                        ),
                        _buildTeamSection(
                          otherTeams,
                          'Discover Teams',
                          Icons.explore,
                          Colors.green,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
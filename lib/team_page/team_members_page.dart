import 'package:flutter/material.dart';
import 'package:ruracare/services/api_service.dart';
import 'package:ruracare/services/models.dart';
import 'package:ruracare/team_page/invite_team_members.dart';

class TeamMembersPage extends StatefulWidget {
  const TeamMembersPage({super.key});

  @override
  TeamMembersPageState createState() => TeamMembersPageState();
}

class TeamMembersPageState extends State<TeamMembersPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Team>> _membersFuture;

  @override
  void initState() {
    super.initState();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final teamId = args['teamId'] as String;
    _membersFuture = _apiService.getMembers(teamId);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final teamId = args['teamId'] as String;
    final teamName = args['teamName'] as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('$teamName Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InviteTeamMembers(
                    teamId: teamId,
                    teamName: teamName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Team>>(
        future: _membersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No team members found'));
          }

          final members = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final team = members[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(team.name[0]),
                  ),
                  title: Text(team.name),
                  subtitle: Text('Team: ${team.name}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ruracare/donation_page/widget/donation_dialog.dart';
import 'package:ruracare/services/api_service.dart';
import 'package:ruracare/services/models.dart';

class DonationPage extends ConsumerStatefulWidget {
  const DonationPage({super.key});

  @override
  DonationPageState createState() => DonationPageState();
}

class DonationPageState extends ConsumerState<DonationPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<TeamDetailed>> _teamsFuture;
  late Future<DonationsResponse> _individualDonationsFuture;
  late Future<DonationsResponse> _teamDonationsFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final apiService = ref.read(apiServiceProvider);
    _teamsFuture = apiService.getUserTeamsDetailed().then((teamsData) {
      // Combine created and joined teams
      return [...teamsData.createdTeams, ...teamsData.joinedTeams];
    });
    _loadDonations();
  }

  void _loadDonations() {
    final apiService = ref.read(apiServiceProvider);
    _individualDonationsFuture = apiService.getDonations(
      pageNumber: 1,
      pageSize: 10,
    );
    
    _teamDonationsFuture = _loadTeamDonations();
  }

  Future<DonationsResponse> _loadTeamDonations() async {
    final apiService = ref.read(apiServiceProvider);
    final token = await apiService.getAuthToken();
    if (token == null) {
      return DonationsResponse(
        pageNumber: 1,
        pageSize: 10,
        totalPages: 0,
        totalRecords: 0,
        message: 'Not authenticated',
        status: 401,
        data: [],
      );
    }
    
    final userId = apiService.getUserIdFromToken(token);
    if (userId == null) {
      return DonationsResponse(
        pageNumber: 1,
        pageSize: 10,
        totalPages: 0,
        totalRecords: 0,
        message: 'User ID not found',
        status: 400,
        data: [],
      );
    }

    return apiService.getTeamDonations(
      pageNumber: 1,
      pageSize: 10,
      userId: userId,
    );
  }

  Future<void> _showIndividualDonationDialog() async {
    if (!mounted) return;
    
    final apiService = ref.read(apiServiceProvider);
    
    try {
      final token = await apiService.getAuthToken();
      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication required')),
        );
        return;
      }
      
      final userId = apiService.getUserIdFromToken(token);
      if (userId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found')),
        );
        return;
      }

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => DonationDialog(
          donationType: 'individual',
          userId: userId,
          onDonationSuccess: () {
            if (mounted) {
              _loadDonations();
            }
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _showTeamDonationDialog(TeamDetailed team) async {
    if (!mounted) return;
    
    final apiService = ref.read(apiServiceProvider);
    
    try {
      final token = await apiService.getAuthToken();
      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication required')),
        );
        return;
      }
      
      final userId = apiService.getUserIdFromToken(token);
      if (userId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found')),
        );
        return;
      }

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => DonationDialog(
          donationType: 'team',
          userId: userId,
          teamId: team.id,
          teamName: team.name,
          onDonationSuccess: () {
            if (mounted) {
              _loadDonations();
            }
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.white,
              pinned: true,
              floating: true,
              snap: true,
              expandedHeight: 50.0,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  color: Colors.white,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48.0),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    labelPadding: EdgeInsets.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF2196F3),
                    indicatorWeight: 3.0,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    unselectedLabelStyle: GoogleFonts.poppins(
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                      height: 1.2,
                    ),
                    tabs: [
                      Container(
                        width: (MediaQuery.of(context).size.width - 32) / 2,
                        alignment: Alignment.center,
                        child: const Text('Individual'),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width - 32) / 2,
                        alignment: Alignment.center,
                        child: const Text('Teams'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildIndividualTab(),
            _buildTeamTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndividualTab() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildDonationCard(
            icon: Icons.person_outline,
            title: 'Individual Donation',
            subtitle: 'Every contribution makes a difference!',
            buttonText: 'Donate',
            onTap: _showIndividualDonationDialog,
            color: const Color(0xFF2196F3),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text(
              'Your Donations',
              style: GoogleFonts.poppins(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: FutureBuilder<DonationsResponse>(
            future: _individualDonationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return _buildErrorCard('Failed to load donations');
              } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.volunteer_activism_outlined,
                  title: 'No donations yet',
                  subtitle: 'Make your first donation to support the cause',
                );
              }

              final donationsResponse = snapshot.data!;
              final donations = donationsResponse.data;
              final totalAmount = _calculateTotalAmount(donations);

              return Column(
                children: [
                  _buildSummaryCard(
                    totalDonations: donations.length,
                    totalAmount: totalAmount,
                    color: const Color(0xFF2196F3),
                  ),
                  const SizedBox(height: 12.0),
                ],
              );
            },
          ),
        ),
        FutureBuilder<DonationsResponse>(
          future: _individualDonationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }
            
            if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }

            final donations = snapshot.data!.data;
            
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final donation = donations[index];
                  return _buildDonationItem(
                    donation: donation,
                    isTeam: false,
                  );
                },
                childCount: donations.length,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTeamTab() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildDonationCard(
            icon: Icons.group_outlined,
            title: 'Team Donation',
            subtitle: 'Together we can make a difference!',
            buttonText: 'Donate',
            onTap: () {},
            color: const Color(0xFF2196F3),
            isDisabled: true,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text(
              'Support Teams',
              style: GoogleFonts.poppins(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        FutureBuilder<List<TeamDetailed>>(
          future: _teamsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return SliverToBoxAdapter(
                child: _buildErrorCard('Failed to load teams: ${snapshot.error}'),
              );
            }
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SliverToBoxAdapter(
                child: _buildEmptyState(
                  icon: Icons.group_off_outlined,
                  title: 'No teams available',
                  subtitle: 'Teams will appear here when created',
                ),
              );
            }
            
            final teams = snapshot.data!;
            
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final team = teams[index];
                  return _buildTeamItem(team);
                },
                childCount: teams.length,
              ),
            );
          },
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text(
              'Team Donations',
              style: GoogleFonts.poppins(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: FutureBuilder<DonationsResponse>(
            future: _teamDonationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return _buildErrorCard('Failed to load team donations');
              } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.group_work_outlined,
                  title: 'No team donations',
                  subtitle: 'Your team donations will appear here',
                );
              }

              final donationsResponse = snapshot.data!;
              final donations = donationsResponse.data;
              final totalAmount = _calculateTotalAmount(donations);

              return Column(
                children: [
                  _buildSummaryCard(
                    totalDonations: donations.length,
                    totalAmount: totalAmount,
                    color: const Color(0xFF2196F3),
                  ),
                  const SizedBox(height: 12.0),
                ],
              );
            },
          ),
        ),
        FutureBuilder<DonationsResponse>(
          future: _teamDonationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }
            
            if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }

            final donations = snapshot.data!.data;
            
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final donation = donations[index];
                  return _buildDonationItem(
                    donation: donation,
                    isTeam: true,
                  );
                },
                childCount: donations.length,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDonationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
    required Color color,
    bool isDisabled = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.0,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: isDisabled ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.poppins(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamItem(TeamDetailed team) {
    final progress = team.fundsRaised != null && team.fundRaisingGoal > 0
        ? (team.fundsRaised! / team.fundRaisingGoal).clamp(0.0, 1.0)
        : 0.0;
    final color = const Color(0xFF2196F3);
    final raisedAmount = team.fundsRaised?.toStringAsFixed(0) ?? '0';
    final goalAmount = team.fundRaisingGoal.toStringAsFixed(0);
    final memberCount = team.participants ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                Icons.group,
                size: 24.0,
                color: color,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Together we can make a difference!',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    color: color,
                    borderRadius: BorderRadius.circular(4.0),
                    minHeight: 4.0,
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${memberCount} ${memberCount == 1 ? 'member' : 'members'} • GHS $raisedAmount',
                        style: GoogleFonts.poppins(
                          fontSize: 12.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% of GHS $goalAmount',
                        style: GoogleFonts.poppins(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0),
            ElevatedButton(
              onPressed: () => _showTeamDonationDialog(team),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 0,
              ),
              child: Text(
                'Support',
                style: GoogleFonts.poppins(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDonationModal(DonationItem donation, bool isTeam) {
    final teamName = isTeam ? (donation.team != null ? (donation.team!['name'] ?? 'Team') : 'Team') : null;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Support ${teamName ?? 'this cause'}'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Add your donation form or content here
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      // Handle donation submission
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue with Donation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDonationItem({
    required DonationItem donation,
    required bool isTeam,
  }) {
    final teamName = isTeam ? (donation.team != null ? (donation.team!['name'] ?? 'Team') : 'Team') : null;
    final color = const Color(0xFF2196F3);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: _getStatusColor(donation.status).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isTeam ? Icons.group : Icons.person,
                color: _getStatusColor(donation.status),
                size: 20.0,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isTeam && teamName != null) ...[
                    Text(
                      teamName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                  ],
                  Text(
                    'GHS ${donation.amount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    _formatDate(donation.createDate),
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: _getStatusColor(donation.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                donation.status.toUpperCase(),
                style: GoogleFonts.poppins(
                  color: _getStatusColor(donation.status),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required int totalDonations,
    required double totalAmount,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  totalDonations.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Donations',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
            Container(
              width: 1.0,
              height: 30.0,
              color: Colors.grey.shade300,
            ),
            Column(
              children: [
                Text(
                  'GHS ${totalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Total Amount',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 40.0),
          const SizedBox(height: 8.0),
          Text(
            message,
            style: GoogleFonts.poppins(color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Icon(icon, size: 60.0, color: Colors.grey.shade400),
          const SizedBox(height: 12.0),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotalAmount(List<DonationItem> donations) {
    return donations.fold(0.0, (sum, donation) => sum + donation.amount);
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
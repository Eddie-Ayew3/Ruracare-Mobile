import 'package:flutter/material.dart';
import 'package:ruracare/dashboard/pages/campaign_target_widget.dart';
import 'package:ruracare/dashboard/pages/donation_row.dart';
import 'package:ruracare/services/api_service.dart';
import 'package:ruracare/services/models.dart';

class DashboardHome extends StatefulWidget {
  final String token;
  final String email;
  final String fullname;
  final String userId;

  const DashboardHome({
    super.key,
    required this.token,
    required this.email,
    required this.fullname,
    required this.userId,
  });

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  final ApiService _apiService = ApiService();
  late Future<User?> _userFuture;
  late Future<DonationsResponse> _donationsFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _apiService.getStoredUser();
    _donationsFuture = _apiService.getDonations(pageNumber: 1, pageSize: 5);
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildWelcomeSection(),
          const SizedBox(height: 16),
          
          // Campaign Target Widget
          const CampaignTargetWidget(),
          const SizedBox(height: 16),

          // Recent Donations
          _buildDonationsSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return FutureBuilder<User?>(
      future: _userFuture,
      builder: (context, snapshot) {
        final userName = snapshot.data?.fullName ?? widget.fullname;
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 33, 150, 243),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0x4D5271FF),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello $userName! 👋',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ready to make a difference today?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        );
      },
    );
  }





  Widget _buildDonationsSection() {
    return FutureBuilder<DonationsResponse>(
      future: _donationsFuture,
      builder: (context, snapshot) {
        // Show loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13), // 255 * 0.05 ≈ 13
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Donations",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "View All",
                      style: TextStyle(
                        color: Color.fromARGB(255, 33, 150, 243),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
          );
        }

        // Show error state
        if (snapshot.hasError || snapshot.data?.status != 200) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13), // 255 * 0.05 ≈ 13
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Donations",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "View All",
                      style: TextStyle(
                        color: Color.fromARGB(255, 33, 150, 243),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    snapshot.data?.message ?? 'Error loading donations',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        }

        // Success state - show real data
        final donationsResponse = snapshot.data!;
        final donations = donationsResponse.data;

        // If no donations, show empty state
        if (donations.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13), // 255 * 0.05 ≈ 13
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Donations",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "View All",
                      style: TextStyle(
                        color: Color.fromARGB(255, 33, 150, 243),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    "No donations yet",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Show real donation data
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13), // 255 * 0.05 ≈ 13
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Donations",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "View All",
                    style: TextStyle(
                      color: Color.fromARGB(255, 33, 150, 243),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...donations.asMap().entries.map((entry) {
                final index = entry.key;
                final donation = entry.value;
                
                String formatDate(String dateString) {
                  if (dateString == '0001-01-01T00:00:00') return 'N/A';
                  try {
                    final date = DateTime.parse(dateString);
                    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                    return '${months[date.month - 1]} ${date.day}';
                  } catch (e) {
                    return 'N/A';
                  }
                }

                return Column(
                  children: [
                    DonationRow(
                      donation: donation,
                    ),
                    if (index != donations.length - 1) const Divider(height: 24),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
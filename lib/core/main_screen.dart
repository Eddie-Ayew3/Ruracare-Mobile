import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ruracare/dashboard/dashboard.dart';
import 'package:ruracare/donation_page/donation_page.dart';
import 'package:ruracare/team_page/team_dashboard.dart';
import 'dart:convert';

class MainScreen extends StatefulWidget {
  final String token;
  final String email;
  final String fullname;
  final String userId;

  const MainScreen({
    super.key,
    required this.token,
    required this.email,
    required this.fullname,
    required this.userId,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _email = '';
  String _fullname = '';
  String? _profileImage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _loading = true;
      });

      // Try to load user data from secure storage first
      final storage = FlutterSecureStorage();
      
      // Load user data
      final userStr = await storage.read(key: 'user');
      if (userStr != null && userStr.isNotEmpty) {
        final userData = jsonDecode(userStr);
        setState(() {
          _fullname = userData['fullName'] ?? userData['name'] ?? widget.fullname;
          _email = userData['email'] ?? widget.email;
        });
      } else {
        // Fallback to widget data
        setState(() {
          _fullname = widget.fullname;
          _email = widget.email;
        });
      }

      // Load profile image
      final profileImage = await storage.read(key: 'userAvatar');
      if (profileImage != null && profileImage.isNotEmpty) {
        setState(() {
          _profileImage = profileImage;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading user data: $e');
      debugPrint('Stack trace: $stackTrace');
      // Fallback to widget data on error
      if (mounted) {
        setState(() {
          _fullname = widget.fullname;
          _email = widget.email;
        });
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  PreferredSizeWidget? _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[50],
          ),
          child: Image.asset(
            'assets/faicon.png',
            height: 20,
            width: 20,
            fit: BoxFit.contain,
          ),
        ),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      title: Text(
        _getAppBarTitle(),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[50],
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return "Dashboard";
      case 1:
        return "Teams";
      case 2:
        return "Donations";
      default:
        return "RuraCare";
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header with gradient background
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade50,
                    Colors.lightBlue.shade50,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Avatar with shadow
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26), // ~10% opacity
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _buildAvatar(),
                    ),
                    const SizedBox(height: 16),
                    
                    // User Name
                    _loading 
                      ? Container(
                          width: 120,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                        )
                      : Text(
                          _fullname.isNotEmpty ? _fullname : 'User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    
                    const SizedBox(height: 4),
                    
                    // User Email
                    _loading
                      ? Container(
                          width: 160,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                        )
                      : Text(
                          _email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                  ],
                ),
              ),
            ),

            // Drawer Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  _buildDrawerItem(
                    Icons.person_outline,
                    "Edit Profile",
                    Icons.arrow_forward_ios_rounded,
                    () {
                      Navigator.pop(context); // Close drawer
                      // Navigate to edit profile page
                    },
                  ),
                  _buildDrawerItem(
                    Icons.settings_outlined,
                    "Settings",
                    Icons.arrow_forward_ios_rounded,
                    () {
                      Navigator.pop(context);
                      // Navigate to settings
                    },
                  ),
                  _buildDrawerItem(
                    Icons.help_outline,
                    "Help & Support",
                    Icons.arrow_forward_ios_rounded,
                    () {
                      Navigator.pop(context);
                      // Navigate to help & support
                    },
                  ),
                  _buildDrawerItem(
                    Icons.privacy_tip_outlined,
                    "Privacy Policy",
                    Icons.arrow_forward_ios_rounded,
                    () {
                      Navigator.pop(context);
                      // Navigate to privacy policy
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Divider(height: 1),
                  ),
                  _buildDrawerItem(
                    Icons.info_outline,
                    "About RuraCare",
                    Icons.arrow_forward_ios_rounded,
                    () {
                      Navigator.pop(context);
                      // Navigate to about page
                    },
                  ),
                ],
              ),
            ),

            // Sign Out Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1.0,
                  ),
                ),
              ),
              child: _buildSignOutButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    // Show loading state
    if (_loading) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey[300],
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    // Show profile image if available
    if (_profileImage != null && _profileImage!.isNotEmpty) {
      try {
        // Check if it's a base64 image or URL
        if (_profileImage!.startsWith('data:image') || _profileImage!.contains(',')) {
          // Base64 image
          return CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            backgroundImage: MemoryImage(
              base64Decode(_profileImage!.split(',').last),
            ),
          );
        } else {
          // URL image
          return CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(_profileImage!),
          );
        }
      } catch (e, stackTrace) {
        debugPrint('Error loading profile image: $e');
        debugPrint('Stack trace: $stackTrace');
        // Fallback to initials if image loading fails
        return _buildInitialsAvatar();
      }
    }

    // Fallback to initials avatar
    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.blue,
      child: Text(
        _getInitials(_fullname),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return 'US';

    final parts = fullName.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].length >= 2 
          ? parts[0].substring(0, 2).toUpperCase()
          : parts[0].toUpperCase();
    }

    final initials = parts
        .where((part) => part.isNotEmpty)
        .map((part) => part[0])
        .join('')
        .toUpperCase();

    return initials.length >= 2 ? initials.substring(0, 2) : initials;
  }

  Widget _buildDrawerItem(IconData leadingIcon, String title, IconData trailingIcon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(
          leadingIcon,
          color: Colors.blue.shade600,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(
        trailingIcon,
        color: Colors.grey[400],
        size: 16,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout, size: 18),
        label: const Text(
          'Sign Out',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: _showSignOutConfirmation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red.shade100),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    // Close any open dialogs and the drawer
    Navigator.of(context).pop(); // Close dialog if open
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      Navigator.of(context).pop(); // Close drawer if open
    }

    // Clear secure storage
    const storage = FlutterSecureStorage();
    await storage.deleteAll();

    // Navigate to login screen and clear the navigation stack
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false, // This removes all previous routes
      );
    }
  }

  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: Colors.orange,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Are you sure you want to sign out?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                          _signOut(); // Proceed with sign out
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Sign Out"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildBody() {
    final pages = [
      DashboardHome(
        token: widget.token,
        email: widget.email,
        fullname: widget.fullname,
        userId: widget.userId,
      ),
      TeamDashboard(
        token: widget.token,
        email: widget.email,
        fullname: widget.fullname,
        userId: widget.userId,
      ),
      const DonationPage(),
    ];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: pages[_currentIndex],
    );
  }

  // 🔥 COMPACT FLAT BOTTOM NAV BAR
  Widget _buildBottomNavBar() {
    return Container(
      height: 90, // Compact height
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // 255 * 0.05 ≈ 13
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            iconPath: 'assets/dashboard.png',
            index: 0,
            label: 'Dashboard',
          ),
          _buildNavItem(
            iconPath: 'assets/teams.png',
            index: 1,
            label: 'Teams',
          ),
          _buildNavItem(
            iconPath: 'assets/wallet.png',
            index: 2,
            label: 'Donations',
          ),
        ],
      ),
    );
  }

  // 🔥 NAV ITEM BUILDER
  Widget _buildNavItem({
    required String iconPath,
    required int index,
    required String label,
  }) {
    final bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // YOUR CUSTOM ICON
            Image.asset(
              iconPath,
              width: 24,
              height: 24,
              color: isActive
                  ? const Color.fromARGB(255, 33, 150, 243) // Active color
                  : Colors.grey.shade600, // Inactive color
            ),
            const SizedBox(height: 4),
            // LABEL
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? const Color.fromARGB(255, 33, 150, 243)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(), // 🔥 NEW FLAT NAV
      backgroundColor: Colors.white,
    );
  }
}
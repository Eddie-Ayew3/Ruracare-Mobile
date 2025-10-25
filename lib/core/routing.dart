import 'package:flutter/material.dart';
import 'package:ruracare/auth/login_screen.dart';
import 'package:ruracare/auth/sign_screen.dart';
import 'package:ruracare/auth/intro_page.dart';
import 'package:ruracare/core/main_screen.dart';  
import 'package:ruracare/donation_page/donation_page.dart';
import 'package:ruracare/team_page/team_dashboard.dart';
import 'package:ruracare/dashboard/dashboard.dart';
import 'package:ruracare/step/stepdashboard.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  Map<String, dynamic> args = {};
  if (settings.arguments != null) {
    if (settings.arguments is Map) {
      args = Map<String, dynamic>.from(settings.arguments as Map);
    }
  }

  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const IntroPage());
    
    case '/login':
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    
    case '/register':
      return MaterialPageRoute(builder: (_) => const SignUpScreen());
    
    // FIXED: Main route - this is your BOTTOM NAV SCREEN
    case '/main':
      return MaterialPageRoute(
        builder: (_) => MainScreen(
          token: args['token']?.toString() ?? '',
          email: args['email']?.toString() ?? '',
          fullname: args['fullname']?.toString() ?? '',
          userId: args['userId']?.toString() ?? '',
        ),
      );

    case '/dashboard':
      return MaterialPageRoute(
        builder: (_) => DashboardHome(
          token: args['token']?.toString() ?? '',
          email: args['email']?.toString() ?? '',
          fullname: args['fullname']?.toString() ?? '',
          userId: args['userId']?.toString() ?? '',
        ),
      );
    
    // Team dashboard (for direct access)
    case '/team-dashboard':
      return MaterialPageRoute(
        builder: (_) => TeamDashboard(
          token: args['token']?.toString() ?? '',
          email: args['email']?.toString() ?? '',
          fullname: args['fullname']?.toString() ?? '',
          userId: args['userId']?.toString() ?? '',
        ),
      );
    
    case '/donations':
      return MaterialPageRoute(
        builder: (_) => const DonationPage(
        ),
      );
  
    case '/steps':
      return MaterialPageRoute(
        builder: (_) => StepDashboard(),
      );
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold( 
          body: Center(child: Text('Route ${settings.name} not found')),
        ),
      );
  }
}
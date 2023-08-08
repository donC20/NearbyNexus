import 'package:flutter/material.dart';
import 'package:NearbyNexus/config/themes/app_theme.dart';

import '../components/sidebar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        actions: [],
      ),
      drawer: const Drawer(
        child: Sidebar(),
      ),
    );
  }
}

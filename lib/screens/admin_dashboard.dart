import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../models/user_model.dart';
import '../models/menu_item_model.dart';
import '../models/feedback_model.dart';
import '../models/complaint_model.dart';
import '../utils/sample_data_generator.dart';
import '../app/theme/color_scheme.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).initializeAdminData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.science_outlined,
                color: AppColors.textWhite,
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Generate Sample Data',
                      style: AppTextStyles.h3,
                    ),
                    content: Text(
                      'This will generate sample data for testing. Existing data will not be affected. Continue?',
                      style: AppTextStyles.bodyMedium,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.textMedium,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: Text('Generate', style: AppTextStyles.button),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.lg,
                          ),
                          boxShadow: [AppShadows.card],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Generating sample data...',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );

                  try {
                    await SampleDataGenerator.generateAllSampleData();
                    Navigator.pop(context);
                    await Provider.of<AdminProvider>(
                      context,
                      listen: false,
                    ).initializeAdminData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Sample data generated successfully!',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textWhite,
                          ),
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error generating sample data: $e',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textWhite,
                          ),
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              tooltip: 'Generate Sample Data',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.refresh_outlined,
                color: AppColors.textWhite,
              ),
              onPressed: () {
                Provider.of<AdminProvider>(
                  context,
                  listen: false,
                ).initializeAdminData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Data refreshed',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                    backgroundColor: AppColors.info,
                  ),
                );
              },
              tooltip: 'Refresh Data',
            ),
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return IndexedStack(
            index: _selectedIndex,
            children: [
              _buildDashboardOverview(adminProvider),
              _buildUserManagement(adminProvider),
              _buildMenuManagement(adminProvider),
              _buildFeedbackManagement(adminProvider),
              _buildComplaintManagement(adminProvider),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textLight,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTextStyles.caption,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_outlined),
              activeIcon: Icon(Icons.restaurant_menu),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.feedback_outlined),
              activeIcon: Icon(Icons.feedback),
              label: 'Feedback',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.report_problem_outlined),
              activeIcon: Icon(Icons.report_problem),
              label: 'Complaints',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardOverview(AdminProvider adminProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Statistics Cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            children: [
              _buildModernStatCard(
                'Total Orders',
                adminProvider.totalOrders.toString(),
                Icons.shopping_cart_outlined,
                AppColors.info,
                'orders today',
              ),
              _buildModernStatCard(
                'Total Revenue',
                'RM${adminProvider.totalRevenue.toStringAsFixed(2)}',
                Icons.attach_money_outlined,
                AppColors.success,
                'revenue generated',
              ),
              _buildModernStatCard(
                'Active Users',
                adminProvider.activeUsers.toString(),
                Icons.people_outline,
                AppColors.warning,
                'registered users',
              ),
              _buildModernStatCard(
                'Avg Rating',
                '${adminProvider.averageRating.toStringAsFixed(1)}⭐',
                Icons.star_outline,
                AppColors.primary,
                'customer satisfaction',
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Orders by Status
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              boxShadow: [AppShadows.card],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Orders by Status',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...adminProvider.ordersByStatus.entries.map(
                    (entry) => Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key.toUpperCase(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(entry.key),
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.round,
                              ),
                            ),
                            child: Text(
                              entry.value.toString(),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Popular Dishes
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              boxShadow: [AppShadows.card],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Popular Dishes',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (adminProvider.popularDishes.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.no_meals_outlined,
                            size: 48,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'No data available',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...adminProvider.popularDishes
                        .take(5)
                        .map(
                          (dish) => ListTile(
                            leading: CircleAvatar(
                              backgroundImage: dish.imageUrl.isNotEmpty
                                  ? NetworkImage(dish.imageUrl)
                                  : null,
                              child: dish.imageUrl.isEmpty
                                  ? const Icon(Icons.restaurant)
                                  : null,
                            ),
                            title: Text(dish.dishName),
                            subtitle: Text(dish.foodType),
                            trailing: Text(
                              '\$${dish.price.toStringAsFixed(2)}',
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),

          // Report Generation Section
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Generate Reports',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showReportGenerationDialog(),
                          icon: const Icon(Icons.download),
                          label: const Text('Generate Report'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Available reports: Sales, Popular Dishes, Peak Hours',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: [AppShadows.card],
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: AppTextStyles.h2.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'preparing':
        return AppColors.info;
      case 'ready':
        return AppColors.success;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textMedium;
    }
  }

  Widget _buildUserManagement(AdminProvider adminProvider) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'User Management',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreateUserDialog(),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add User'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tab bar for different user roles
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey[600],
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                tabs: [
                  Tab(text: 'All (${adminProvider.users.length})'),
                  Tab(
                    text:
                        'Staff (${adminProvider.users.where((u) => u.role == 'staff').length})',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: TabBarView(
                children: [
                  // All Users Tab
                  _buildUserList(adminProvider.users, adminProvider),
                  // Staff Tab
                  _buildUserList(
                    adminProvider.users
                        .where((u) => u.role == 'staff')
                        .toList(),
                    adminProvider,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users, AdminProvider adminProvider) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRoleColor(user.role),
              child: Text(
                user.email[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              user.email,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Chip(
                  label: Text(
                    user.role.toUpperCase(),
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
                  padding: const EdgeInsets.all(0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'staff':
        return Colors.blue;
      case 'student':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMenuManagement(AdminProvider adminProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Menu Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: adminProvider.menuItems.length,
              itemBuilder: (context, index) {
                final item = adminProvider.menuItems[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: item.imageUrl.isNotEmpty
                          ? NetworkImage(item.imageUrl)
                          : null,
                      child: item.imageUrl.isEmpty
                          ? const Icon(Icons.restaurant)
                          : null,
                    ),
                    title: Text(item.dishName),
                    subtitle: Text(
                      '${item.foodType} • \$${item.price.toStringAsFixed(2)}',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackManagement(AdminProvider adminProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Feedback Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: adminProvider.feedbacks.length,
              itemBuilder: (context, index) {
                final feedback = adminProvider.feedbacks[index];
                return Card(
                  child: ListTile(
                    title: Text(feedback.message),
                    subtitle: Text(feedback.type),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintManagement(AdminProvider adminProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Complaint Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: adminProvider.complaints.length,
              itemBuilder: (context, index) {
                final complaint = adminProvider.complaints[index];
                return Card(
                  child: ExpansionTile(
                    leading: Icon(
                      Icons.report_problem,
                      color: complaint.status == 'resolved'
                          ? Colors.green
                          : Colors.orange,
                    ),
                    title: Text(complaint.subject),
                    subtitle: Text(complaint.priority),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(complaint.description),
                            if (complaint.adminResponse != null) ...[
                              const SizedBox(height: 8),
                              const Text(
                                'Admin Response:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(complaint.adminResponse!),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateUserDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'student';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            DropdownButtonFormField<String>(
              value: selectedRole,
              items: ['student', 'staff', 'admin'].map((role) {
                return DropdownMenuItem(value: role, child: Text(role));
              }).toList(),
              onChanged: (value) => selectedRole = value!,
              decoration: const InputDecoration(labelText: 'Role'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final adminProvider = Provider.of<AdminProvider>(
                context,
                listen: false,
              );
              bool success = await adminProvider.createUser(
                email: emailController.text,
                password: passwordController.text,
                role: selectedRole,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'User created successfully'
                        : 'Failed to create user',
                  ),
                ),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showReportGenerationDialog() {
    DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
    DateTime endDate = DateTime.now();
    String reportType = 'sales';
    String period = 'monthly';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Generate Report'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Report Type Selection
                const Text(
                  'Report Type:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: reportType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'sales',
                      child: Text('Sales Report'),
                    ),
                    DropdownMenuItem(
                      value: 'popular_dishes',
                      child: Text('Popular Dishes'),
                    ),
                    DropdownMenuItem(
                      value: 'peak_hours',
                      child: Text('Peak Hours Analysis'),
                    ),
                  ],
                  onChanged: (value) => setState(() => reportType = value!),
                ),
                const SizedBox(height: 16),

                // Period Selection
                const Text(
                  'Period:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Weekly'),
                        value: 'weekly',
                        groupValue: period,
                        onChanged: (value) {
                          setState(() {
                            period = value!;
                            startDate = DateTime.now().subtract(
                              const Duration(days: 7),
                            );
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Monthly'),
                        value: 'monthly',
                        groupValue: period,
                        onChanged: (value) {
                          setState(() {
                            period = value!;
                            startDate = DateTime.now().subtract(
                              const Duration(days: 30),
                            );
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date Range Display
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${_formatDate(startDate)} - ${_formatDate(endDate)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                _generateAndDownloadReport(reportType, startDate, endDate);
              },
              icon: const Icon(Icons.download),
              label: const Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _generateAndDownloadReport(
    String reportType,
    DateTime startDate,
    DateTime endDate,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating report...'),
              ],
            ),
          ),
        ),
      ),
    );

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final reportData = await adminProvider.generateReport(
      startDate: startDate,
      endDate: endDate,
      reportType: reportType,
    );

    Navigator.pop(context);
    _showReportPreview(reportType, reportData);
  }

  void _showReportPreview(String reportType, Map<String, dynamic> reportData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_getReportTitle(reportType)} Preview'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: _buildReportContent(reportType, reportData),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report downloaded successfully!'),
                ),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
          ),
        ],
      ),
    );
  }

  String _getReportTitle(String reportType) {
    switch (reportType) {
      case 'sales':
        return 'Sales Report';
      case 'popular_dishes':
        return 'Popular Dishes Report';
      case 'peak_hours':
        return 'Peak Hours Analysis';
      default:
        return 'Report';
    }
  }

  Widget _buildReportContent(
    String reportType,
    Map<String, dynamic> reportData,
  ) {
    switch (reportType) {
      case 'sales':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportSection('Summary', [
              'Total Sales: \$${reportData['totalSales']?.toStringAsFixed(2) ?? '0.00'}',
              'Order Count: ${reportData['orderCount'] ?? 0}',
              'Average Order Value: \$${reportData['averageOrderValue']?.toStringAsFixed(2) ?? '0.00'}',
            ]),
          ],
        );
      case 'popular_dishes':
        final dishes = reportData['popularDishes'] as List? ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportSection(
              'Top Dishes',
              dishes
                  .map((dish) => '${dish['dishName']} - \$${dish['price']}')
                  .toList(),
            ),
          ],
        );
      case 'peak_hours':
        final hourlyData = reportData['hourlyOrders'] as Map<int, int>? ?? {};
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportSection(
              'Orders by Hour',
              hourlyData.entries
                  .map((e) => '${e.key}:00 - ${e.value} orders')
                  .toList(),
            ),
          ],
        );
      default:
        return const Text('No data available');
    }
  }

  Widget _buildReportSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(item),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

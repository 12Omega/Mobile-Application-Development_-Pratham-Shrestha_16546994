import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../../core/models/user_profile.dart';

class ProfileScreenEnhanced extends StatefulWidget {
  const ProfileScreenEnhanced({super.key});

  @override
  State<ProfileScreenEnhanced> createState() => _ProfileScreenEnhancedState();
}

class _ProfileScreenEnhancedState extends State<ProfileScreenEnhanced> {
  late ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    await _viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            Consumer<ProfileViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${viewModel.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _initializeProfile(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => _initializeProfile(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    _buildProfileHeader(viewModel),
                    const SizedBox(height: 24),

                    // Profile Information Section
                    _buildSectionTitle('Profile Information'),
                    const SizedBox(height: 8),
                    _buildProfileInfoCard(viewModel),
                    const SizedBox(height: 24),

                    // Vehicle Information Section
                    _buildSectionTitle('Vehicle Information'),
                    const SizedBox(height: 8),
                    _buildVehicleInfoCard(viewModel),
                    const SizedBox(height: 24),

                    // Payment Methods Section
                    _buildSectionTitle('Payment Methods'),
                    const SizedBox(height: 8),
                    _buildPaymentMethodsCard(viewModel),
                    const SizedBox(height: 24),

                    // Notification Settings Section
                    _buildSectionTitle('Notification Settings'),
                    const SizedBox(height: 8),
                    _buildNotificationSettingsCard(viewModel),
                    const SizedBox(height: 24),

                    // Help & Support Section
                    _buildSectionTitle('Help & Support'),
                    const SizedBox(height: 8),
                    _buildHelpSupportCard(),
                    const SizedBox(height: 24),

                    // About Section
                    _buildSectionTitle('About'),
                    const SizedBox(height: 8),
                    _buildAboutCard(),
                    const SizedBox(height: 32),

                    // Logout Button
                    _buildLogoutButton(viewModel),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileViewModel viewModel) {
    final user = viewModel.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage: user.profileImageUrl != null
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: user.profileImageUrl == null
                  ? Text(
                      viewModel.userInitials,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Member since ${_formatDate(user.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showEditProfileDialog(viewModel),
              icon: const Icon(Icons.edit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildProfileInfoCard(ProfileViewModel viewModel) {
    final user = viewModel.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Card(
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.person,
            title: 'Full Name',
            subtitle: user.name,
            onTap: () => _showEditProfileDialog(viewModel),
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.email,
            title: 'Email',
            subtitle: user.email,
            onTap: () => _showEditProfileDialog(viewModel),
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.phone,
            title: 'Phone Number',
            subtitle: user.phone,
            onTap: () => _showEditProfileDialog(viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoCard(ProfileViewModel viewModel) {
    return Card(
      child: Column(
        children: [
          ...viewModel.vehicles.map((vehicle) => Column(
                children: [
                  _buildListTile(
                    icon: Icons.directions_car,
                    title: vehicle.displayName,
                    subtitle: vehicle.fullDescription,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (vehicle.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            if (!vehicle.isDefault)
                              const PopupMenuItem(
                                value: 'default',
                                child: Text('Set as Default'),
                              ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                          onSelected: (value) => _handleVehicleAction(
                            viewModel,
                            vehicle,
                            value.toString(),
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showEditVehicleDialog(viewModel, vehicle),
                  ),
                  if (vehicle != viewModel.vehicles.last)
                    const Divider(height: 1),
                ],
              )),
          if (viewModel.vehicles.isNotEmpty) const Divider(height: 1),
          _buildListTile(
            icon: Icons.add,
            title: 'Add Vehicle',
            onTap: () => _showEditVehicleDialog(viewModel, null),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsCard(ProfileViewModel viewModel) {
    return Card(
      child: Column(
        children: [
          ...viewModel.paymentMethods.map((payment) => Column(
                children: [
                  _buildListTile(
                    icon: _getPaymentIcon(payment.type),
                    title: '${payment.displayName} ${payment.maskedNumber}',
                    subtitle: payment.expiryDate != null
                        ? 'Expires ${payment.expiryDate}'
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (payment.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            if (!payment.isDefault)
                              const PopupMenuItem(
                                value: 'default',
                                child: Text('Set as Default'),
                              ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                          onSelected: (value) => _handlePaymentAction(
                            viewModel,
                            payment,
                            value.toString(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (payment != viewModel.paymentMethods.last)
                    const Divider(height: 1),
                ],
              )),
          if (viewModel.paymentMethods.isNotEmpty) const Divider(height: 1),
          _buildListTile(
            icon: Icons.add,
            title: 'Add Payment Method',
            onTap: () => _showPaymentMethodsDialog(viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettingsCard(ProfileViewModel viewModel) {
    final settings = viewModel.notificationSettings;

    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Enable All Notifications'),
            value: settings.allNotifications,
            onChanged: (value) {
              viewModel.updateNotificationSettings(
                allNotifications: value,
                parkingUpdates: value ? settings.parkingUpdates : false,
                bookingReminders: value ? settings.bookingReminders : false,
                promotionalOffers: value ? settings.promotionalOffers : false,
                securityAlerts: value ? settings.securityAlerts : false,
              );
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.local_parking),
            title: const Text('Parking Updates'),
            subtitle: const Text('Get notified about parking availability'),
            value: settings.parkingUpdates && settings.allNotifications,
            onChanged: settings.allNotifications
                ? (value) {
                    viewModel.updateNotificationSettings(parkingUpdates: value);
                  }
                : null,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.schedule),
            title: const Text('Booking Reminders'),
            subtitle: const Text('Get notified about upcoming bookings'),
            value: settings.bookingReminders && settings.allNotifications,
            onChanged: settings.allNotifications
                ? (value) {
                    viewModel.updateNotificationSettings(
                        bookingReminders: value);
                  }
                : null,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.local_offer),
            title: const Text('Promotional Offers'),
            subtitle: const Text('Receive special offers and discounts'),
            value: settings.promotionalOffers && settings.allNotifications,
            onChanged: settings.allNotifications
                ? (value) {
                    viewModel.updateNotificationSettings(
                        promotionalOffers: value);
                  }
                : null,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.security),
            title: const Text('Security Alerts'),
            subtitle: const Text('Important security notifications'),
            value: settings.securityAlerts && settings.allNotifications,
            onChanged: settings.allNotifications
                ? (value) {
                    viewModel.updateNotificationSettings(securityAlerts: value);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSupportCard() {
    return Card(
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.help_outline,
            title: 'FAQs',
            onTap: () => _showFAQsDialog(),
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.article_outlined,
            title: 'How to Use ParkEase',
            onTap: () => _showHowToUseDialog(),
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.support_agent,
            title: 'Contact Support',
            onTap: () => _showContactSupportDialog(),
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.policy_outlined,
            title: 'Terms & Privacy Policy',
            onTap: () => _showTermsAndPolicyDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.info_outline,
            title: 'About ParkEase',
            subtitle: 'Version 1.0.0',
            onTap: () => _showAboutDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(ProfileViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            viewModel.isLoading ? null : () => _showLogoutDialog(viewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: viewModel.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Logout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // Helper methods
  IconData _getPaymentIcon(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.creditCard:
        return Icons.credit_card;
      case PaymentMethodType.debitCard:
        return Icons.credit_card;
      case PaymentMethodType.bankAccount:
        return Icons.account_balance;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.year}';
  }

  // Action handlers
  void _handleVehicleAction(
      ProfileViewModel viewModel, Vehicle vehicle, String action) {
    switch (action) {
      case 'edit':
        _showEditVehicleDialog(viewModel, vehicle);
        break;
      case 'default':
        viewModel.updateVehicle(vehicleId: vehicle.id, isDefault: true);
        break;
      case 'delete':
        _showDeleteVehicleDialog(viewModel, vehicle);
        break;
    }
  }

  void _handlePaymentAction(
      ProfileViewModel viewModel, PaymentMethod payment, String action) {
    switch (action) {
      case 'default':
        // Set as default payment method
        break;
      case 'delete':
        _showDeletePaymentDialog(viewModel, payment);
        break;
    }
  }

  // Dialog methods will be implemented in the next part...
  void _showEditProfileDialog(ProfileViewModel viewModel) {
    // Implementation will be added
  }

  void _showEditVehicleDialog(ProfileViewModel viewModel, Vehicle? vehicle) {
    // Implementation will be added
  }

  void _showPaymentMethodsDialog(ProfileViewModel viewModel) {
    // Implementation will be added
  }

  void _showDeleteVehicleDialog(ProfileViewModel viewModel, Vehicle vehicle) {
    // Implementation will be added
  }

  void _showDeletePaymentDialog(
      ProfileViewModel viewModel, PaymentMethod payment) {
    // Implementation will be added
  }

  void _showContactSupportDialog() {
    // Implementation will be added
  }

  void _showFAQsDialog() {
    // Implementation will be added
  }

  void _showHowToUseDialog() {
    // Implementation will be added
  }

  void _showTermsAndPolicyDialog() {
    // Implementation will be added
  }

  void _showAboutDialog() {
    // Implementation will be added
  }

  void _showLogoutDialog(ProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await viewModel.logout();
                if (mounted) {
                  context.go('/login');
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parkease/core/models/user_model.dart';
import 'package:parkease/core/viewmodels/auth_viewmodel.dart';
import 'package:parkease/core/viewmodels/profile_viewmodel.dart';
import 'package:parkease/ui/router.dart';
import 'package:parkease/ui/shared/app_theme.dart';
import 'package:parkease/ui/widgets/custom_app_bar.dart';
import 'package:parkease/ui/widgets/custom_bottom_navigation.dart';
import 'package:parkease/ui/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  Future<void> _loadProfileData() async {
    await Provider.of<ProfileViewModel>(context, listen: false)
        .refreshProfileData();
  }

  void _onNavigationItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Home
        context.go(AppRoutes.home);
        break;
      case 1: // Map
        context.go(AppRoutes.map);
        break;
      case 2: // Bookings
        context.go(AppRoutes.bookingHistory);
        break;
      case 3: // Profile
        break;
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('LOGOUT'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await Provider.of<AuthViewModel>(context, listen: false).logout(context);
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  Future<void> _editProfile() async {
    final user = Provider.of<AuthViewModel>(context, listen: false).user;
    if (user == null) return;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _EditProfileDialog(user: user),
    );

    if (result != null) {
      final profileViewModel =
          Provider.of<ProfileViewModel>(context, listen: false);
      await profileViewModel.updateProfile(
        name: result['name'],
        phone: result['phone'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthViewModel, ProfileViewModel>(
      builder: (context, authViewModel, profileViewModel, child) {
        final user = authViewModel.user;

        return Scaffold(
          appBar: const CustomAppBar(
            title: 'Profile',
            showBackButton: false,
          ),
          body: profileViewModel.isLoading && user == null
              ? const Center(child: CircularProgressIndicator())
              : user == null
                  ? _buildErrorState()
                  : _buildContent(context, user, profileViewModel),
          bottomNavigationBar: CustomBottomNavigation(
            currentIndex: _selectedIndex,
            onTap: _onNavigationItemTapped,
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load profile',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Retry',
            onPressed: _loadProfileData,
            width: 120,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, User user, ProfileViewModel viewModel) {
    final userStats = viewModel.userStats;

    return RefreshIndicator(
      onRefresh: _loadProfileData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile header
          _buildProfileHeader(user),

          const SizedBox(height: 24),

          // Stats
          if (userStats != null) ...[
            _buildStatsSection(userStats),
            const SizedBox(height: 24),
          ],

          // Account settings
          const Text(
            'Account Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _buildSettingsItem(
            'Edit Profile',
            Icons.person_outline,
            _editProfile,
          ),

          _buildSettingsItem(
            'Vehicle Information',
            Icons.directions_car_outlined,
            () {
              _showVehicleInfoDialog(user, viewModel);
            },
          ),

          _buildSettingsItem(
            'Payment Methods',
            Icons.credit_card,
            () {
              _showPaymentMethodsDialog();
            },
          ),

          _buildSettingsItem(
            'Notifications',
            Icons.notifications_outlined,
            () {
              _showNotificationSettingsDialog(user, viewModel);
            },
            trailing: Switch(
              value: user.preferences.notifications,
              onChanged: (value) {
                viewModel.updateNotificationPreference(value);
              },
              activeColor: AppTheme.primaryColor,
            ),
          ),

          const SizedBox(height: 24),

          // Support
          const Text(
            'Support',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _buildSettingsItem(
            'Help Center',
            Icons.help_outline,
            () {
              _navigateToHelpCenter();
            },
          ),

          _buildSettingsItem(
            'Contact Support',
            Icons.support_agent,
            () {
              _showContactSupportDialog();
            },
          ),

          _buildSettingsItem(
            'About ParkEase',
            Icons.info_outline,
            () {
              _showAboutDialog();
            },
          ),

          const SizedBox(height: 24),

          // Logout button
          CustomButton(
            text: 'Logout',
            onPressed: _logout,
            isOutlined: true,
            backgroundColor: Colors.white,
            textColor: Colors.red,
            icon: Icons.logout,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              _getInitials(user.name),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // User info
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
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.phone,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Edit button
        IconButton(
          onPressed: _editProfile,
          icon: const Icon(Icons.edit),
          color: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Stats',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatItem(
              stats['bookingStats']['total'].toString(),
              'Total Bookings',
              Icons.receipt_long,
            ),
            const SizedBox(width: 8),
            _buildStatItem(
              stats['bookingStats']['active'].toString(),
              'Active',
              Icons.directions_car,
            ),
            const SizedBox(width: 8),
            _buildStatItem(
              '\$${stats['financialStats']['totalSpent']}',
              'Total Spent',
              Icons.attach_money,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap,
      {Widget? trailing}) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.primaryColor,
      ),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    );
  }

  String _getInitials(String name) {
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0] + nameParts[1][0];
    } else if (name.isNotEmpty) {
      return name[0];
    } else {
      return 'U';
    }
  }

  void _showPaymentMethodsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => PaymentMethodsSheet(
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showNotificationSettingsDialog(User user, ProfileViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => NotificationSettingsSheet(
        user: user,
        viewModel: viewModel,
      ),
    );
  }

  void _navigateToHelpCenter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => HelpCenterSheet(
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showContactSupportDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ContactSupportSheet(),
    );
  }

  void _showVehicleInfoDialog(User user, ProfileViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => VehicleInfoSheet(
        user: user,
        viewModel: viewModel,
      ),
    );
  }

  void _showAboutDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AboutSheet(),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final User user;

  const _EditProfileDialog({required this.user});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'name': _nameController.text,
                'phone': _phoneController.text,
              });
            }
          },
          child: const Text('SAVE'),
        ),
      ],
    );
  }
}

// Payment Methods Sheet
class PaymentMethodsSheet extends StatefulWidget {
  final ScrollController scrollController;

  const PaymentMethodsSheet({Key? key, required this.scrollController}) : super(key: key);

  @override
  State<PaymentMethodsSheet> createState() => _PaymentMethodsSheetState();
}

class _PaymentMethodsSheetState extends State<PaymentMethodsSheet> {
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'type': 'card',
      'name': 'Visa ending in 1234',
      'icon': Icons.credit_card,
      'isDefault': true,
    },
    {
      'type': 'card',
      'name': 'Mastercard ending in 5678',
      'icon': Icons.credit_card,
      'isDefault': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payment Methods',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              children: [
                ..._paymentMethods.map((method) => _buildPaymentMethodItem(method)),
                const SizedBox(height: 16),
                _buildAddPaymentMethodButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(Map<String, dynamic> method) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(method['icon'], color: AppTheme.primaryColor),
        title: Text(method['name']),
        subtitle: method['isDefault'] ? const Text('Default') : null,
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
            if (!method['isDefault'])
              const PopupMenuItem(value: 'default', child: Text('Set as Default')),
          ],
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editPaymentMethod(method);
                break;
              case 'delete':
                _deletePaymentMethod(method);
                break;
              case 'default':
                _setDefaultPaymentMethod(method);
                break;
            }
          },
        ),
      ),
    );
  }

  Widget _buildAddPaymentMethodButton() {
    return ElevatedButton.icon(
      onPressed: _addPaymentMethod,
      icon: const Icon(Icons.add),
      label: const Text('Add Payment Method'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  void _addPaymentMethod() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payment Method'),
        content: const Text('Payment method integration coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _editPaymentMethod(Map<String, dynamic> method) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${method['name']}')),
    );
  }

  void _deletePaymentMethod(Map<String, dynamic> method) {
    setState(() {
      _paymentMethods.remove(method);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${method['name']} deleted')),
    );
  }

  void _setDefaultPaymentMethod(Map<String, dynamic> method) {
    setState(() {
      for (var m in _paymentMethods) {
        m['isDefault'] = false;
      }
      method['isDefault'] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${method['name']} set as default')),
    );
  }
}

// Notification Settings Sheet
class NotificationSettingsSheet extends StatefulWidget {
  final User user;
  final ProfileViewModel viewModel;

  const NotificationSettingsSheet({
    Key? key,
    required this.user,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<NotificationSettingsSheet> createState() => _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<NotificationSettingsSheet> {
  late bool _pushNotifications;
  late bool _emailNotifications;
  late bool _bookingReminders;
  late bool _promotionalOffers;

  @override
  void initState() {
    super.initState();
    _pushNotifications = widget.user.preferences.notifications;
    _emailNotifications = widget.user.preferences.emailNotifications ?? true;
    _bookingReminders = widget.user.preferences.bookingReminders ?? true;
    _promotionalOffers = widget.user.preferences.promotionalOffers ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notification Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildNotificationOption(
            'Push Notifications',
            'Receive push notifications on your device',
            _pushNotifications,
            (value) {
              setState(() => _pushNotifications = value);
              widget.viewModel.updateNotificationPreference(value);
            },
          ),
          _buildNotificationOption(
            'Email Notifications',
            'Receive notifications via email',
            _emailNotifications,
            (value) => setState(() => _emailNotifications = value),
          ),
          _buildNotificationOption(
            'Booking Reminders',
            'Get reminded about your upcoming bookings',
            _bookingReminders,
            (value) => setState(() => _bookingReminders = value),
          ),
          _buildNotificationOption(
            'Promotional Offers',
            'Receive special offers and discounts',
            _promotionalOffers,
            (value) => setState(() => _promotionalOffers = value),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Settings'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationOption(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    // Save notification settings
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings saved')),
    );
  }
}

// Help Center Sheet
class HelpCenterSheet extends StatelessWidget {
  final ScrollController scrollController;

  const HelpCenterSheet({Key? key, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final faqItems = [
      {
        'question': 'How do I book a parking spot?',
        'answer': 'Open the app, search for your destination, select an available parking spot, choose your duration, and confirm your booking with payment.',
      },
      {
        'question': 'Can I cancel my booking?',
        'answer': 'Yes, you can cancel your booking up to 15 minutes before your reserved time. Cancellation fees may apply depending on the timing.',
      },
      {
        'question': 'How do I extend my parking time?',
        'answer': 'You can extend your parking time through the app if the spot is available. Additional charges will apply for the extended duration.',
      },
      {
        'question': 'What payment methods are accepted?',
        'answer': 'We accept all major credit cards, debit cards, and digital wallets like Apple Pay and Google Pay.',
      },
      {
        'question': 'Is my payment information secure?',
        'answer': 'Yes, we use industry-standard encryption and security measures to protect your payment information.',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Help Center',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                const Text(
                  'Frequently Asked Questions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...faqItems.map((item) => _buildFAQItem(item['question']!, item['answer']!)),
                const SizedBox(height: 24),
                _buildContactSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Still need help?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: Icon(Icons.email, color: AppTheme.primaryColor),
          title: const Text('Email Support'),
          subtitle: const Text('support@parkease.com'),
          onTap: () {
            // Launch email
          },
        ),
        ListTile(
          leading: Icon(Icons.phone, color: AppTheme.primaryColor),
          title: const Text('Phone Support'),
          subtitle: const Text('+1 (555) 123-4567'),
          onTap: () {
            // Launch phone
          },
        ),
        ListTile(
          leading: Icon(Icons.chat, color: AppTheme.primaryColor),
          title: const Text('Live Chat'),
          subtitle: const Text('Available 24/7'),
          onTap: () {
            // Launch chat
          },
        ),
      ],
    );
  }
}

// Contact Support Sheet
class ContactSupportSheet extends StatefulWidget {
  const ContactSupportSheet({Key? key}) : super(key: key);

  @override
  State<ContactSupportSheet> createState() => _ContactSupportSheetState();
}

class _ContactSupportSheetState extends State<ContactSupportSheet> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'General';

  final List<String> _categories = [
    'General',
    'Booking Issues',
    'Payment Problems',
    'Technical Support',
    'Account Issues',
    'Feedback',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Contact Support',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a subject';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your message';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitSupport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Send Message'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitSupport() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Support request sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

// Vehicle Info Sheet
class VehicleInfoSheet extends StatefulWidget {
  final User user;
  final ProfileViewModel viewModel;

  const VehicleInfoSheet({
    Key? key,
    required this.user,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<VehicleInfoSheet> createState() => _VehicleInfoSheetState();
}

class _VehicleInfoSheetState extends State<VehicleInfoSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _licensePlateController;
  late TextEditingController _modelController;
  late TextEditingController _colorController;
  String _selectedVehicleType = 'car';

  final List<String> _vehicleTypes = [
    'car',
    'motorcycle',
    'suv',
    'truck',
    'van',
    'electric_car',
  ];

  final List<String> _commonColors = [
    'White',
    'Black',
    'Silver',
    'Gray',
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Brown',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _licensePlateController = TextEditingController(text: widget.user.vehicleInfo.licensePlate);
    _modelController = TextEditingController(text: widget.user.vehicleInfo.model ?? '');
    _colorController = TextEditingController(text: widget.user.vehicleInfo.color ?? '');
    _selectedVehicleType = widget.user.vehicleInfo.vehicleType;
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Vehicle Information',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // License Plate
                    TextFormField(
                      controller: _licensePlateController,
                      decoration: const InputDecoration(
                        labelText: 'License Plate Number',
                        hintText: 'e.g., BA 1 KHA 1234',
                        prefixIcon: Icon(Icons.confirmation_number),
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter license plate number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Vehicle Type
                    DropdownButtonFormField<String>(
                      value: _selectedVehicleType,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Type',
                        prefixIcon: Icon(Icons.directions_car),
                        border: OutlineInputBorder(),
                      ),
                      items: _vehicleTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(_getVehicleIcon(type)),
                              const SizedBox(width: 8),
                              Text(_formatVehicleType(type)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedVehicleType = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Vehicle Model
                    TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Model',
                        hintText: 'e.g., Toyota Corolla, Honda City',
                        prefixIcon: Icon(Icons.car_rental),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter vehicle model';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Vehicle Color
                    DropdownButtonFormField<String>(
                      value: _commonColors.contains(_colorController.text) ? _colorController.text : 'Other',
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Color',
                        prefixIcon: Icon(Icons.palette),
                        border: OutlineInputBorder(),
                      ),
                      items: _commonColors.map((color) {
                        return DropdownMenuItem(
                          value: color,
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _getColorFromName(color),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(color),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != 'Other') {
                          _colorController.text = value!;
                        } else {
                          _showCustomColorDialog();
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Vehicle Features
                    const Text(
                      'Vehicle Features',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildFeatureCheckbox('Electric Vehicle', Icons.electric_car),
                    _buildFeatureCheckbox('Hybrid Vehicle', Icons.eco),
                    _buildFeatureCheckbox('Automatic Transmission', Icons.settings),
                    _buildFeatureCheckbox('GPS Navigation', Icons.navigation),
                    _buildFeatureCheckbox('Parking Sensors', Icons.sensors),
                    
                    const SizedBox(height: 24),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveVehicleInfo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Save Vehicle Information'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCheckbox(String title, IconData icon) {
    return CheckboxListTile(
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      value: false, // This would be connected to actual data
      onChanged: (value) {
        // Handle feature toggle
      },
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
    );
  }

  IconData _getVehicleIcon(String type) {
    switch (type) {
      case 'motorcycle':
        return Icons.two_wheeler;
      case 'suv':
        return Icons.airport_shuttle;
      case 'truck':
        return Icons.local_shipping;
      case 'van':
        return Icons.airport_shuttle;
      case 'electric_car':
        return Icons.electric_car;
      default:
        return Icons.directions_car;
    }
  }

  String _formatVehicleType(String type) {
    switch (type) {
      case 'electric_car':
        return 'Electric Car';
      default:
        return type.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
    }
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.black;
      case 'silver':
        return Colors.grey[300]!;
      case 'gray':
        return Colors.grey;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'brown':
        return Colors.brown;
      default:
        return Colors.grey[400]!;
    }
  }

  void _showCustomColorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Custom Color'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Enter custom color',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _colorController.text = controller.text;
                  setState(() {});
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveVehicleInfo() {
    if (_formKey.currentState!.validate()) {
      // Save vehicle information
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle information saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

// About Sheet
class AboutSheet extends StatelessWidget {
  const AboutSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'About ParkEase',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.local_parking_rounded,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'ParkEase',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'ParkEase is a smart parking solution that helps you find, reserve, and pay for parking spots in urban areas. Our mission is to make parking hassle-free and efficient for everyone.',
            style: TextStyle(fontSize: 16, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildInfoRow('Developer', 'ParkEase Team'),
          _buildInfoRow('Contact', 'support@parkease.com'),
          _buildInfoRow('Website', 'www.parkease.com'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => _showPrivacyPolicy(context),
                child: const Text('Privacy Policy'),
              ),
              TextButton(
                onPressed: () => _showTermsOfService(context),
                child: const Text('Terms of Service'),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text('Privacy policy content would be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const Text('Terms of service content would be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

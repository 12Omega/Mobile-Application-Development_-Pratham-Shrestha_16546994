import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/UserViewModel.dart';
import '../../domain/model/User.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    final viewModel = Provider.of<UserViewModel>(context, listen: false);
    // In a real app, you'd get the user ID from authentication
    const userId = 'current-user-id';
    await viewModel.loadUserProfile(userId);
    await viewModel.loadUserStats(userId);
  }

  Future<void> _editProfile() async {
    final viewModel = Provider.of<UserViewModel>(context, listen: false);
    final user = viewModel.user;
    if (user == null) return;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _EditProfileDialog(user: user),
    );

    if (result != null) {
      final updatedUser = user.copyWith(
        name: result['name'],
        phone: result['phone'],
      );
      await viewModel.updateUserProfile(user.id, updatedUser);
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
      final viewModel = Provider.of<UserViewModel>(context, listen: false);
      await viewModel.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.errorMessage != null && viewModel.user == null) {
          return Scaffold(
            body: _buildErrorState(viewModel),
          );
        }

        final user = viewModel.user;
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('No user data available')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          body: RefreshIndicator(
            onRefresh: _loadUserData,
            child: _buildContent(context, user, viewModel),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(UserViewModel viewModel) {
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
            viewModel.errorMessage ?? 'Failed to load profile',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              viewModel.clearError();
              _loadUserData();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, User user, UserViewModel viewModel) {
    final userStats = viewModel.userStats;

    return ListView(
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
          () => _showVehicleDialog(user, viewModel),
        ),

        _buildSettingsItem(
          'Notifications',
          Icons.notifications_outlined,
          () => _showNotificationDialog(user, viewModel),
          trailing: Switch(
            value: user.preferences?.notifications ?? true,
            onChanged: (value) {
              viewModel.updateNotificationPreference(value);
            },
            activeColor: Colors.blue,
          ),
        ),

        const SizedBox(height: 24),

        // Logout button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
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
            color: Colors.blue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              _getInitials(user.name),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
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
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                user.phone,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // Edit button
        IconButton(
          onPressed: _editProfile,
          icon: const Icon(Icons.edit),
          color: Colors.blue,
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
              stats['totalBookings']?.toString() ?? '0',
              'Total Bookings',
              Icons.receipt_long,
            ),
            const SizedBox(width: 8),
            _buildStatItem(
              stats['activeBookings']?.toString() ?? '0',
              'Active',
              Icons.directions_car,
            ),
            const SizedBox(width: 8),
            _buildStatItem(
              '\$${stats['totalSpent']?.toString() ?? '0'}',
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
            Icon(icon, color: Colors.blue),
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
      leading: Icon(icon, color: Colors.blue),
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

  void _showVehicleDialog(User user, UserViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => _VehicleInfoDialog(
        user: user,
        onSave: (licensePlate, vehicleType, color, model) {
          viewModel.updateVehicleInfo(
            licensePlate: licensePlate,
            vehicleType: vehicleType,
            color: color,
            model: model,
          );
        },
      ),
    );
  }

  void _showNotificationDialog(User user, UserViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Push Notifications'),
              value: user.preferences?.notifications ?? true,
              onChanged: (value) {
                viewModel.updateNotificationPreference(value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
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

class _VehicleInfoDialog extends StatefulWidget {
  final User user;
  final Function(String, String, String?, String?) onSave;

  const _VehicleInfoDialog({
    required this.user,
    required this.onSave,
  });

  @override
  State<_VehicleInfoDialog> createState() => _VehicleInfoDialogState();
}

class _VehicleInfoDialogState extends State<_VehicleInfoDialog> {
  late TextEditingController _licensePlateController;
  late TextEditingController _vehicleTypeController;
  late TextEditingController _colorController;
  late TextEditingController _modelController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final vehicleInfo = widget.user.vehicleInfo;
    _licensePlateController =
        TextEditingController(text: vehicleInfo?.licensePlate ?? '');
    _vehicleTypeController =
        TextEditingController(text: vehicleInfo?.vehicleType ?? '');
    _colorController = TextEditingController(text: vehicleInfo?.color ?? '');
    _modelController = TextEditingController(text: vehicleInfo?.model ?? '');
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _vehicleTypeController.dispose();
    _colorController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Vehicle Information'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _licensePlateController,
              decoration: const InputDecoration(
                labelText: 'License Plate',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter license plate';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _vehicleTypeController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Type',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter vehicle type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: 'Color (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model (Optional)',
                border: OutlineInputBorder(),
              ),
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
              widget.onSave(
                _licensePlateController.text,
                _vehicleTypeController.text,
                _colorController.text.isEmpty ? null : _colorController.text,
                _modelController.text.isEmpty ? null : _modelController.text,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('SAVE'),
        ),
      ],
    );
  }
}

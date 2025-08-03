import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart' as custom_widgets;
import '../viewmodels/profile_viewmodel.dart';

class ProfileScreenClean extends StatefulWidget {
  final String userId;

  const ProfileScreenClean({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<ProfileScreenClean> createState() => _ProfileScreenCleanState();
}

class _ProfileScreenCleanState extends State<ProfileScreenClean> {
  late ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ProfileViewModel>();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await _viewModel.loadUserProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Profile',
          showBackButton: false,
        ),
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.userProfile == null) {
              return const LoadingWidget();
            }

            if (viewModel.errorMessage != null &&
                viewModel.userProfile == null) {
              return custom_widgets.ErrorWidget(
                message: viewModel.errorMessage!,
                onRetry: _loadProfile,
              );
            }

            if (viewModel.userProfile == null) {
              return const Center(
                child: Text('No profile data available'),
              );
            }

            return RefreshIndicator(
              onRefresh: _loadProfile,
              child: _buildProfileContent(context, viewModel),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(
      BuildContext context, ProfileViewModel viewModel) {
    final profile = viewModel.userProfile!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profile Header
        _buildProfileHeader(profile),
        const SizedBox(height: 24),

        // Profile Information Section
        _buildSectionTitle('Profile Information'),
        const SizedBox(height: 8),
        _buildProfileInfoCard(profile),
        const SizedBox(height: 24),

        // Actions
        _buildActionsSection(context, viewModel),
      ],
    );
  }

  Widget _buildProfileHeader(profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage: profile.avatarUrl != null
                  ? NetworkImage(profile.avatarUrl!)
                  : null,
              child: profile.avatarUrl == null
                  ? Text(
                      _getInitials(profile.name),
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
                    profile.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.phone,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showEditProfileDialog(context),
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

  Widget _buildProfileInfoCard(profile) {
    return Card(
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.person,
            title: 'Full Name',
            subtitle: profile.name,
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.email,
            title: 'Email',
            subtitle: profile.email,
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.phone,
            title: 'Phone Number',
            subtitle: profile.phone,
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.calendar_today,
            title: 'Member Since',
            subtitle: _formatDate(profile.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(
      BuildContext context, ProfileViewModel viewModel) {
    return Column(
      children: [
        CustomButton(
          text: 'Edit Profile',
          onPressed: () => _showEditProfileDialog(context),
          isOutlined: true,
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Delete Account',
          onPressed: () => _showDeleteAccountDialog(context),
          backgroundColor: Colors.red,
          textColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0] + nameParts[1][0];
    } else {
      return nameParts[0][0];
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditProfileDialog(BuildContext context) {
    final profile = _viewModel.userProfile!;
    final nameController = TextEditingController(text: profile.name);
    final phoneController = TextEditingController(text: profile.phone);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
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
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
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
          Consumer<ProfileViewModel>(
            builder: (context, viewModel, child) {
              return TextButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          await viewModel.updateProfile(
                            userId: widget.userId,
                            name: nameController.text,
                            phone: phoneController.text,
                          );

                          if (viewModel.errorMessage == null) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                child: viewModel.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('SAVE'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement delete account logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion feature coming soon'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}

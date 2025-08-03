import 'package:flutter/material.dart';
import 'package:parkease/core/viewmodels/profile_viewmodel.dart';
import 'package:parkease/ui/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize controllers with user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<ProfileViewModel>(context, listen: false).user;
      if (user != null) {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Edit Profile',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
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
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Save profile changes
                    final profileViewModel =
                        Provider.of<ProfileViewModel>(context, listen: false);
                    profileViewModel
                        .updateProfile(
                      name: _nameController.text,
                      phone: _phoneController.text,
                    )
                        .then((success) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(profileViewModel.errorMessage ??
                                'Failed to update profile'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    });
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

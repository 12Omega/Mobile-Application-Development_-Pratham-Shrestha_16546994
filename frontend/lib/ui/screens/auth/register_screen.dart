import 'package:flutter/material.dart';
import 'package:parkease/core/services/navigation_service.dart';
import 'package:parkease/core/viewmodels/auth_viewmodel.dart';
import 'package:parkease/ui/router.dart';
import 'package:parkease/ui/shared/app_theme.dart';
import 'package:parkease/ui/widgets/custom_button.dart';
import 'package:parkease/ui/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _modelController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedVehicleType = 'car';
  String _selectedColor = 'White';

  final List<String> _vehicleTypes = ['car', 'motorcycle', 'truck', 'suv', 'van'];
  final List<String> _vehicleColors = ['White', 'Black', 'Silver', 'Gray', 'Red', 'Blue', 'Green', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _licensePlateController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  final NavigationService _navigationService = NavigationService();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

      final success = await authViewModel.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        licensePlate: _licensePlateController.text.trim().toUpperCase(),
        vehicleType: _selectedVehicleType,
        color: _selectedColor,
        model: _modelController.text.trim().isNotEmpty ? _modelController.text.trim() : 'Not specified',
      );

      if (success && mounted) {
        _navigationService.navigateTo(context, AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Error message
                if (authViewModel.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      authViewModel.errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (authViewModel.errorMessage != null)
                  const SizedBox(height: 16),

                // Personal Information
                Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 16),

                // Name field
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Email field
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Phone field
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Vehicle Information
                Text(
                  'Vehicle Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 16),

                // License plate field
                CustomTextField(
                  controller: _licensePlateController,
                  labelText: 'License Plate',
                  hintText: 'Enter your license plate',
                  prefixIcon: Icons.directions_car_outlined,
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your license plate';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Vehicle type dropdown
                DropdownButtonFormField<String>(
                  value: _selectedVehicleType,
                  decoration: InputDecoration(
                    labelText: 'Vehicle Type',
                    prefixIcon: const Icon(Icons.car_rental),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  items: _vehicleTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type.capitalize()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedVehicleType = value!;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Vehicle model field
                CustomTextField(
                  controller: _modelController,
                  labelText: 'Vehicle Model (Optional)',
                  hintText: 'e.g., Toyota Corolla, Honda City',
                  prefixIcon: Icons.directions_car,
                ),

                const SizedBox(height: 16),

                // Vehicle color dropdown
                DropdownButtonFormField<String>(
                  value: _selectedColor,
                  decoration: InputDecoration(
                    labelText: 'Vehicle Color',
                    prefixIcon: const Icon(Icons.palette),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  items: _vehicleColors.map((color) {
                    return DropdownMenuItem<String>(
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
                    setState(() {
                      _selectedColor = value!;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // Security
                Text(
                  'Security',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 16),

                // Password field
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Confirm password field
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  hintText: 'Confirm your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Register button
                CustomButton(
                  text: 'Register',
                  isLoading: authViewModel.isLoading,
                  onPressed: _register,
                ),

                const SizedBox(height: 24),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    TextButton(
                      onPressed: () {
                        _navigationService.navigateTo(context, AppRoutes.login);
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
      default:
        return Colors.grey[400]!;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

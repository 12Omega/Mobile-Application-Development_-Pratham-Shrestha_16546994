import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreenFixed extends StatefulWidget {
  const ProfileScreenFixed({super.key});

  @override
  State<ProfileScreenFixed> createState() => _ProfileScreenFixedState();
}

class _ProfileScreenFixedState extends State<ProfileScreenFixed> {
  // Mock user data - replace with actual user data from your state management
  final String userName = "John Doe";
  final String userEmail = "john.doe@example.com";
  final String userPhone = "+1 234 567 8900";

  // Settings state
  bool notificationsEnabled = true;
  bool parkingUpdates = true;
  bool bookingReminders = true;
  bool promotionalOffers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 24),

            // Profile Information Section
            _buildSectionTitle('Profile Information'),
            const SizedBox(height: 8),
            _buildProfileInfoCard(),
            const SizedBox(height: 24),

            // Vehicle Information Section
            _buildSectionTitle('Vehicle Information'),
            const SizedBox(height: 8),
            _buildVehicleInfoCard(),
            const SizedBox(height: 24),

            // Payment Methods Section
            _buildSectionTitle('Payment Methods'),
            const SizedBox(height: 8),
            _buildPaymentMethodsCard(),
            const SizedBox(height: 24),

            // Notification Settings Section
            _buildSectionTitle('Notification Settings'),
            const SizedBox(height: 8),
            _buildNotificationSettingsCard(),
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
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                _getInitials(userName),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showEditProfileDialog(),
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

  Widget _buildProfileInfoCard() {
    return Card(
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.person,
            title: 'Full Name',
            subtitle: userName,
            onTap: () => _showEditProfileDialog(),
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.email,
            title: 'Email',
            subtitle: userEmail,
            onTap: () => _showEditProfileDialog(),
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.phone,
            title: 'Phone Number',
            subtitle: userPhone,
            onTap: () => _showEditProfileDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoCard() {
    return Card(
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.directions_car,
            title: 'Vehicle Details',
            subtitle: 'Toyota Camry - ABC 123',
            onTap: () => _showEditVehicleDialog(),
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.add,
            title: 'Add Another Vehicle',
            onTap: () => _showEditVehicleDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsCard() {
    return Card(
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.credit_card,
            title: 'Credit/Debit Cards',
            subtitle: 'Manage your cards',
            onTap: () => _showPaymentMethodsDialog(),
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.account_balance,
            title: 'Bank Account',
            subtitle: 'Add bank account',
            onTap: () => _showAddBankAccountDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettingsCard() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Enable All Notifications'),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
                if (!value) {
                  parkingUpdates = false;
                  bookingReminders = false;
                  promotionalOffers = false;
                }
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.local_parking),
            title: const Text('Parking Updates'),
            subtitle: const Text('Get notified about parking availability'),
            value: parkingUpdates && notificationsEnabled,
            onChanged: notificationsEnabled
                ? (value) {
                    setState(() {
                      parkingUpdates = value;
                    });
                  }
                : null,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.schedule),
            title: const Text('Booking Reminders'),
            subtitle: const Text('Get notified about upcoming bookings'),
            value: bookingReminders && notificationsEnabled,
            onChanged: notificationsEnabled
                ? (value) {
                    setState(() {
                      bookingReminders = value;
                    });
                  }
                : null,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.local_offer),
            title: const Text('Promotional Offers'),
            subtitle: const Text('Receive special offers and discounts'),
            value: promotionalOffers && notificationsEnabled,
            onChanged: notificationsEnabled
                ? (value) {
                    setState(() {
                      promotionalOffers = value;
                    });
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

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
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

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0] + nameParts[1][0];
    } else {
      return nameParts[0][0];
    }
  }

  // Dialog methods
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: userName);
    final emailController = TextEditingController(text: userEmail);
    final phoneController = TextEditingController(text: userPhone);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
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
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
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
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // Here you would typically update the user data in your state management
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _showEditVehicleDialog() {
    final makeController = TextEditingController(text: 'Toyota');
    final modelController = TextEditingController(text: 'Camry');
    final colorController = TextEditingController(text: 'Silver');
    final licensePlateController = TextEditingController(text: 'ABC 123');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Vehicle Information'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: makeController,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Make',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.directions_car),
                      hintText: 'e.g. Toyota, Honda, Ford',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter vehicle make';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: modelController,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Model',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.car_rental),
                      hintText: 'e.g. Camry, Civic, Focus',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter vehicle model';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: colorController,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Color',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.palette),
                      hintText: 'e.g. Red, Blue, Silver',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter vehicle color';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: licensePlateController,
                    decoration: const InputDecoration(
                      labelText: 'License Plate',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.confirmation_number),
                      hintText: 'e.g. ABC 123',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter license plate';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vehicle information updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Methods'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Existing cards
              Card(
                child: ListTile(
                  leading: const Icon(Icons.credit_card, color: Colors.blue),
                  title: const Text('Visa **** 1234'),
                  subtitle: const Text('Expires 12/26'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Card removed successfully'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.credit_card, color: Colors.red),
                  title: const Text('MasterCard **** 5678'),
                  subtitle: const Text('Expires 08/27'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Card removed successfully'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Add new card button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddCardDialog();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Card'),
                ),
              ),
            ],
          ),
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

  void _showAddCardDialog() {
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Credit/Debit Card'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: cardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Card Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.credit_card),
                      hintText: '1234 5678 9012 3456',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 19,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter card number';
                      }
                      if (value.replaceAll(' ', '').length < 16) {
                        return 'Please enter a valid card number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: expiryController,
                          decoration: const InputDecoration(
                            labelText: 'Expiry (MM/YY)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: cvvController,
                          decoration: const InputDecoration(
                            labelText: 'CVV',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.security),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name on Card',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name on card';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Card added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('ADD CARD'),
          ),
        ],
      ),
    );
  }

  void _showAddBankAccountDialog() {
    final accountNameController = TextEditingController();
    final accountNumberController = TextEditingController();
    final routingNumberController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Bank Account'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: accountNameController,
                  decoration: const InputDecoration(
                    labelText: 'Account Holder Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter account holder name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: accountNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Account Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter account number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: routingNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Routing Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter routing number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bank account added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('ADD ACCOUNT'),
          ),
        ],
      ),
    );
  }

  void _showFAQsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Frequently Asked Questions'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFAQItem(
                'How do I book a parking spot?',
                'To book a parking spot, search for a location, select an available spot, choose your duration, and complete the booking process.',
              ),
              _buildFAQItem(
                'How do I cancel a booking?',
                'Go to your Bookings tab, select the booking you want to cancel, and tap the Cancel button. Cancellation policies may apply.',
              ),
              _buildFAQItem(
                'How do I update my vehicle information?',
                'Go to Profile > Vehicle Information and tap Edit to update your vehicle details.',
              ),
              _buildFAQItem(
                'What payment methods are accepted?',
                'We accept all major credit/debit cards and bank transfers.',
              ),
              _buildFAQItem(
                'Is there a refund policy?',
                'Refunds are available for cancellations made at least 24 hours before the booking time. A cancellation fee may apply.',
              ),
            ],
          ),
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

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(answer),
        ],
      ),
    );
  }

  void _showHowToUseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Use ParkEase'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHowToUseStep(
                '1. Find Parking',
                'Search for parking near your destination using your current location or by entering an address.',
                Icons.search,
              ),
              _buildHowToUseStep(
                '2. Compare Options',
                'View available parking spots and compare prices, distances, and amenities.',
                Icons.compare_arrows,
              ),
              _buildHowToUseStep(
                '3. Select a Spot',
                'Choose an available parking spot that meets your needs.',
                Icons.local_parking,
              ),
              _buildHowToUseStep(
                '4. Book & Pay',
                'Complete your booking by selecting the duration and making payment.',
                Icons.payment,
              ),
              _buildHowToUseStep(
                '5. Park with Ease',
                'Use the app to navigate to your parking spot and show your booking confirmation when you arrive.',
                Icons.directions_car,
              ),
            ],
          ),
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

  Widget _buildHowToUseStep(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSupportDialog() {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.subject),
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
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.message),
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
                const SizedBox(height: 16),
                const Text(
                  'Our support team will respond within 24 hours.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Support request sent successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('SEND'),
          ),
        ],
      ),
    );
  }

  void _showTermsAndPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Privacy Policy'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Terms of Service',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'By using ParkEase, you agree to these terms. ParkEase provides a platform to find and book parking spaces. Users must provide accurate information and are responsible for their account.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Privacy Policy',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'ParkEase collects personal information to provide and improve our services. This includes contact details, vehicle information, location data, and payment information. We do not sell your personal data to third parties.',
              ),
              const SizedBox(height: 16),
              const Text(
                'For complete Terms of Service and Privacy Policy, please visit our website.',
              ),
            ],
          ),
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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'ParkEase',
        applicationVersion: '1.0.0',
        applicationIcon: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.local_parking_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        children: [
          const SizedBox(height: 16),
          const Text(
            'ParkEase is a smart parking solution that helps you find and book parking spaces with ease. All rights reserved. © 2025 ParkEase.',
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
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
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login screen
              context.go('/login');
            },
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }
}

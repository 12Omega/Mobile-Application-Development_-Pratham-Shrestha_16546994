import 'package:flutter/material.dart';
import 'package:parkease/core/models/user_model.dart';
import 'package:parkease/core/viewmodels/profile_viewmodel.dart';
import 'package:parkease/ui/shared/app_theme.dart';

// Payment Methods Dialog
void showPaymentMethodsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Payment Methods'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Add Credit/Debit Card'),
            onTap: () {
              Navigator.pop(context);
              showAddCardDialog(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('Add Bank Account'),
            onTap: () {
              Navigator.pop(context);
              showAddBankAccountDialog(context);
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

// Add Card Dialog
void showAddCardDialog(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();
  final nameController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add Credit/Debit Card'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: cardNumberController,
              decoration: const InputDecoration(
                labelText: 'Card Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter card number';
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
                    ),
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
                    ),
                    keyboardType: TextInputType.number,
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
              ),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              // Save card info
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment method added successfully'),
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

// Add Bank Account Dialog
void showAddBankAccountDialog(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  final accountNumberController = TextEditingController();
  final routingNumberController = TextEditingController();
  final accountNameController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add Bank Account'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: accountNumberController,
              decoration: const InputDecoration(
                labelText: 'Account Number',
                border: OutlineInputBorder(),
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
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter routing number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: accountNameController,
              decoration: const InputDecoration(
                labelText: 'Account Holder Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter account holder name';
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
            if (formKey.currentState!.validate()) {
              // Save bank account info
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bank account added successfully'),
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

// Notification Settings Dialog
void showNotificationSettingsDialog(
    BuildContext context, User user, ProfileViewModel viewModel) {
  bool notificationsEnabled = user.preferences.notifications;
  bool bookingReminders = true;
  bool promotionalNotifications = true;
  bool parkingUpdates = true;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Enable All Notifications'),
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                  if (!value) {
                    bookingReminders = false;
                    promotionalNotifications = false;
                    parkingUpdates = false;
                  }
                });
              },
            ),
            const Divider(),
            CheckboxListTile(
              title: const Text('Booking Reminders'),
              subtitle: const Text('Get notified about upcoming bookings'),
              value: bookingReminders && notificationsEnabled,
              onChanged: notificationsEnabled
                  ? (value) {
                      setState(() {
                        bookingReminders = value ?? false;
                      });
                    }
                  : null,
            ),
            CheckboxListTile(
              title: const Text('Promotional Offers'),
              subtitle: const Text('Receive special offers and discounts'),
              value: promotionalNotifications && notificationsEnabled,
              onChanged: notificationsEnabled
                  ? (value) {
                      setState(() {
                        promotionalNotifications = value ?? false;
                      });
                    }
                  : null,
            ),
            CheckboxListTile(
              title: const Text('Parking Updates'),
              subtitle: const Text('Get notified about parking availability'),
              value: parkingUpdates && notificationsEnabled,
              onChanged: notificationsEnabled
                  ? (value) {
                      setState(() {
                        parkingUpdates = value ?? false;
                      });
                    }
                  : null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              viewModel.updateNotificationPreference(notificationsEnabled);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification settings updated'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    ),
  );
}

// Help Center Dialog
void navigateToHelpCenter(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Help Center'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('FAQs'),
            onTap: () {
              Navigator.pop(context);
              showFAQsDialog(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('How to Use ParkEase'),
            onTap: () {
              Navigator.pop(context);
              showHowToUseDialog(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text('Terms & Privacy Policy'),
            onTap: () {
              Navigator.pop(context);
              showTermsAndPolicyDialog(context);
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

// FAQs Dialog
void showFAQsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Frequently Asked Questions'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildFAQItem(
              'How do I book a parking spot?',
              'To book a parking spot, search for a location, select a parking lot, choose an available spot, and complete the booking process.',
            ),
            buildFAQItem(
              'How do I cancel a booking?',
              'Go to your Bookings tab, select the booking you want to cancel, and tap the Cancel button. Cancellation policies may apply.',
            ),
            buildFAQItem(
              'How do I update my vehicle information?',
              'Go to Profile > Vehicle Information and tap Edit to update your vehicle details.',
            ),
            buildFAQItem(
              'What payment methods are accepted?',
              'We accept all major credit/debit cards and bank transfers.',
            ),
            buildFAQItem(
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

// FAQ Item
Widget buildFAQItem(String question, String answer) {
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
        const Divider(),
      ],
    ),
  );
}

// How to Use Dialog
void showHowToUseDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('How to Use ParkEase'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildHowToUseStep(
              '1. Find Parking',
              'Search for parking near your destination by entering an address or using your current location.',
              Icons.search,
            ),
            buildHowToUseStep(
              '2. Compare Options',
              'View available parking lots, compare prices, distance, and amenities.',
              Icons.compare_arrows,
            ),
            buildHowToUseStep(
              '3. Select a Spot',
              'Choose an available parking spot that meets your needs.',
              Icons.local_parking,
            ),
            buildHowToUseStep(
              '4. Book & Pay',
              'Complete your booking by selecting the duration and making payment.',
              Icons.payment,
            ),
            buildHowToUseStep(
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

// How to Use Step
Widget buildHowToUseStep(String title, String description, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryColor),
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
              Text(description),
            ],
          ),
        ),
      ],
    ),
  );
}

// Terms and Policy Dialog
void showTermsAndPolicyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Terms & Privacy Policy'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
              'By using ParkEase, you agree to these terms. ParkEase provides a platform to find and book parking spaces. Users must provide accurate information and are responsible for all activity under their account.',
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
              'For the complete Terms of Service and Privacy Policy, please visit our website.',
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

// Contact Support Dialog
void showContactSupportDialog(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Contact Support'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: subjectController,
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
              controller: messageController,
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              // Send support request
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

// About Dialog
void showAboutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AboutDialog(
      applicationName: 'ParkEase',
      applicationVersion: 'v1.0.0',
      applicationIcon: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
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
          'ParkEase is a smart parking solution that helps you find and book parking spaces with ease.',
        ),
        const SizedBox(height: 16),
        const Text(
          '© 2025 ParkEase. All rights reserved.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    ),
  );
}

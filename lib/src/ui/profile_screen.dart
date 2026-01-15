import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cardamom_analytics/src/ui/theme/theme_constants.dart';
import 'package:cardamom_analytics/src/utils/app_preferences.dart';
import 'package:cardamom_analytics/src/localization/app_localizations.dart';
import 'package:cardamom_analytics/src/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cardamom_analytics/src/services/background_sync_worker.dart';
import 'package:workmanager/workmanager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _farmController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await AppPreferences.getProfile();
    setState(() {
      _nameController.text = profile['userName'] ?? '';
      _farmController.text = profile['farmName'] ?? '';
      _locationController.text = profile['location'] ?? '';
      _emailController.text = profile['userEmail'] ?? '';
      _phoneController.text = profile['userPhone'] ?? '';
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await AppPreferences.setProfile(
        userName: _nameController.text,
        farmName: _farmController.text,
        location: _locationController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).updated)),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: ThemeConstants.creamApp,
      appBar: AppBar(
        title: Text(l10n.profile, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: ThemeConstants.forestGreen,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: ThemeConstants.forestGreen, width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, size: 60, color: ThemeConstants.forestGreen),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildLabel(l10n.userName),
                  _buildTextField(_nameController, Icons.person_outline),
                  
                  const SizedBox(height: 20),
                  
                  _buildLabel(l10n.farmName),
                  _buildTextField(_farmController, Icons.agriculture_outlined),
                  
                  const SizedBox(height: 20),
                  
                  _buildLabel(l10n.location),
                  _buildTextField(_locationController, Icons.location_on_outlined),

                  const SizedBox(height: 20),
                  
                  _buildLabel(l10n.email),
                  _buildTextField(_emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress),

                  const SizedBox(height: 20),
                  
                  _buildLabel(l10n.phoneNumber),
                  _buildTextField(_phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone),
                  
                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ThemeConstants.forestGreen.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.security_outlined, size: 20, color: ThemeConstants.forestGreen),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.profilePrivacyNote,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConstants.forestGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.saveProfile,
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                   ),
                  
                  const SizedBox(height: 48),
                  
                  // Debug Section
                  Text(
                    "DEBUG TOOLS (TESTING ONLY)",
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red.shade300),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final notificationService = NotificationService();
                            await notificationService.showNewAuctionNotification(
                              auctioneer: "TEST AUCTIONEER",
                              avgPrice: 2500.0,
                              maxPrice: 2850.0,
                              date: DateTime.now(),
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Test notification triggered!")),
                              );
                            }
                          },
                          icon: const Icon(Icons.notifications_active_outlined),
                          label: const Text("Test Alert", style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ThemeConstants.forestGreen,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                             final prefs = await SharedPreferences.getInstance();
                             await prefs.remove('last_notified_auction_date');
                             if (mounted) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text("Baseline reset. Background worker will notify for latest data on next run.")),
                               );
                             }
                          },
                          icon: const Icon(Icons.restart_alt),
                          label: const Text("Reset Baseline", style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // Trigger the same logic used in the background isolate
                        // but run it in foreground for testing.
                        setState(() => _isLoading = true);
                        try {
                           // We can't easily call callbackDispatcher() directly as it's meant for isolates
                           // and uses top-level Workmanager stuff, but we can call the service logic.
                           // For simplicity in testing, we'll use Workmanager to trigger an immediate one-off task.
                           await Workmanager().registerOneOffTask(
                             "debug-manual-check-${DateTime.now().millisecondsSinceEpoch}",
                             "checkNewAuctions",
                             inputData: {"debug": true},
                           );
                           if (mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text("One-off background task registered! Close the app now to see notifications.")),
                             );
                           }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Failed to trigger task: $e")),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      icon: const Icon(Icons.run_circle_outlined),
                      label: const Text("Run Background Check Now"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.outfit(),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: ThemeConstants.forestGreen),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ThemeConstants.forestGreen, width: 1.5),
        ),
      ),
    );
  }
}

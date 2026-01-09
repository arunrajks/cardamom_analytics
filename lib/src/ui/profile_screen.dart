import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cardamom_analytics/src/ui/theme/theme_constants.dart';
import 'package:cardamom_analytics/src/utils/app_preferences.dart';
import 'package:cardamom_analytics/src/localization/app_localizations.dart';

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

  Widget _buildTextField(TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
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

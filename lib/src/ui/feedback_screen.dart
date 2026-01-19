import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cardamom_analytics/src/ui/theme/theme_constants.dart';
import 'package:cardamom_analytics/src/localization/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _feedbackController = TextEditingController();
  bool _isLoading = false;

  final String developerEmail = "apps.spicekraft@gmail.com";

  Future<void> _sendViaEmail() async {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text.isEmpty ? "Anonymous" : _nameController.text;
      final String email = _emailController.text.isEmpty ? "Not provided" : _emailController.text;
      final String body = "Farmer Feedback\n\n"
          "Name: $name\n"
          "Email: $email\n\n"
          "Feedback:\n${_feedbackController.text}";
      
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: developerEmail,
        query: _encodeQueryParameters({
          'subject': 'Cardamom Analytics Feedback',
          'body': body,
        }),
      );

      try {
        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
          _onSuccess();
        } else {
          // If canLaunchUrl fails, we try launching anyway as it sometimes fails falsely on Android
          await launchUrl(emailUri);
          _onSuccess();
        }
      } catch (e) {
        _showError("Could not open email app. Please ensure an email account is configured.");
      }
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  void _onSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).feedbackSuccess),
        backgroundColor: ThemeConstants.secondaryGreen,
      ),
    );
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: ThemeConstants.creamApp,
      appBar: AppBar(
        title: Text(l10n.feedback, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: ThemeConstants.forestGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ThemeConstants.primaryGreen.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ThemeConstants.primaryGreen.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: ThemeConstants.headingOrange, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        l10n.feedbackDesc,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ThemeConstants.forestGreen,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              _buildLabel(l10n.nameOptional),
              _buildTextField(_nameController, Icons.person_outline),
              
              const SizedBox(height: 20),
              
              _buildLabel(l10n.emailOptional),
              _buildTextField(_emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              
              const SizedBox(height: 20),
              
              _buildLabel(l10n.feedback),
              _buildTextField(
                _feedbackController, 
                Icons.chat_bubble_outline, 
                maxLines: 5,
                hint: l10n.feedbackHint,
                validator: (val) => (val == null || val.isEmpty) ? l10n.feedbackEmptyError : null,
              ),
              
              const SizedBox(height: 40),
              
              _buildActionButton(
                onPressed: _sendViaEmail,
                label: l10n.translate('send_feedback'),
                icon: Icons.alternate_email,
                color: ThemeConstants.forestGreen,
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

  Widget _buildTextField(
    TextEditingController controller, 
    IconData icon, {
    TextInputType? keyboardType, 
    int maxLines = 1,
    String? hint,
    String? Function(String?)? validator
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.outfit(),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? (maxLines * 15.0) : 0),
          child: Icon(icon, color: ThemeConstants.forestGreen),
        ),
        hintText: hint,
        hintStyle: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 14),
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

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }
}

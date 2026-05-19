import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sakai_shared/sakai_shared.dart';

/// Language option data class.
class _LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final bool isImplemented;

  const _LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    this.isImplemented = false,
  });
}

/// Available languages.
class _Languages {
  static const String _prefKey = 'selected_language';
  static const String _englishCode = 'en';

  static const List<_LanguageOption> options = [
    _LanguageOption(
      code: _englishCode,
      name: 'English',
      nativeName: 'English',
      isImplemented: true,
    ),
    _LanguageOption(
      code: 'fil',
      name: 'Filipino / Tagalog',
      nativeName: 'Filipino',
      isImplemented: false,
    ),
    _LanguageOption(
      code: 'es',
      name: 'Spanish',
      nativeName: 'Espanol',
      isImplemented: false,
    ),
    _LanguageOption(
      code: 'zh',
      name: 'Chinese',
      nativeName: 'Chinese',
      isImplemented: false,
    ),
  ];
}

/// Language selection screen allowing users to choose their preferred language.
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = _Languages._englishCode;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved =
        prefs.getString(_Languages._prefKey) ?? _Languages._englishCode;
    setState(() {
      _selectedLanguage = saved;
      _isLoading = false;
    });
  }

  Future<void> _saveLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_Languages._prefKey, code);
  }

  void _onLanguageSelected(_LanguageOption option) {
    if (!option.isImplemented) {
      _showComingSoonDialog(option);
      return;
    }

    setState(() => _selectedLanguage = option.code);
    _saveLanguage(option.code);

    if (mounted) {
      SakaiSnackBar.success(context, 'Language preference saved');
    }
  }

  void _showComingSoonDialog(_LanguageOption option) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text(
          '${option.nativeName} (${option.name}) translation is not yet available. '
          'We are working on adding support for this language.',
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SakaiSurfaceCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Select your preferred language. '
                          'Note: Some languages are still in development.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ..._Languages.options.map(
                  (option) => _LanguageTile(
                    option: option,
                    selectedCode: _selectedLanguage,
                    onTap: () => _onLanguageSelected(option),
                  ),
                ),
              ],
            ),
    );
  }
}

// ─── Language Tile ────────────────────────────────────────────────

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.option,
    required this.selectedCode,
    required this.onTap,
  });

  final _LanguageOption option;
  final String selectedCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = option.code == selectedCode;

    return SakaiSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.circle_outlined,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.nativeName,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (!option.isImplemented) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Coming Soon',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isSelected)
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:islamic_library_flutter/data/services/notification_service.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';
import 'package:islamic_library_flutter/presentation/providers/locale_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_library_flutter/core/utils/scaffold_utils.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  void _showLanguageSelector(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final currentLocale = ref.watch(localeProvider);

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.selectLanguage,
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _buildLanguageOption(
                context,
                ref,
                l10n.arabic,
                currentLocale.languageCode == 'ar',
                const Locale('ar'),
              ),
              _buildLanguageOption(
                context,
                ref,
                l10n.english,
                currentLocale.languageCode == 'en',
                const Locale('en'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    bool isSelected,
    Locale locale,
  ) {
    return ListTile(
      title: Text(
        label,
        style: GoogleFonts.cairo(
          color: isSelected ? AppTheme.primaryColor : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppTheme.primaryColor)
          : null,
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(locale);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              )
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () => GlobalScaffoldService.openDrawer(),
                ),
              ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(l10n.notificationsAthan, l10n),
          _buildAthanSettings(l10n),
          _buildSettingTile(
            icon: Icons.settings_applications_rounded,
            title: l10n.manageNotificationSettings,
            subtitle: l10n.manageNotificationSettingsSubtitle,
            onTap: () async {
              await openAppSettings();
            },
          ),
          _buildSettingTile(
            icon: Icons.notification_important_rounded,
            title: 'Test Notification',
            subtitle: 'Tap to verify alerts are working',
            onTap: () async {
              await NotificationService().showTestNotification();
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(l10n.appearanceLanguage, l10n),
          _buildSettingTile(
            icon: Icons.dark_mode_rounded,
            title: l10n.darkMode,
            subtitle: l10n.darkModeSubtitle,
            trailing: const Icon(
              Icons.check_circle,
              color: AppTheme.primaryColor,
            ),
          ),
          _buildSettingTile(
            icon: Icons.language_rounded,
            title: l10n.appLanguage,
            subtitle: locale.languageCode == 'ar' ? l10n.arabic : l10n.english,
            onTap: () => _showLanguageSelector(context, ref, l10n),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(l10n.aboutApp, l10n),
          _buildSettingTile(
            icon: Icons.info_outline_rounded,
            title: l10n.appVersion,
            subtitle: _version.isEmpty ? '...' : _version,
          ),
          _buildSettingTile(
            icon: Icons.share_rounded,
            title: l10n.shareApp,
            onTap: () {
              SharePlus.instance.share(
                ShareParams(
                  text:
                      '${l10n.appTitle}: Your comprehensive Muslim companion for Holy Quran, Azkar, and Prayer Times.\nhttps://play.google.com/store/apps/details?id=com.islam.home',
                ),
              );
            },
          ),
          _buildSettingTile(
            icon: Icons.star_outline_rounded,
            title: l10n.rateApp,
            onTap: () async {
              final url = Uri.parse(
                'https://play.google.com/store/apps/details?id=com.islam.home',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              '${l10n.appTitle} v${_version.isEmpty ? '...' : _version}',
              style: GoogleFonts.montserrat(
                color: Colors.white24,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 100), // Bottom padding for miniplayer
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildAthanSettings(AppLocalizations l10n) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, box, widget) {
        final notificationsEnabled = box.get(
          'notifications_enabled',
          defaultValue: true,
        );

        return _buildSettingTile(
          icon: Icons.notifications_active_rounded,
          title: l10n.athanNotifications,
          subtitle: notificationsEnabled ? l10n.enabledForAll : l10n.disabled,
          trailing: Switch.adaptive(
            value: notificationsEnabled,
            activeThumbColor: AppTheme.primaryColor,
            onChanged: (value) async {
              await box.put('notifications_enabled', value);
              if (!value) {
                await NotificationService().cancelAll();
              }
            },
          ),
          isFirst: true,
          isLast: true,
        );
      },
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
              )
            : null,
        trailing:
            trailing ??
            (onTap != null
                ? const Icon(Icons.chevron_right, color: Colors.white24)
                : null),
      ),
    );
  }
}

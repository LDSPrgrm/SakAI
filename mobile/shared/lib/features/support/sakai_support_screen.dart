import 'package:flutter/material.dart';

import '../../theme/sakai_design_tokens.dart';
import '../../widgets/sakai_bottom_action_bar.dart';
import '../../widgets/sakai_list_tile.dart';
import '../../widgets/sakai_primary_button.dart';
import '../../widgets/sakai_screen_scaffold.dart';
import '../../widgets/sakai_secondary_button.dart';
import '../../widgets/sakai_surface_card.dart';
import '../../widgets/sakai_text_field.dart';

/// A single frequently-asked question rendered as an expandable card.
class SakaiSupportFaq {
  const SakaiSupportFaq({required this.question, required this.answer});

  final String question;
  final String answer;
}

/// A direct-contact affordance (hotline, email, chat) shown in the contact tab.
///
/// [onTap] is owned by the host app so the shared package stays free of
/// `url_launcher` / routing dependencies.
class SakaiSupportContactAction {
  const SakaiSupportContactAction({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
}

/// Configuration for the "send a ticket" form. Omit to hide the form entirely
/// (used by roles that only offer direct-contact channels).
class SakaiSupportTicketForm {
  const SakaiSupportTicketForm({
    required this.onSubjectChanged,
    required this.onMessageChanged,
    required this.onSubmit,
    this.heading = 'Send a Message',
    this.description =
        'Have an issue? Fill out the form below and our team will get back to you as soon as possible.',
    this.subjectLabel = 'Subject',
    this.subjectHint = 'e.g., Payment issue, App crash',
    this.messageLabel = 'Message',
    this.messageHint = 'Describe your issue in detail...',
    this.submitLabel = 'Submit Ticket',
    this.submittingLabel = 'Submitting…',
    this.canSubmit = false,
    this.isSubmitting = false,
  });

  final ValueChanged<String> onSubjectChanged;
  final ValueChanged<String> onMessageChanged;
  final VoidCallback onSubmit;
  final String heading;
  final String description;
  final String subjectLabel;
  final String subjectHint;
  final String messageLabel;
  final String messageHint;
  final String submitLabel;
  final String submittingLabel;
  final bool canSubmit;
  final bool isSubmitting;
}

/// Configuration for the emergency SOS callout. Omit to hide the callout.
///
/// The callout intentionally keeps the documented error-surface exception:
/// error role colors on a tinted error container.
class SakaiSupportEmergency {
  const SakaiSupportEmergency({
    required this.onTrigger,
    this.title = 'Emergency SOS',
    this.description =
        'If you feel unsafe during an active ride, use the SOS feature to alert emergency contacts and SakAI response teams.',
    this.buttonLabel = 'Trigger SOS',
  });

  final VoidCallback onTrigger;
  final String title;
  final String description;
  final String buttonLabel;
}

/// Role-parameterized support screen shared by the passenger and driver apps.
///
/// Layout follows the passenger design: a two-tab scaffold with expandable FAQ
/// cards and a contact tab that can host a ticket form, direct-contact tiles,
/// and an emergency SOS callout. Every role-specific string, FAQ entry, and
/// action is injected by the host app; this widget holds no app state,
/// routing, or platform-channel dependency.
class SakaiSupportScreen extends StatefulWidget {
  const SakaiSupportScreen({
    super.key,
    required this.faqs,
    this.title = 'Support & Help',
    this.faqTabLabel = 'FAQs',
    this.contactTabLabel = 'Contact Us',
    this.ticketForm,
    this.contactActions = const <SakaiSupportContactAction>[],
    this.contactActionsHeading = 'Still need help?',
    this.emergency,
  });

  final List<SakaiSupportFaq> faqs;
  final String title;
  final String faqTabLabel;
  final String contactTabLabel;
  final SakaiSupportTicketForm? ticketForm;
  final List<SakaiSupportContactAction> contactActions;
  final String contactActionsHeading;
  final SakaiSupportEmergency? emergency;

  @override
  State<SakaiSupportScreen> createState() => _SakaiSupportScreenState();
}

class _SakaiSupportScreenState extends State<SakaiSupportScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = SakaiDesignTokens.of(context);

    return SakaiScreenScaffold(
      title: widget.title,
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
            tabs: [
              Tab(
                text: widget.faqTabLabel,
                icon: const Icon(Icons.help_outline),
              ),
              Tab(
                text: widget.contactTabLabel,
                icon: const Icon(Icons.email_outlined),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceMd),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFaqTab(tokens, theme),
                _buildContactTab(tokens, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTab(SakaiDesignTokens tokens, ThemeData theme) {
    return ListView.separated(
      itemCount: widget.faqs.length,
      separatorBuilder: (context, index) => SizedBox(height: tokens.spaceSm),
      itemBuilder: (context, index) {
        final faq = widget.faqs[index];
        final isExpanded = _expandedIndex == index;

        return SakaiSurfaceCard(
          onTap: () {
            setState(() {
              _expandedIndex = isExpanded ? null : index;
            });
          },
          padding: EdgeInsets.all(tokens.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: theme.colorScheme.primary,
                    size: tokens.iconSm,
                  ),
                  SizedBox(width: tokens.spaceSm),
                  Expanded(
                    child: Text(
                      faq.question,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              if (isExpanded) ...[
                SizedBox(height: tokens.spaceSm),
                Text(
                  faq.answer,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactTab(SakaiDesignTokens tokens, ThemeData theme) {
    final form = widget.ticketForm;
    final emergency = widget.emergency;
    final isSubmitting = form?.isSubmitting ?? false;

    final sections = <Widget>[];

    if (form != null) {
      sections.addAll([
        Text(
          form.heading,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: tokens.spaceSm),
        Text(
          form.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: tokens.spaceLg),
        SakaiTextField(
          label: form.subjectLabel,
          hint: form.subjectHint,
          onChanged: form.onSubjectChanged,
          enabled: !isSubmitting,
        ),
        SizedBox(height: tokens.spaceMd),
        SakaiTextField(
          label: form.messageLabel,
          hint: form.messageHint,
          maxLines: 5,
          onChanged: form.onMessageChanged,
          enabled: !isSubmitting,
        ),
      ]);
    }

    if (widget.contactActions.isNotEmpty) {
      if (sections.isNotEmpty) {
        sections.addAll([
          SizedBox(height: tokens.spaceXl),
          Divider(color: theme.colorScheme.outlineVariant),
          SizedBox(height: tokens.spaceLg),
        ]);
      }
      sections.addAll([
        Text(
          widget.contactActionsHeading,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: tokens.spaceSm),
        SakaiSurfaceCard(
          padding: EdgeInsets.symmetric(vertical: tokens.spaceXs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final action in widget.contactActions)
                SakaiListTile(
                  leading: Icon(
                    action.icon,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(action.title),
                  subtitle: action.subtitle == null
                      ? null
                      : Text(action.subtitle!),
                  onTap: action.onTap,
                ),
            ],
          ),
        ),
      ]);
    }

    if (emergency != null) {
      if (sections.isNotEmpty) {
        sections.addAll([
          SizedBox(height: tokens.spaceXl),
          Divider(color: theme.colorScheme.outlineVariant),
          SizedBox(height: tokens.spaceLg),
        ]);
      }
      sections.add(_buildEmergencySos(tokens, theme, emergency));
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(0, 0, 0, tokens.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sections,
            ),
          ),
        ),
        if (form != null)
          SakaiBottomActionBar(
            actions: [
              SakaiPrimaryButton(
                label: isSubmitting ? form.submittingLabel : form.submitLabel,
                onPressed: form.canSubmit && !isSubmitting ? form.onSubmit : null,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildEmergencySos(
    SakaiDesignTokens tokens,
    ThemeData theme,
    SakaiSupportEmergency emergency,
  ) {
    return Container(
      padding: EdgeInsets.all(tokens.spaceMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: theme.colorScheme.error,
                size: tokens.iconMd,
              ),
              SizedBox(width: tokens.spaceSm),
              Text(
                emergency.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceSm),
          Text(
            emergency.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          SizedBox(height: tokens.spaceMd),
          SakaiSecondaryButton(
            label: emergency.buttonLabel,
            onPressed: emergency.onTrigger,
          ),
        ],
      ),
    );
  }
}

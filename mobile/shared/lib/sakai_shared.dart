/// Shared UI, theming, and OpenAPI client for SakAI Flutter apps.
library;

// API layer (existing)
export 'api/onboarding_service.dart';
export 'api/token_storage.dart';
export 'api/auth_interceptor.dart';
export 'api/sakai_api_support.dart';

// Cross-app features
export 'features/otp/otp_enabled.dart';
export 'features/otp/otp_notifier.dart';
export 'features/otp/otp_repository.dart';

// Domain models (new — stable wrappers around generated types)
export 'models/backend_unavailable_exception.dart';
export 'models/models.dart';
export 'repositories/sos_repository.dart';

// WebSocket client (new)
export 'ws/ws_events.dart';
export 'ws/ws_client.dart';

// API client (generated — do not hand-edit)
// Hide PaymentMethod to avoid conflict with domain-level PaymentMethod in ride_entity.dart
export 'package:sakai_api_client/sakai_api_client.dart' hide PaymentMethod;

// Theme
export 'theme/sakai_design_tokens.dart';
export 'theme/sakai_theme.dart';
export 'theme/sakai_semantic_colors.dart';
export 'theme/sakai_theme_config.dart';

// Validators
export 'validators/sakai_validators.dart';

// Widgets
export 'widgets/async_value_view.dart';
export 'widgets/coming_soon_state.dart';
export 'widgets/sakai_app_bar.dart';
export 'widgets/sakai_avatar.dart';
export 'widgets/sakai_bottom_action_bar.dart';
export 'widgets/sakai_countdown_chip.dart';
export 'widgets/sakai_dialog.dart';
export 'widgets/sakai_divider.dart';
export 'widgets/sakai_empty_state.dart';
export 'widgets/sakai_error_alert.dart';
export 'widgets/sakai_error_state.dart';
export 'widgets/sakai_fare_chip.dart';
export 'widgets/sakai_form_field.dart';
export 'widgets/sakai_glass_card.dart';
export 'widgets/sakai_list_tile.dart';
export 'widgets/sakai_loading_overlay.dart';
export 'widgets/sakai_loading_skeleton.dart';
export 'widgets/sakai_modal_sheet.dart';
export 'widgets/sakai_otp_input.dart';
export 'widgets/sakai_primary_button.dart';
export 'widgets/sakai_screen_scaffold.dart';
export 'widgets/sakai_secondary_button.dart';
export 'widgets/sakai_section_header.dart';
export 'widgets/sakai_snack_bar.dart';
export 'widgets/sakai_status_badge.dart';
export 'widgets/sakai_surface_card.dart';
export 'widgets/sakai_text_field.dart';
export 'widgets/sakai_welcome_carousel.dart';

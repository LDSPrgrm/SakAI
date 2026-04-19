/// Shared UI, theming, and OpenAPI client for SakAI Flutter apps.
library;

// API layer (existing)
export 'api/onboarding_service.dart';
export 'api/token_storage.dart';
export 'api/auth_interceptor.dart';
export 'api/sakai_api_support.dart';

// Domain models (new — stable wrappers around generated types)
export 'models/models.dart';

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

// Widgets
export 'widgets/sakai_glass_card.dart';
export 'widgets/sakai_primary_button.dart';
export 'widgets/sakai_screen_scaffold.dart';
export 'widgets/sakai_secondary_button.dart';
export 'widgets/sakai_surface_card.dart';
export 'widgets/sakai_text_field.dart';
export 'widgets/sakai_welcome_carousel.dart';

/// Providers Barrel Export
///
/// Import all providers with: `import 'package:safeNest/core/providers/providers.dart';`

export 'api_provider.dart';
export 'auth_notifier.dart';
export 'database_provider.dart';

// Repository providers are exported from repositories barrel
// to avoid circular dependencies
export '../repositories/auth_repository.dart' show authRepositoryProvider;
export '../repositories/sos_repository.dart' show sosRepositoryProvider;
export '../repositories/messaging_repository.dart'
    show messagingRepositoryProvider;
export '../repositories/report_repository.dart' show reportRepositoryProvider;
export '../repositories/support_center_repository.dart'
    show supportCenterRepositoryProvider;
export '../repositories/training_repository.dart'
    show trainingRepositoryProvider;

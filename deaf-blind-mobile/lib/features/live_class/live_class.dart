/// §1 Live class — LiveKit video meetings (feature barrel).
library;

// Domain
export 'domain/models/meeting.dart';
export 'domain/models/meeting_room_phase.dart';

// Presentation — public entry points for other features
export 'presentation/screens/meeting_lobby_screen.dart';
export 'presentation/screens/meeting_room_screen.dart';

// Providers (for shell / tests)
export 'presentation/providers/meeting_providers.dart';

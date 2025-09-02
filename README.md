# Nail Exam Simulator

A mobile application simulating the Korean Nail Technician Practical Examination to help students practice exam procedures and sequence learning.

## Project Status

**Current Phase: Phase 1 - Core Framework Setup ✅**

### Completed Features
- ✅ Flutter project initialization with proper structure
- ✅ MVP architecture implementation
- ✅ Singleton manager classes (Game, Timer, Storage)
- ✅ Local storage system with JSON serialization
- ✅ Basic navigation flow and screen routing
- ✅ Data model definitions
- ✅ Unit test framework setup

## Architecture

This project follows the MVP (Model-View-Presenter) pattern:

```
lib/
├── core/                   # Core utilities and constants
├── data/models/           # Data models with JSON serialization
├── managers/              # Singleton managers (Game, Timer, Storage)
├── presentation/          # UI layer (screens, presenters, widgets)
├── navigation/            # App routing
├── main.dart             # App entry point
└── app.dart              # Main app configuration
```

## Getting Started

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK (included with Flutter)
- Android Studio or VS Code with Flutter extensions

### Installation

1. Clone the repository
2. Install dependencies:
```bash
flutter pub get
```

3. Generate JSON serialization code:
```bash
flutter packages pub run build_runner build
```

4. Run the app:
```bash
flutter run
```

### Testing

Run all tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/managers/game_manager_test.dart
```

## Features (Phase 1)

### Core Managers
- **GameManager**: Handles exam sessions, period management, and scoring
- **TimerManager**: Manages exam and period timers with warnings
- **LocalStorageManager**: Handles persistent data storage

### Data Models
- **ExamSession**: Complete exam session with periods and scoring
- **PeriodData**: Individual period data with actions and scores
- **ActionLog**: User action logging for analysis
- **ScoreData**: Scoring calculations and grade determination

### Screens
- **HomeScreen**: Main dashboard with session history and stats
- **ExamSetupScreen**: Exam configuration and instructions
- **ExamScreen**: Main exam interface (work area placeholder)
- **ResultsScreen**: Score breakdown and performance analysis

## Exam Structure

The simulator includes 5 periods, each 30 minutes long:

1. **Hand Polish Application** - Full color, French, Deep French, Gradient
2. **Foot Polish Application** - Same techniques as Period 1
3. **Gel Nail Art** - Fan pattern, Line marble
4. **Nail Extension** - Silk, Tip with silk, Acrylic, Gel
5. **Extension Removal** - File-down simulation

## Scoring System

Each period is scored on four criteria:
- **Sequence Accuracy** (40%) - Following correct procedure order
- **Time Management** (20%) - Efficient use of allocated time
- **Hygiene Protocol** (20%) - Proper sanitation practices
- **Technique Quality** (20%) - Execution of nail techniques

## Development Phases

- [x] **Phase 1**: Core Framework Setup
- [ ] **Phase 2**: UI Foundation & Asset Integration
- [ ] **Phase 3**: Period 1 Implementation (Hand Polish)
- [ ] **Phase 4**: Period 2 Implementation (Foot Polish)
- [ ] **Phase 5**: Period 3 Implementation (Gel Art)
- [ ] **Phase 6**: Period 4 Implementation (Extension)
- [ ] **Phase 7**: Period 5 Implementation (Removal)
- [ ] **Phase 8**: Polish & Enhancement

## Project Structure Details

### Data Flow
1. User starts exam → GameManager creates session
2. Session stored locally → LocalStorageManager handles persistence
3. Timer started → TimerManager tracks time and warnings
4. User actions logged → ActionLog records for scoring
5. Period completed → Scoring algorithm calculates results

### Key Design Decisions
- **Offline-first**: All data stored locally, no server required
- **Practice vs Exam modes**: Different timing and pause rules
- **JSON serialization**: Easy data persistence and debugging
- **MVP pattern**: Clear separation of concerns
- **Singleton managers**: Global state management

## Contributing

When adding new features:

1. Follow the existing MVP pattern
2. Add unit tests for new functionality
3. Update this README if architecture changes
4. Use the existing singleton managers for state
5. Follow Flutter/Dart style guidelines

## License

This project is for educational purposes in nail technician training.

# Nail Technician Practical Exam Simulation App - Development Request Document

## Project Overview

### Purpose
Develop a mobile application simulating the Korean Nail Technician Practical Examination to help students practice exam procedures and sequence learning. The app focuses on procedural accuracy rather than realistic graphics, emphasizing correct technique sequences and timing.

### Core Concept
- **Platform**: Flutter (iOS/Android)
- **View**: 2.5D Isometric perspective
- **Storage**: Local device storage only
- **Target Users**: Nail technician exam candidates

## Technical Architecture

### Design Pattern
```
MVP (Model-View-Presenter) Architecture
├── Models/
│   ├── ExamSession.dart
│   ├── ScoreData.dart
│   └── ToolInventory.dart
├── Views/
│   ├── ExamScreens/
│   └── UIComponents/
├── Presenters/
│   ├── ExamPresenter.dart
│   └── ScoringPresenter.dart
└── Managers/ (Singleton)
    ├── GameManager.dart
    ├── TimerManager.dart
    └── LocalStorageManager.dart
```

### Core Dependencies
```yaml
dependencies:
  flutter: sdk
  provider: ^6.0.0  # State management
  shared_preferences: ^2.0.0  # Local storage
  path_provider: ^2.0.0  # File system access
  flame: ^1.0.0  # Game engine features (optional)
```

## Functional Requirements

### Base System Features

#### Timer System
- Countdown timer for each period (30 minutes per period)
- Total exam timer (2.5 hours)
- Visual and audio warnings at 5-minute intervals
- Pause functionality for practice mode

#### Scoring System
```dart
ScoreComponents:
- Sequence accuracy (40%)
- Time management (20%)
- Hygiene protocol (20%)
- Technique completion (20%)
```

#### Gesture Recognition
- **Drag**: Polish application, filing motions
- **Tap**: Tool selection, color picking
- **Hold**: Cuticle softener application
- **Swipe**: Buffing, cleaning actions
- **Pinch**: Zoom for detailed work

### Visual Components

#### 2.5D Isometric Layout
```
Screen Division:
┌─────────────────────────┐
│    Timer & Score Bar    │
├─────────────────────────┤
│                         │
│    Work Area            │
│    (Isometric View)     │
│                         │
├─────────────────────────┤
│    Tool Tray            │
└─────────────────────────┘
```

#### Minimum Viable Assets
1. **Base Images**
   - Hand sprite (top-down isometric view)
   - 10 nail segments (individual fingernails)

2. **Nail States** (per nail)
   - Clean base state
   - With cuticle state
   - Polished state

3. **Tools** (5-10 items)
   - Nail file
   - Buffer
   - Cuticle pusher
   - Polish brush
   - Nail tips
   - Cotton pad
   - Cuticle nipper

4. **Polish Colors** (5 basic)
   - Clear base/top coat
   - Red
   - Pink
   - White (for French)
   - Nude

## Exam Period Implementation

### Period 1: Hand Polish Application
**Techniques**: Full color, French, Deep French, Gradient (Random selection)

**Implementation Requirements**:
- Polish selection interface
- Drag-to-apply mechanism
- Coverage detection algorithm
- Smile line accuracy measurement for French techniques
- Gradient blending visualization

**Sequence Validation**:
1. Base coat application
2. Color application (technique-specific)
3. Top coat application
4. Cleanup around edges

### Period 2: Foot Polish Application
**Techniques**: Same as Period 1, applied to foot

**Implementation Requirements**:
- Foot sprite display
- Adjusted gesture recognition for toe nails
- Same techniques as Period 1
- Modified scoring for toe nail specifics

### Period 3: Gel Nail Art
**Techniques**: Fan pattern, Line marble (Random selection)

**Implementation Requirements**:
- Pattern template overlay
- Drag-to-draw functionality
- Pattern accuracy detection
- UV lamp simulation (timer-based)

### Period 4: Nail Extension
**Techniques**: Silk, Tip with silk, Acrylic, Gel (Random selection)

**Implementation Requirements**:
- Nail tip selection interface
- Drag-and-drop tip placement
- Length adjustment slider
- Form application simulation
- Material-specific application gestures

### Period 5: Extension Removal
**Implementation Requirements**:
- File-down simulation (swipe gesture)
- Progress bar for removal completion
- Damage detection (penalty for over-filing)

## Development Phases

### Phase 1: Core Framework Setup
**Deliverables**:
- Project structure initialization
- MVP architecture implementation
- Singleton manager classes
- Local storage system
- Basic navigation flow

**Key Files**:
```dart
// GameManager.dart
class GameManager {
  static final instance = GameManager._();
  ExamSession? currentSession;
  int currentPeriod = 1;
  Map<int, PeriodResult> results = {};
}

// LocalStorageManager.dart
class LocalStorageManager {
  static final instance = LocalStorageManager._();
  Future<void> saveProgress(ExamSession session);
  Future<ExamSession?> loadProgress();
}
```

### Phase 2: UI Foundation & Asset Integration
**Deliverables**:
- 2.5D isometric view setup
- Asset loading system
- Tool tray implementation
- Gesture detection framework
- Timer display system

**Key Components**:
```dart
// IsometricWorkArea.dart
class IsometricWorkArea extends StatefulWidget {
  final Function(Offset) onDragUpdate;
  final Function(Tool) onToolSelected;
}
```

### Phase 3: Period 1 Implementation (Hand Polish)
**Deliverables**:
- Polish application mechanics
- Technique selection system
- Scoring algorithm for Period 1
- Visual feedback system

**Validation Logic**:
```dart
class PolishValidator {
  bool validateSequence(List<Action> actions);
  double calculateCoverage(NailArea area);
  double measureSmileLineAccuracy(Line drawn, Line target);
}
```

### Phase 4: Period 2 Implementation (Foot Polish)
**Deliverables**:
- Foot view adaptation
- Modified interaction zones
- Period 2 specific scoring

### Phase 5: Period 3 Implementation (Gel Art)
**Deliverables**:
- Pattern drawing system
- UV lamp timer integration
- Art technique scoring

### Phase 6: Period 4 Implementation (Extension)
**Deliverables**:
- Extension technique mechanics
- Material selection interface
- Form application simulation

### Phase 7: Period 5 Implementation (Removal)
**Deliverables**:
- Removal progress tracking
- Damage detection system
- Final scoring compilation

### Phase 8: Polish & Enhancement
**Deliverables**:
- Tutorial system
- Practice mode refinement
- Performance optimization
- Comprehensive testing

## Data Models

### Exam Session Model
```dart
class ExamSession {
  String sessionId;
  DateTime startTime;
  int currentPeriod;
  Map<int, PeriodData> periodResults;
  double totalScore;
  bool isComplete;
}

class PeriodData {
  int periodNumber;
  String assignedTechnique;
  List<ActionLog> actions;
  Duration timeTaken;
  double score;
  Map<String, double> scoreBreakdown;
}
```

## Quality Assurance Requirements

### Gesture Accuracy
- Minimum 95% gesture recognition rate
- Response time < 100ms
- Smooth drag tracking at 60fps

### Scoring Consistency
- Automated test cases for each scoring component
- Variance tolerance < 5% for identical actions

### Performance Metrics
- App size < 50MB
- Memory usage < 200MB during exam
- Battery drain < 10% per hour

## User Experience Guidelines

### Visual Feedback
- Immediate visual response to all interactions
- Color-coded success/error indicators
- Progress bars for multi-step procedures

### Audio Cues (Optional)
- Timer warnings
- Successful completion sounds
- Error notification sounds

## Localization Preparation
Structure code to support future localization:
```dart
// Prepare for Korean/English
class AppStrings {
  static const examPeriod1 = 'exam_period_1';
  static const timerWarning = 'timer_warning';
}
```

## Success Criteria
1. Complete exam simulation in 2.5 hours
2. All 5 periods functional with random technique selection
3. Accurate scoring based on Korean exam standards
4. Smooth gesture interactions
5. Local progress saving/loading
6. Stable performance on mid-range devices (2GB RAM minimum)

---

*This document serves as the complete development specification. Each phase should be completed and tested before proceeding to the next. Code should be modular to allow easy addition of techniques and features post-MVP.*
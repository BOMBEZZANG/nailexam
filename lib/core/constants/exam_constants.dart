class ExamConstants {
  static const int totalPeriods = 5;
  static const Duration periodDuration = Duration(minutes: 30);
  static const Duration totalExamDuration = Duration(hours: 2, minutes: 30);
  
  static const Map<int, List<String>> periodTechniques = {
    1: ['full_color', 'french', 'deep_french', 'gradient'],
    2: ['full_color', 'french', 'deep_french', 'gradient'],
    3: ['fan_pattern', 'line_marble'],
    4: ['silk', 'tip_silk', 'acrylic', 'gel'],
    5: ['removal'],
  };
  
  static const Map<String, double> scoreWeights = {
    'sequence': 0.4,
    'timing': 0.2,
    'hygiene': 0.2,
    'technique': 0.2,
  };
  
  static const Map<int, String> periodNames = {
    1: 'Hand Polish Application',
    2: 'Foot Polish Application', 
    3: 'Gel Nail Art',
    4: 'Nail Extension',
    5: 'Extension Removal',
  };
  
  static const Map<String, String> techniqueDisplayNames = {
    'full_color': 'Full Color',
    'french': 'French',
    'deep_french': 'Deep French',
    'gradient': 'Gradient',
    'fan_pattern': 'Fan Pattern',
    'line_marble': 'Line Marble',
    'silk': 'Silk',
    'tip_silk': 'Tip with Silk',
    'acrylic': 'Acrylic',
    'gel': 'Gel',
    'removal': 'Removal',
  };
}
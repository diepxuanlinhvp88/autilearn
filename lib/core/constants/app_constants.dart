class AppConstants {
  // Quiz Types
  static const String choicesQuiz = 'choices_quiz';
  static const String pairingQuiz = 'pairing_quiz';
  static const String sequentialQuiz = 'sequential_quiz';
  static const String emotionsQuiz = 'emotions_quiz'; // Bài học nhận diện cảm xúc
  static const String drawingQuiz = 'drawing_quiz'; // Bài học vẽ
  static const String freeDrawing = 'free_drawing'; // Vẽ tự do
  static const String templateDrawing = 'template_drawing'; // Tô màu theo mẫu

  // User Roles
  static const String roleParent = 'parent';
  static const String roleTeacher = 'teacher';
  static const String roleStudent = 'student';

  // Quiz Difficulty Levels
  static const String difficultyEasy = 'easy';
  static const String difficultyMedium = 'medium';
  static const String difficultyHard = 'hard';

  // Storage Paths
  static const String pathQuizImages = 'quiz_images';
  static const String pathAudioFiles = 'audio_files';
  static const String pathUserAvatars = 'user_avatars';
  static const String pathDrawings = 'drawings';
  static const String pathDrawingTemplates = 'drawing_templates';
}

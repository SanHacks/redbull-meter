import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

/// Helper class for celebration animations and messages
class CelebrationHelper {
  /// Shows a celebration dialog with confetti
  static Future<void> showCelebrationDialog(
    BuildContext context, {
    required String title,
    required String message,
    IconData? icon,
    Color? color,
  }) async {
    final controller = ConfettiController(duration: const Duration(seconds: 3));
    controller.play();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              // Confetti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: controller,
                  blastDirection: 3.14 / 2, // Down
                  maxBlastForce: 5,
                  minBlastForce: 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 50,
                  gravity: 0.1,
                  colors: const [
                    Color(0xFFFF0000), // Red Bull red
                    Color(0xFFFFCC00), // Red Bull yellow
                    Colors.white,
                    Colors.orange,
                  ],
                ),
              ),
              // Content
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFF0000),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (color ?? const Color(0xFFFF0000))
                              .withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 48,
                          color: color ?? const Color(0xFFFF0000),
                        ),
                      ),
                    if (icon != null) const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[400],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        controller.stop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF0000),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Awesome!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a simple success snackbar
  static void showSuccessSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Shows achievement unlocked celebration
  static Future<void> showAchievementUnlocked(
    BuildContext context, {
    required String achievementName,
    required String description,
    IconData? icon,
  }) async {
    await showCelebrationDialog(
      context,
      title: 'Achievement Unlocked!',
      message: '$achievementName\n$description',
      icon: icon ?? Icons.emoji_events,
      color: const Color(0xFFFFCC00), // Red Bull yellow
    );
  }

  /// Shows streak milestone celebration
  static Future<void> showStreakMilestone(
    BuildContext context, {
    required int streakDays,
  }) async {
    await showCelebrationDialog(
      context,
      title: 'Streak Milestone!',
      message: '$streakDays Day Streak!\nKeep it going!',
      icon: Icons.local_fire_department,
      color: Colors.orange,
    );
  }

  /// Shows goal completed celebration
  static Future<void> showGoalCompleted(
    BuildContext context, {
    required String goalName,
  }) async {
    await showCelebrationDialog(
      context,
      title: 'Goal Completed!',
      message: 'You reached your $goalName goal!',
      icon: Icons.check_circle,
      color: Colors.green,
    );
  }

  /// Creates a confetti widget overlay
  static Widget createConfettiOverlay({
    required ConfettiController controller,
    Alignment alignment = Alignment.topCenter,
  }) {
    return Align(
      alignment: alignment,
      child: ConfettiWidget(
        confettiController: controller,
        blastDirection: 3.14 / 2, // Down
        maxBlastForce: 5,
        minBlastForce: 2,
        emissionFrequency: 0.05,
        numberOfParticles: 50,
        gravity: 0.1,
        colors: const [
          Color(0xFFFF0000), // Red Bull red
          Color(0xFFFFCC00), // Red Bull yellow
          Colors.white,
          Colors.orange,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/quiz_repository.dart';
import '../../../core/ui/server_image.dart';

class QuizDetailScreen extends ConsumerWidget {
  final String idOrSlug;

  const QuizDetailScreen({super.key, required this.idOrSlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizAsync = ref.watch(quizDetailProvider(idOrSlug));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: quizAsync.when(
          data: (quiz) {
            return Column(
              children: [
                // Main Content Area
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),

                          // Hero Image (Dynamic URL)
                          if (quiz.image.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(36),
                              child: Container(
                                width: 160,
                                height: 160,
                                color: Colors.grey[200],
                                child: ServerImage(
                                  imagePath: quiz.image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else
                            ClipRRect(
                              borderRadius: BorderRadius.circular(36),
                              child: Container(
                                width: 160,
                                height: 160,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 50,
                                ),
                              ),
                            ),
                          const SizedBox(height: 32),

                          // Title (Dynamic)
                          Text(
                            quiz.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Geist Mono',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: Color(0xFF131D2B),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Subtitle / Description (Dynamic)
                          Text(
                            quiz.description.isNotEmpty
                                ? quiz.description
                                : 'Test je kennis over dit onderwerp!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF7C7C80),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Stats Row (Dynamic values)
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatColumn(
                                  '${quiz.questions.isNotEmpty ? quiz.questions.length : quiz.questionCount}',
                                  'Vragen',
                                ),
                                const VerticalDivider(
                                  color: Color(0xFFE5E5EA),
                                  thickness: 1,
                                  width: 32,
                                ),
                                _buildStatColumn(
                                  '${quiz.xpReward}',
                                  'XP beloning',
                                ),
                                const VerticalDivider(
                                  color: Color(0xFFE5E5EA),
                                  thickness: 1,
                                  width: 32,
                                ),
                                _buildStatColumn(
                                  quiz.difficulty.toUpperCase(),
                                  'Niveau',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Action Button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF131D2B).withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        final pathId = quiz.slug.isNotEmpty
                            ? quiz.slug
                            : quiz.id;
                        context.push('/quiz/$pathId/play');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF131D2B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Start Quiz',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $err'),
                TextButton(
                  onPressed: () => ref.invalidate(quizDetailProvider(idOrSlug)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for the stat columns
  Widget _buildStatColumn(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF7C7C80)),
        ),
      ],
    );
  }
}

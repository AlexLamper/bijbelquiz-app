import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/server_image.dart';
import '../../quiz/data/quiz_repository.dart';
import '../../quiz/domain/quiz.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    // 1. Fetch categories
    final categoriesAsync = ref.watch(categoriesProvider);

    // 2. Fetch ALL quizzes once
    final allQuizzesAsync = ref.watch(
      quizzesProvider(const QuizQuery()), // Fetches all quizzes without category filter
    );

    // 3. Filter quizzes client-side
    final filteredQuizzes = allQuizzesAsync.maybeWhen(
      data: (quizzes) {
        if (_selectedCategory == 'all') return quizzes;
        return quizzes
            .where((quiz) => 
                quiz.categoryId == _selectedCategory || 
                quiz.category?.id == _selectedCategory ||
                quiz.category?.slug == _selectedCategory)
            .toList();
      },
      orElse: () => [],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const HeaderLogo(),
                    const SizedBox(width: 12),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.merriweather(
                          fontSize: 24,
                          color: Colors.black,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Bijbel',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'Quiz',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Icon(Icons.search, color: Color(0xFF8E8E93)),
                      const SizedBox(width: 12),
                      Text(
                        'Zoeken in quizzen of onderwerpen',
                        style: TextStyle(
                          color: const Color(0xFF8E8E93).withOpacity(0.8),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Filter Chips
              categoriesAsync.when(
                data: (categories) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        _buildFilterChip('Alles', 'all'),
                        ...categories.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: _buildFilterChip(category.name, category.id),
                          );
                        }),
                      ],
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: CircularProgressIndicator(),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('Fout bij laden categorieën: $err'),
                ),
              ),
              const SizedBox(height: 32),

              // Section 1
              _buildSectionHeader('Aanbevolen voor jou'),
              const SizedBox(height: 16),

              allQuizzesAsync.when(
                data: (quizzes) {
                  if (quizzes.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text("Geen quizzen gevonden."),
                    );
                  }
                  return SizedBox(
                    height: 210,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: quizzes.length,
                      itemBuilder: (context, index) {
                        final quiz = quizzes[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: QuizCardNew(
                            quiz: quiz,
                            isPremium: quiz.category?.name == 'Premium',
                            onTap: () => context.push(
                              '/quiz/${quiz.slug.isNotEmpty ? quiz.slug : quiz.id}',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('Fout: $err'),
                ),
              ),
              const SizedBox(height: 32),

              // Section 2
              _buildSectionHeader('Gefilterde quizzen'),
              const SizedBox(height: 16),

              allQuizzesAsync.when(
                data: (quizzes) {
                  final displayQuizzes = filteredQuizzes;
                  if (displayQuizzes.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text("Geen quizzen gevonden."),
                    );
                  }
                  return SizedBox(
                    height: 210,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: displayQuizzes.length,
                      itemBuilder: (context, index) {
                        final quiz = displayQuizzes[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: QuizCardNew(
                            quiz: quiz,
                            isPremium: quiz.category?.name == 'Premium',
                            onTap: () => context.push(
                              '/quiz/${quiz.slug.isNotEmpty ? quiz.slug : quiz.id}',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('Fout: $err'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String id) {
    final isActive = _selectedCategory == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1A2530) : const Color(0xFFF4F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF555555),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

class HeaderLogo extends StatelessWidget {
  const HeaderLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2530),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Image.asset(
          'assets/images/logo-dark.png',
          width: 24,
          height: 24,
        ),
      ),
    );
  }
}

class QuizCardNew extends StatelessWidget {
  final Quiz quiz;
  final bool isPremium;
  final VoidCallback onTap;

  const QuizCardNew({
    super.key,
    required this.quiz,
    required this.isPremium,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 120,
                  width: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // The actual image widget
                        ServerImage(
                          imagePath: quiz.image,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                ),
                if (isPremium)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4B15C),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 10),
                          SizedBox(width: 4),
                          Text(
                            'PREMIUM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              quiz.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                quiz.category?.name ?? 'Gemiddeld',
                style: const TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
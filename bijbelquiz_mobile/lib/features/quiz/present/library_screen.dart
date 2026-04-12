import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/ui/server_image.dart';
import '../data/quiz_repository.dart';
import '../domain/quiz.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  // Using slug/id for category matching, defaulting to 'all'
  String _selectedCategory = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _selectedCategory == 'all'
        ? const QuizQuery()
        : QuizQuery(categoryId: _selectedCategory);

    final quizzesAsync = ref.watch(quizzesProvider(query));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Page Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Quizzen',
                  style: TextStyle(
                    fontFamily: 'Courier', // Monospace font
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Color(0xFF131D2B),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Ontdek alle beschikbare Bijbelquizzen en test je\nkennis.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF666666),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Search Bar (Updated for perfect alignment & UX)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF4F4F6),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF8E8E93),
                      size: 22,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.cancel,
                              color: Color(0xFF8E8E93),
                              size: 20,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              FocusScope.of(context).unfocus(); // Dismiss keyboard
                            },
                          )
                        : null,
                    hintText: 'Zoeken in quizzen...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    // contentPadding handles the vertical centering effortlessly
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    _buildFilterChip('Alles', 'all'),
                    const SizedBox(width: 10),
                    _buildFilterChip('Oude Testament', 'oude-testament'),
                    const SizedBox(width: 10),
                    _buildFilterChip('Nieuwe Testament', 'nieuwe-testament'),
                    const SizedBox(width: 10),
                    _buildFilterChip('Algemeen', 'algemeen'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Premium Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9FB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.star, color: Color(0xFFFFA000), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Premium',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ontgrendel alle quizzen inclusief diepere theologie en uitgebreide uitleg!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF555555),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/premium');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF131D2B),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Probeer Premium',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Vertical List of Quiz Cards
              quizzesAsync.when(
                data: (quizzes) {
                  final filteredQuizzes = quizzes.where((q) {
                    return q.title.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filteredQuizzes.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        "Geen quizzen gevonden.",
                        style: TextStyle(color: Color(0xFF8E8E93)),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8.0,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredQuizzes.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final quiz = filteredQuizzes[index];
                      return LibraryQuizCard(
                        quiz: quiz,
                        onTap: () => context.push(
                          '/quiz/${quiz.slug.isNotEmpty ? quiz.slug : quiz.id}',
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Fout: $err')),
              ),
              const SizedBox(height: 24), // Bottom padding
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
          color: isActive ? const Color(0xFF131D2B) : const Color(0xFFF4F4F6),
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
}

class LibraryQuizCard extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback onTap;

  const LibraryQuizCard({super.key, required this.quiz, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final categoryName = quiz.category?.name ?? 'Algemeen';
    final difficulty = quiz.category?.name == 'Premium'
        ? 'Makkelijk'
        : 'Gemiddeld';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E5EA), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Row(
            children: [
              // Left Image
              Container(
                width: 110,
                height: double.infinity,
                color: const Color(0xFFF4F4F6), // Slightly softer grey
                child: quiz.image.isNotEmpty
                    ? SizedBox(
                        width: 110,
                        height: 110,
                        child: ServerImage(
                          imagePath: quiz.image,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(
                        // Updated to a cleaner, more modern icon
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: Color(0xFFD1D1D6),
                          size: 32,
                        ),
                      ),
              ),
              // Right Content Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        categoryName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          difficulty,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
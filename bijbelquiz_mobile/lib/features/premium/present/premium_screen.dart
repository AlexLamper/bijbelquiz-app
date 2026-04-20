import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Brand Colors derived from the screenshot
const Color _bgColor = Color(0xFF131A26);
const Color _goldColor = Color(0xFFCEAB71);
const Color _textColorMuted = Color(0xFF8B939C);
const Color _cardBg = Color(0xFF1A2230);
const Color _cardUnselectedBorder = Color(0xFF2A3441);

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  // Track which plan is selected ('lifetime' or 'monthly')
  String _selectedPlanId = 'lifetime';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      // Removed the standard AppBar to allow the image to flow to the top edge
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Image with Gradient Fade & Close Button
            Stack(
              children: [
                // Image Background
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1A3A52).withOpacity(0.8),
                        const Color(0xFF0F1F2E).withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
                // Gradient Overlay to seamlessly fade into the dark background
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        _bgColor.withOpacity(0.5),
                        _bgColor, // Solid background color at the bottom
                      ],
                      stops: const [0.5, 0.85, 1.0],
                    ),
                  ),
                ),
                // Floating Close Button (SafeArea ensures it doesn't hit the notch/status bar)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ],
            ),

            // Main Content Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Title & Subtitle
                  const Text(
                    'Word Premium Lid',
                    style: TextStyle(
                      fontFamily: 'Courier', // Monospace brand font
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ontvang volledige toegang tot de diepste lagen van de Schrift.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: _textColorMuted,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 3. Benefits List
                  _buildBenefitFeature("Onbeperkt aantal dagelijkse vragen"),
                  const SizedBox(height: 16),
                  _buildBenefitFeature("Exclusieve 'Statenvertaling' Verdieping"),
                  const SizedBox(height: 16),
                  _buildBenefitFeature("Ad-vrij leren & Offline modus"),
                  const SizedBox(height: 36),

                  // 4. Interactive Pricing Cards
                  _buildPricingCard(
                    id: 'lifetime',
                    title: 'Lifetime toegang',
                    subtitleLeft: 'ÉÉNMALIG',
                    price: '€74,99',
                    subtitleRight: 'Voor altijd premium',
                  ),
                  const SizedBox(height: 16),
                  _buildPricingCard(
                    id: 'monthly',
                    title: 'Maandelijks',
                    subtitleLeft: '',
                    price: '€5,99',
                    subtitleRight: ' / mnd',
                  ),
                  const SizedBox(height: 32),

                  // 5. Primary Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement checkout/subscription logic
                        debugPrint('Activating plan: $_selectedPlanId');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _goldColor,
                        foregroundColor: _bgColor, // Dark text on gold button
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Activeer Premium',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 6. Footer Legal & Restore Links
                  Center(
                    child: Text(
                      'Na de proefperiode wordt het bedrag in rekening gebracht.\nAnnuleer op elk gewenst moment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: _textColorMuted.withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement restore purchases
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Aankopen Herstellen',
                        style: TextStyle(
                          fontSize: 13,
                          color: _textColorMuted,
                          decoration: TextDecoration.underline,
                          decorationColor: _textColorMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for the benefit rows
  Widget _buildBenefitFeature(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline, color: _goldColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget for the selectable pricing cards
  Widget _buildPricingCard({
    required String id,
    required String title,
    required String subtitleLeft,
    required String price,
    required String subtitleRight,
  }) {
    final isSelected = _selectedPlanId == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanId = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _goldColor : _cardUnselectedBorder,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Side (Title & Subtitle)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (subtitleLeft.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitleLeft,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: _textColorMuted,
                    ),
                  ),
                ]
              ],
            ),
            // Right Side (Price & Meta)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: price,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (!isSelected && subtitleRight.isNotEmpty)
                        TextSpan(
                          text: subtitleRight,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _textColorMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isSelected && subtitleRight.isNotEmpty && id == 'lifetime') ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitleRight,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _goldColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}
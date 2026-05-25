import 'package:flutter/material.dart';
import 'dart:math' as math;

class CarDisplay extends StatefulWidget {
  const CarDisplay({super.key});

  @override
  State<CarDisplay> createState() => _CarDisplayState();
}

class _CarDisplayState extends State<CarDisplay> {
  final PageController _pageController = PageController();
  static const int _carCount = 5;
  bool _isImagesCached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isImagesCached) {
      for (int i = 1; i <= _carCount; i++) {
        precacheImage(AssetImage('assets/images/png/car$i.png'), context);
      }
      _isImagesCached = true;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withAlpha(120),
            const Color.fromARGB(255, 45, 47, 48),
            const Color.fromARGB(255, 45, 47, 48),
            colorScheme.primary.withAlpha(120),
          ],
          stops: const [0.0, 0.10, 0.90, 1.0],
          transform: const GradientRotation(math.pi / 5),
        ),
      ),
      padding: const EdgeInsets.all(1),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.5),
          color: const Color(0xFF121212),
        ),
        child: Column(
          children: [
            Expanded(
              child: _CarCarousel(
                controller: _pageController,
                count: _carCount,
              ),
            ),

            _CarIndicators(
              controller: _pageController,
              count: _carCount,
              primaryColor: colorScheme.primary,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _CarCarousel extends StatelessWidget {
  final PageController controller;
  final int count;

  const _CarCarousel({required this.controller, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: PageView.builder(
        controller: controller,
        itemCount: count,
        itemBuilder: (context, index) {
          return Image.asset(
            'assets/images/png/car${index + 1}.png',
            fit: BoxFit.contain,
             errorBuilder: (context, error, stackTrace) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  Icon(Icons.car_crash_outlined , color: Colors.redAccent,),
                  SizedBox(width: 10,),
                  Text("Error while loading Image." ,
                    style: TextStyle(
                       fontFamily: 'Inter',
                    ),
                  )
                ],
              ); // fallback widget
            },
          );
        },
      ),
    );
  }
}

class _CarIndicators extends StatelessWidget {
  final PageController controller;
  final int count;
  final Color primaryColor;

  const _CarIndicators({
    required this.controller,
    required this.count,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        double pageOffset = 0.0;
        if (controller.hasClients && controller.position.haveDimensions) {
          pageOffset = controller.page ?? 0.0;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,

          /// page offset это положение page view в данный момент, начальная
          /// точка 0.0, при передвижении на 1 объект page contoller становится 1
          children: List.generate(count, (index) {
            final distance = (pageOffset - index).abs();
            final factor = (1 - distance).clamp(0.0, 1.0);
            final width = 8.0 + (8.0 * factor);

            final color = Color.lerp(
              Colors.white.withValues(alpha: 0.2),
              primaryColor,
              factor,
            );

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3.0),
              width: width,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }
}

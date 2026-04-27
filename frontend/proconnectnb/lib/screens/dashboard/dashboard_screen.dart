import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';

import '/provider/medication_provider.dart';
import '/provider/activity_provider.dart';
import '/provider/caregiver_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _breathingController;
  late PageController _carouselController;
  Timer? _carouselTimer;
  int _currentCarouselIndex = 0;

  final String _userName = "Test";

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _carouselController = PageController(viewportFraction: 1.0);
    _startCarouselTimer();
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_carouselController.hasClients) {
        int nextIndex = (_currentCarouselIndex + 1) % 3;
        _carouselController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _carouselController.dispose();
    _entranceController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    final medProvider = context.watch<MedicationProvider>();
    final remainingMeds = medProvider.medications
        .where((m) => !m.isTaken)
        .length;
    final adherenceScore = medProvider.medications.isEmpty
        ? 0
        : (medProvider.adherenceRate * 100).toInt();

    final actProvider = context.watch<ActivityProvider>();
    String activitySubtitle = "Chargement...";
    if (!actProvider.isLoading) {
      final int progress = (actProvider.todayActivity.progressRatio * 100)
          .toInt();
      activitySubtitle = "Objectif $progress%";
    }

    final cgProvider = context.watch<CaregiverProvider>();
    final int cgCount = cgProvider.caregivers.length;
    final String caregiverSubtitle = cgCount == 0
        ? "Aucun actif"
        : "$cgCount actif(s)";

    final List<Map<String, dynamic>> bannerData = [
      {
        "title": "Score de suivi",
        "value": "$adherenceScore%",
        "subtitle": adherenceScore == 100
            ? "Parfait ! Tout est pris."
            : "N'oubliez pas vos traitements.",
        "icon": Icons.health_and_safety_rounded,
        "color": const Color(0xFF0052D4),
      },
      {
        "title": "Prochain Rendez-vous",
        "value": "Demain",
        "subtitle": "Dr. Tremblay - Cardiologie à 14:00.",
        "icon": Icons.calendar_month_rounded,
        "color": const Color(0xFF11998E),
      },
      {
        "title": "Conseil du jour",
        "value": "Hydratation",
        "subtitle": "N'oubliez pas de boire 1.5L d'eau aujourd'hui.",
        "icon": Icons.water_drop_rounded,
        "color": const Color(0xFF8E2DE2),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: Stack(
        children: [
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0052D4).withOpacity(0.2),
                    const Color(0xFF0052D4).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                    child: _buildHeader(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: _buildInteractiveCarousel(bannerData),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Services Rapides",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TactileActionCard(
                                title: "Médicaments",
                                subtitle: remainingMeds == 0
                                    ? "Tout est pris"
                                    : "$remainingMeds restant(s)",
                                icon: Icons.vaccines_rounded,
                                gradient: const [
                                  Color(0xFF0052D4),
                                  Color(0xFF4364F7),
                                ],
                                route: '/medications',
                                entranceController: _entranceController,
                                breathingController: _breathingController,
                                delay: 0.2,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TactileActionCard(
                                title: "Activités",
                                subtitle: activitySubtitle,
                                icon: Icons.directions_run_rounded,
                                gradient: const [
                                  Color(0xFF11998E),
                                  Color(0xFF38EF7D),
                                ],
                                route: '/activities',
                                entranceController: _entranceController,
                                breathingController: _breathingController,
                                delay: 0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TactileActionCard(
                                title: "Proche Aidant",
                                subtitle: caregiverSubtitle,
                                icon: Icons.diversity_1_rounded,
                                gradient: const [
                                  Color(0xFFF2994A),
                                  Color(0xFFF2C94C),
                                ],
                                route: '/caregivers',
                                entranceController: _entranceController,
                                breathingController: _breathingController,
                                delay: 0.4,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TactileActionCard(
                                title: "Dossier Médical",
                                subtitle: "Documents",
                                icon: Icons.folder_shared_rounded,
                                gradient: const [
                                  Color(0xFFE94057),
                                  Color(0xFFF27121),
                                ],
                                route: '/documents',
                                entranceController: _entranceController,
                                breathingController: _breathingController,
                                delay: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0.0, 0.4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: -1.0,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildTopIconButton(Icons.tune_rounded, () {
                Navigator.pushNamed(context, '/settings');
              }),
              const SizedBox(width: 12),

              _buildTopIconButton(Icons.notifications_none_rounded, () {
                Navigator.pushNamed(context, '/notifications');
              }),
              const SizedBox(width: 12),
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0052D4).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('images/profile_placeholder.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Icon(Icons.person, color: Colors.transparent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF0F172A), size: 22),
      ),
    );
  }

  Widget _buildInteractiveCarousel(List<Map<String, dynamic>> bannerData) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0.1, 0.6, curve: Curves.easeOutBack),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.1, 0.6),
          ),
        ),
        child: SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _carouselController,
            onPageChanged: (index) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
            itemCount: bannerData.length,
            itemBuilder: (context, index) {
              final data = bannerData[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: data["color"].withOpacity(0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(
                            data["icon"],
                            size: 140,
                            color: data["color"].withOpacity(0.04),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(28),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: data["color"].withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  data["icon"],
                                  color: data["color"],
                                  size: 36,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      data["title"],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      data["value"],
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0F172A),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      data["subtitle"],
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF475569),
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
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
            },
          ),
        ),
      ),
    );
  }
}

class TactileActionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final String route;
  final AnimationController entranceController;
  final AnimationController breathingController;
  final double delay;

  const TactileActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.route,
    required this.entranceController,
    required this.breathingController,
    required this.delay,
  });

  @override
  State<TactileActionCard> createState() => _TactileActionCardState();
}

class _TactileActionCardState extends State<TactileActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _tapController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _tapController.reverse().then((_) {
      try {
        Navigator.pushNamed(context, widget.route);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Module en cours d'intégration")),
        );
      }
    });
  }

  void _onTapCancel() {
    _tapController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: widget.entranceController,
              curve: Interval(
                widget.delay,
                widget.delay + 0.4,
                curve: Curves.easeOutExpo,
              ),
            ),
          ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: widget.entranceController,
            curve: Interval(widget.delay, widget.delay + 0.4),
          ),
        ),
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _scaleAnimation,
              widget.breathingController,
            ]),
            builder: (context, child) {
              final breathingValue = widget.breathingController.value;
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: widget.gradient.first.withOpacity(
                        0.1 + (breathingValue * 0.15),
                      ),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.gradient.last.withOpacity(
                          0.08 + (breathingValue * 0.08),
                        ),
                        blurRadius: 20 + (breathingValue * 5),
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: widget.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: widget.gradient.first.withOpacity(
                                0.3 + (breathingValue * 0.2),
                              ),
                              blurRadius: 10 + (breathingValue * 4),
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(widget.icon, color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

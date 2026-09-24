import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/cooking_icons.dart';

class CookingModeScreen extends StatefulWidget {
  final Recipe recipe;

  const CookingModeScreen({super.key, required this.recipe});

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  late final PageController _pageController;
  int _currentStepIndex = 0;

  // Step timer state
  Timer? _activeTimer;
  int _remainingSeconds = 0;
  bool _isTimerRunning = false;
  int _totalStepSeconds = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initTimerForStep(0);
  }

  @override
  void dispose() {
    _activeTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _initTimerForStep(int stepIndex) {
    _activeTimer?.cancel();
    _isTimerRunning = false;

    if (stepIndex < widget.recipe.steps.length) {
      final step = widget.recipe.steps[stepIndex];
      _totalStepSeconds = step.timerSeconds;
      _remainingSeconds = step.timerSeconds;
    } else {
      _totalStepSeconds = 0;
      _remainingSeconds = 0;
    }
  }

  void _startTimer() {
    if (_remainingSeconds <= 0) return;

    setState(() => _isTimerRunning = true);

    _activeTimer?.cancel();
    _activeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isTimerRunning = false;
        });

        // Show snackbar alert when timer ends
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.alarm_on_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Süre doldu! Bir sonraki adıma geçebilirsiniz.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  void _pauseTimer() {
    _activeTimer?.cancel();
    setState(() => _isTimerRunning = false);
  }

  void _resetTimer() {
    _activeTimer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _remainingSeconds = _totalStepSeconds;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentStepIndex = index;
    });
    _initTimerForStep(index);
  }

  void _goToPreviousStep() {
    if (_currentStepIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextStep() {
    if (_currentStepIndex < widget.recipe.steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  color: Color(0xFF10B981),
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tebrikler! 🎉',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.recipe.title} tarifini ustalıkla tamamladınız. Ellerinize sağlık ve afiyet olsun!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    Navigator.of(context).pop(); // exit cooking mode
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5722),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Tariflere Geri Dön', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatSeconds(int totalSecs) {
    final minutes = totalSecs ~/ 60;
    final seconds = totalSecs % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.recipe.steps;
    final totalSteps = steps.length;
    final progress = totalSteps > 0 ? (_currentStepIndex + 1) / totalSteps : 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // In-kitchen dark mode for maximum contrast
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.recipe.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Adım ${_currentStepIndex + 1} / $totalSteps',
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF334155),
            color: const Color(0xFFFF5722),
            minHeight: 4,
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: totalSteps,
        itemBuilder: (context, index) {
          final step = steps[index];
          final toolIcon = CookingIcons.getToolIcon(step.toolIcon);
          final toolLabel = CookingIcons.getToolLabel(step.toolIcon);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Badge & Tool Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5722),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ADIM ${step.order}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Row(
                        children: [
                          Icon(toolIcon, size: 16, color: const Color(0xFF38BDF8)),
                          const SizedBox(width: 6),
                          Text(
                            toolLabel,
                            style: const TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Step Title
                Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 16),

                // Step Instruction (Large, high-contrast text for in-kitchen cooking)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Text(
                    step.instruction,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFFF1F5F9),
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Timer Widget (if step has timer)
                if (step.timerSeconds > 0)
                  _buildTimerSection()
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(
                      children: const [
                        Icon(CookingIcons.clock, size: 16, color: Color(0xFF94A3B8)),
                        SizedBox(width: 8),
                        Text(
                          'Bu adım serbest hazırlıktır, zamanlayıcı gerekmez.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Expandable Pro-Tip Box (Acemi Püf Noktası)
                if (step.proTip.isNotEmpty)
                  _buildProTipCard(step.proTip),
              ],
            ),
          );
        },
      ),

      // Navigation Bar at Bottom
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          border: Border(top: BorderSide(color: Color(0xFF334155))),
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (_currentStepIndex > 0)
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: _goToPreviousStep,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Önceki'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF475569)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              if (_currentStepIndex > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _goToNextStep,
                  icon: Icon(
                    _currentStepIndex == totalSteps - 1
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_rounded,
                    size: 20,
                  ),
                  label: Text(
                    _currentStepIndex == totalSteps - 1
                        ? 'Pişirmeyi Tamamla 🎉'
                        : 'Sonraki Adım',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentStepIndex == totalSteps - 1
                        ? const Color(0xFF10B981)
                        : const Color(0xFFFF5722),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerSection() {
    final timerFraction = _totalStepSeconds > 0
        ? _remainingSeconds / _totalStepSeconds
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isTimerRunning ? const Color(0xFFFF5722) : const Color(0xFF334155),
          width: _isTimerRunning ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _isTimerRunning ? CookingIcons.timerActive : CookingIcons.timer,
                    color: _isTimerRunning ? const Color(0xFFFF5722) : const Color(0xFF94A3B8),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Adım Süresi',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                _formatSeconds(_remainingSeconds),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: _remainingSeconds == 0
                      ? const Color(0xFF10B981)
                      : (_isTimerRunning ? const Color(0xFFFF5722) : Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: timerFraction,
              minHeight: 6,
              backgroundColor: const Color(0xFF334155),
              color: _isTimerRunning ? const Color(0xFFFF5722) : const Color(0xFF38BDF8),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isTimerRunning && _remainingSeconds > 0)
                ElevatedButton.icon(
                  onPressed: _startTimer,
                  icon: const Icon(CookingIcons.play, size: 18),
                  label: const Text('Sayacı Başlat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5722),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              if (_isTimerRunning)
                ElevatedButton.icon(
                  onPressed: _pauseTimer,
                  icon: const Icon(CookingIcons.pause, size: 18),
                  label: const Text('Duraklat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _resetTimer,
                icon: const Icon(CookingIcons.replay, size: 16),
                label: const Text('Sıfırla'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF94A3B8),
                  side: const BorderSide(color: Color(0xFF475569)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProTipCard(String proTip) {
    return Material(
      color: const Color(0xFF292524),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            iconColor: const Color(0xFFF59E0B),
            collapsedIconColor: const Color(0xFFF59E0B),
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                CookingIcons.proTip,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
            ),
            title: const Text(
              'Acemi Püf Noktası 💡',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFEF3C7),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  proTip,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFFDE68A),
                    height: 1.5,
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

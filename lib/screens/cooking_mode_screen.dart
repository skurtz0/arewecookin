import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../utils/cooking_icons.dart';
import '../widgets/cooking_technique_animation.dart';
import '../providers/locale_provider.dart';

class CookingModeScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const CookingModeScreen({super.key, required this.recipe});

  @override
  ConsumerState<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends ConsumerState<CookingModeScreen> {
  late final PageController _pageController;
  int _currentStepIndex = 0;

  // Step timer state
  Timer? _activeTimer;
  int _remainingSeconds = 0;
  bool _isTimerRunning = false;
  int _totalStepSeconds = 0;

  // Ingredients checklist state
  final Set<int> _checkedIngredients = {};

  void _showAllIngredientsSheet(BuildContext context) {
    final strings = ref.read(appStringsProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF475569),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(CookingIcons.pantry, color: Color(0xFFFF5722), size: 20),
                        const SizedBox(width: 10),
                        Text(
                          strings.ingredientsTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_checkedIngredients.length}/${widget.recipe.ingredients.length} ${strings.locale.toLowerCase().startsWith('tr') ? 'Hazır' : 'Ready'}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: widget.recipe.ingredients.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final ing = widget.recipe.ingredients[index];
                          final isChecked = _checkedIngredients.contains(index);

                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setSheetState(() {
                                if (isChecked) {
                                  _checkedIngredients.remove(index);
                                } else {
                                  _checkedIngredients.add(index);
                                }
                              });
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isChecked
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF334155).withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isChecked ? const Color(0xFF10B981) : const Color(0xFF475569),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isChecked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                    color: isChecked ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      ing.localizedDisplayText(strings.locale),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: isChecked ? const Color(0xFF94A3B8) : Colors.white,
                                        decoration: isChecked ? TextDecoration.lineThrough : null,
                                        fontWeight: isChecked ? FontWeight.normal : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

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
    final strings = ref.watch(appStringsProvider);
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
              widget.recipe.localizedTitle(strings.locale),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${strings.step} ${_currentStepIndex + 1} / $totalSteps',
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _showAllIngredientsSheet(context),
            icon: const Icon(CookingIcons.pantry, size: 15, color: Color(0xFFFF5722)),
            label: Text(
              strings.ingredientsCountFormat(widget.recipe.ingredients.length),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF5722)),
            ),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFFF5722).withValues(alpha: 0.12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
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
          final toolLabel = CookingIcons.getToolLabel(step.toolIcon, strings.locale);

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
                        '${strings.step.toUpperCase()} ${step.order}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(toolIcon, size: 16, color: const Color(0xFF38BDF8)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                toolLabel,
                                style: const TextStyle(
                                  color: Color(0xFFCBD5E1),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Step Title
                Text(
                  step.localizedTitle(strings.locale),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),

                // Step Ingredients (if available for this step)
                if (step.stepIngredients.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.35)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.shopping_basket_rounded, size: 16, color: Color(0xFF38BDF8)),
                            SizedBox(width: 8),
                            Text(
                              'Bu Adımda Kullanılacak Malzemeler:',
                              style: TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: step.stepIngredients.map((item) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF334155)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF10B981)),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        color: Color(0xFFF1F5F9),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],

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
                    step.localizedInstruction(strings.locale),
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

                // Expandable Pro-Tip Box (Acemi Püf Noktası & Vektörel Animasyon)
                if (step.proTip.isNotEmpty)
                  _buildProTipCard(step),
              ],
            ),
          );
        },
      ),

      // Navigation Bar at Bottom (Overflow-safe)
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
                  child: OutlinedButton(
                    onPressed: _goToPreviousStep,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF475569)),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_back_rounded, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            strings.cancel == 'İptal' ? 'Önceki' : 'Back',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_currentStepIndex > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _goToNextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentStepIndex == totalSteps - 1
                        ? const Color(0xFF10B981)
                        : const Color(0xFFFF5722),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentStepIndex == totalSteps - 1
                              ? '${strings.finishCooking} 🎉'
                              : (strings.cancel == 'İptal' ? 'Sonraki Adım' : 'Next Step'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          _currentStepIndex == totalSteps - 1
                              ? Icons.check_circle_rounded
                              : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
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
    final strings = ref.watch(appStringsProvider);
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
                  Text(
                    strings.locale.toLowerCase().startsWith('tr') ? 'Adım Süresi' : 'Step Timer',
                    style: const TextStyle(
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
                Flexible(
                  child: ElevatedButton(
                    onPressed: _startTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5722),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(CookingIcons.play, size: 18),
                          const SizedBox(width: 6),
                          Text(strings.startTimer),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_isTimerRunning)
                Flexible(
                  child: ElevatedButton(
                    onPressed: _pauseTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(CookingIcons.pause, size: 18),
                          const SizedBox(width: 6),
                          Text(strings.pauseTimer),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 10),
              Flexible(
                child: OutlinedButton(
                  onPressed: _resetTimer,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF94A3B8),
                    side: const BorderSide(color: Color(0xFF475569)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CookingIcons.replay, size: 16),
                        const SizedBox(width: 6),
                        Text(strings.resetTimer),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProTipCard(CookingStep step) {
    final strings = ref.watch(appStringsProvider);
    return Material(
      color: const Color(0xFF1E293B),
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
            title: Text(
              '${strings.proTip} 💡',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFEF3C7),
              ),
            ),
            children: [
              // Vector Animation showing technique
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: CookingTechniqueAnimation(
                  technique: CookingTechniqueType.detect(
                    toolIcon: step.toolIcon,
                    proTip: step.proTip,
                  ),
                  height: 160,
                  isDarkMode: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.tips_and_updates_rounded, color: Color(0xFFF59E0B), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          step.localizedProTip(ref.read(appStringsProvider).locale),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFFDE68A),
                            height: 1.45,
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

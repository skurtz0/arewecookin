import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../utils/cooking_icons.dart';
import '../widgets/cooking_technique_animation.dart';
import '../providers/locale_provider.dart';
import '../providers/household_servings_provider.dart';
import '../providers/recipe_progress_provider.dart';
import '../providers/cook_history_provider.dart';
import '../providers/unit_system_provider.dart';
import '../providers/cook_text_size_provider.dart';
import '../providers/timer_sound_provider.dart';
import '../providers/recipe_notes_provider.dart';
import '../utils/unit_converter.dart';
import '../l10n/recipe_localization.dart';

class CookingModeScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const CookingModeScreen({super.key, required this.recipe});

  @override
  ConsumerState<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends ConsumerState<CookingModeScreen> {
  late final PageController _pageController;
  int _currentStepIndex = 0;
  bool _resumed = false;

  // Step timers: every step keeps its own countdown, so a timer keeps running
  // (e.g. while the dish simmers) when the user moves to the next step.
  Timer? _ticker;
  final Map<int, int> _remaining = {};
  final Set<int> _runningSteps = {};
  final Map<int, int> _extraSeconds =
      {}; // minutes added with "+1 min", per step

  int get _totalStepSeconds => _currentStepIndex < widget.recipe.steps.length
      ? widget.recipe.steps[_currentStepIndex].timerSeconds +
            (_extraSeconds[_currentStepIndex] ?? 0)
      : 0;
  int get _remainingSeconds =>
      _remaining[_currentStepIndex] ?? _totalStepSeconds;
  bool get _isTimerRunning => _runningSteps.contains(_currentStepIndex);

  // Ingredients checklist state
  final Set<int> _checkedIngredients = {};
  bool _checkedTouched = false;

  /// Ingredient line scaled to the servings chosen on the detail screen, in the chosen unit system.
  String _ingredientText(Ingredient ing, String locale) {
    final chosen = ref.read(recipeProgressProvider)[widget.recipe.id]?.servings ??
        ref.read(householdServingsProvider);
    final base = widget.recipe.servings;
    final original = AmountFormat.parse(ing.amount);
    final imperial = ref.read(imperialUnitsProvider);
    if (original == null ||
        (chosen == null || base <= 0 || chosen == base) && !imperial) {
      return ing.localizedDisplayText(locale);
    }
    final scaled = (chosen == null || base <= 0)
        ? original
        : original * chosen / base;
    var amount = AmountFormat.fraction(scaled);
    var unit = ing.localizedUnit(locale);
    if (imperial) {
      final conv = UnitConverter.toImperial(
        scaled,
        ing.unit.trim().isEmpty ? unit : ing.unit,
      );
      if (conv != null) {
        amount = UnitConverter.format(conv.amount);
        unit = conv.unit;
      }
    }
    return [
      amount,
      unit,
      ing.localizedName(locale),
    ].where((e) => e.isNotEmpty).join(' ');
  }

  /// Minutes of step timers from the current step to the end (rounded up); 0 when none.
  int _timerMinutesLeft() {
    var seconds = 0;
    for (var i = _currentStepIndex; i < widget.recipe.steps.length; i++) {
      seconds += widget.recipe.steps[i].timerSeconds;
    }
    return (seconds / 60).ceil();
  }

  /// Servings the ingredient amounts are scaled to: the number chosen for this recipe, else the
  /// default servings preference, else the recipe's own.
  int _shownServings() =>
      ref.read(recipeProgressProvider)[widget.recipe.id]?.servings ??
      ref.read(householdServingsProvider) ??
      (widget.recipe.servings > 0 ? widget.recipe.servings : 4);

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
                        const Icon(
                          CookingIcons.pantry,
                          color: Color(0xFFFF5722),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            // The servings the amounts below are scaled to.
                            '${strings.ingredientsTitle} · ${strings.servingsFormat(_shownServings())}',
                            key: const Key('cook_ingredients_title'),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_checkedIngredients.length}/${widget.recipe.ingredients.length} ${strings.ready.isNotEmpty ? strings.ready[0].toUpperCase() + strings.ready.substring(1) : ''}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // The user's own note for this recipe (tweaks, tips) is handy while cooking.
                    Builder(builder: (_) {
                      final note = (ref.read(recipeNotesProvider)[widget.recipe.id]?.note ?? '').trim();
                      if (note.isEmpty) return const SizedBox.shrink();
                      return Container(
                        key: const Key('cook_note'),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.sticky_note_2_outlined, size: 18, color: Color(0xFFFBBF24)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                note,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: widget.recipe.ingredients.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final ing = widget.recipe.ingredients[index];
                          final isChecked = _checkedIngredients.contains(index);

                          return Semantics(
                            key: Key('cook_ingredient_$index'),
                            checked: isChecked,
                            container: true,
                            child: InkWell(
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
                                _checkedTouched = true;
                                ref
                                    .read(recipeProgressProvider.notifier)
                                    .setChecked(
                                      widget.recipe.id,
                                      _checkedIngredients,
                                    );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isChecked
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF334155)
                                            .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isChecked
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF475569),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isChecked
                                          ? Icons.check_circle_rounded
                                          : Icons
                                                .radio_button_unchecked_rounded,
                                      color: isChecked
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF94A3B8),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _ingredientText(ing, strings.locale),
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: isChecked
                                              ? const Color(0xFF94A3B8)
                                              : Colors.white,
                                          decoration: isChecked
                                              ? TextDecoration.lineThrough
                                              : null,
                                          fontWeight: isChecked
                                              ? FontWeight.normal
                                              : FontWeight.w600,
                                        ),
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
    // Resume where the user stopped last time (stored step arrives asynchronously).
    ref.listenManual(recipeProgressProvider, (prev, next) {
      // Ingredient ticks are shared with the recipe detail screen.
      final savedChecked = next[widget.recipe.id]?.checked;
      if (!_checkedTouched &&
          savedChecked != null &&
          savedChecked.isNotEmpty &&
          mounted) {
        setState(() => _checkedIngredients.addAll(savedChecked));
      }
      final saved = next[widget.recipe.id]?.step ?? 0;
      if (!_resumed &&
          saved > 0 &&
          saved < widget.recipe.steps.length &&
          _currentStepIndex == 0) {
        _resumed = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _pageController.hasClients) {
            _pageController.jumpToPage(saved);
          }
        });
      }
    }, fireImmediately: true);
    _setKeepAwake(true);
    _initTimerForStep(0);
  }

  /// Keeps the screen on while cooking. Failures (unsupported platform, tests) are ignored.
  void _setKeepAwake(bool on) {
    try {
      (on ? WakelockPlus.enable() : WakelockPlus.disable()).catchError((_) {});
    } catch (_) {}
  }

  @override
  void dispose() {
    _setKeepAwake(false);
    _ticker?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _initTimerForStep(int stepIndex) {
    if (stepIndex < widget.recipe.steps.length) {
      _remaining.putIfAbsent(
        stepIndex,
        () => widget.recipe.steps[stepIndex].timerSeconds,
      );
    }
  }

  void _ensureTicker() {
    if (_ticker?.isActive ?? false) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final finished = <int>[];
      setState(() {
        for (final step in _runningSteps.toList()) {
          final left = (_remaining[step] ?? 0) - 1;
          if (left <= 0) {
            _remaining[step] = 0;
            _runningSteps.remove(step);
            finished.add(step);
          } else {
            _remaining[step] = left;
          }
        }
      });
      for (final step in finished) {
        _alertTimerDone(step);
      }
      if (_runningSteps.isEmpty) timer.cancel();
    });
  }

  void _alertTimerDone(int step) {
    try {
      HapticFeedback.heavyImpact();
      if (ref.read(timerSoundProvider)) SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
    final strings = ref.read(appStringsProvider);
    // Spoken for screen-reader users even if the snackbar is not looked at.
    SemanticsService.sendAnnouncement(
      View.of(context),
      strings.timerDoneFor(step + 1),
      Directionality.of(context),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.alarm_on_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                strings.timerDoneFor(step + 1),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  void _startTimer() {
    if (_remainingSeconds <= 0) return;
    setState(() => _runningSteps.add(_currentStepIndex));
    _ensureTicker();
  }

  void _pauseTimer() {
    setState(() => _runningSteps.remove(_currentStepIndex));
  }

  /// Adds one minute to the current step's timer (works while it runs or is finished).
  void _addMinute() {
    final i = _currentStepIndex;
    setState(() {
      _extraSeconds[i] = (_extraSeconds[i] ?? 0) + 60;
      _remaining[i] = (_remaining[i] ?? 0) + 60;
    });
  }

  void _resetTimer() {
    setState(() {
      _runningSteps.remove(_currentStepIndex);
      _extraSeconds.remove(_currentStepIndex);
      _remaining[_currentStepIndex] = _totalStepSeconds;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentStepIndex = index;
    });
    _resumed = true;
    ref.read(recipeProgressProvider.notifier).setStep(widget.recipe.id, index);
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
    final strings = ref.read(appStringsProvider);
    // Finished: next time the recipe starts from step 1 again.
    ref.read(recipeProgressProvider.notifier).setStep(widget.recipe.id, 0);
    // Ingredient ticks belong to this cook: the next time starts with a clean checklist.
    _checkedIngredients.clear();
    _checkedTouched = true;
    ref.read(recipeProgressProvider.notifier).setChecked(widget.recipe.id, <int>{});
    ref.read(cookHistoryProvider.notifier).markCooked(widget.recipe.id);
    final noteController = TextEditingController(
      text: ref.read(recipeNotesProvider)[widget.recipe.id]?.note ?? '',
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          scrollable: true,
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
              Text(
                strings.doneTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.doneBody(widget.recipe.localizedTitle(strings.locale)),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                strings.doneRate,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              Consumer(
                builder: (context, ref, _) {
                  final rating = ref.watch(
                    recipeNotesProvider.select(
                      (m) => m[widget.recipe.id]?.rating ?? 0,
                    ),
                  );
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var n = 1; n <= 5; n++)
                          IconButton(
                            key: Key('done_rate_$n'),
                            tooltip: strings.rateStarFor(n),
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              n <= rating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: const Color(0xFFF59E0B),
                            ),
                            onPressed: () => ref
                                .read(recipeNotesProvider.notifier)
                                .setRating(widget.recipe.id, n),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              // A quick note while the dish is fresh in mind (shown again on the recipe page).
              TextField(
                key: const Key('done_note'),
                controller: noteController,
                minLines: 1,
                maxLines: 3,
                onChanged: (v) => ref.read(recipeNotesProvider.notifier).setNote(widget.recipe.id, v),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: strings.myNotesHint,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
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
                  child: Text(
                    strings.doneBack,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
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
    final progress = totalSteps > 0
        ? (_currentStepIndex + 1) / totalSteps
        : 1.0;

    // Large system text is respected up to 1.4x here: the step cards use dense multi-chip rows.
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(textScaler: mq.textScaler.clamp(maxScaleFactor: 1.4)),
      child: _buildScaffold(context, strings, steps, totalSteps, progress),
    );
  }

  void _showStepsSheet(BuildContext context, AppStrings strings, List<CookingStep> steps) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: steps.length,
          itemBuilder: (_, i) => ListTile(
            key: Key('step_overview_$i'),
            selected: i == _currentStepIndex,
            leading: CircleAvatar(radius: 14, child: Text('${i + 1}')),
            title: Text(
              steps[i].localizedTitle(strings.locale),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: steps[i].timerSeconds >= 60
                ? Text(strings.minutesShort((steps[i].timerSeconds / 60).ceil()))
                : null,
            trailing: steps[i].timerSeconds >= 60 ? const Icon(Icons.timer_outlined, size: 18) : null,
            onTap: () {
              Navigator.of(ctx).pop();
              _pageController.jumpToPage(i);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    AppStrings strings,
    List<CookingStep> steps,
    int totalSteps,
    double progress,
  ) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF0F172A,
      ), // In-kitchen dark mode for maximum contrast
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.recipe.localizedTitle(strings.locale),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Tooltip(
              message: strings.allSteps,
              child: InkWell(
                key: const Key('step_overview_open'),
                onTap: () => _showStepsSheet(context, strings, steps),
                child: Text(
                  '${strings.step} ${_currentStepIndex + 1} / $totalSteps'
                  '${_timerMinutesLeft() > 0 ? ' · ${strings.timerLeft(_timerMinutesLeft())}' : ''}',
                  key: const Key('step_progress'),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            key: const Key('cook_ingredients_button'),
            onPressed: () => _showAllIngredientsSheet(context),
            icon: const Icon(
              CookingIcons.pantry,
              size: 15,
              color: Color(0xFFFF5722),
            ),
            label: Text(
              strings.ingredientsCountFormat(widget.recipe.ingredients.length),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF5722),
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFFF5722).withValues(alpha: 0.12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          IconButton(
            tooltip: strings.a11yClose,
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
          final toolLabel = CookingIcons.getToolLabel(
            step.toolIcon,
            strings.locale,
          );

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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              toolIcon,
                              size: 16,
                              color: const Color(0xFF38BDF8),
                            ),
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
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.shopping_basket_rounded,
                              size: 16,
                              color: Color(0xFF38BDF8),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                strings.stepIngredientsUsed,
                                style: const TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF334155),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 14,
                                    color: Color(0xFF10B981),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      RecipeLocalization.localizeIngredientName(
                                        item,
                                        strings.locale,
                                      ),
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

                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Builder(
                        builder: (context) {
                          final soundOn = ref.watch(timerSoundProvider);
                          return IconButton(
                            key: const Key('timer_sound_toggle'),
                            tooltip: soundOn
                                ? strings.timerSoundOn
                                : strings.timerSoundOff,
                            icon: Icon(
                              soundOn
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_off_rounded,
                              color: const Color(0xFF94A3B8),
                            ),
                            onPressed: () =>
                                ref.read(timerSoundProvider.notifier).toggle(),
                          );
                        },
                      ),
                      IconButton(
                        key: const Key('cook_text_size'),
                        tooltip: strings.cookTextSize,
                        icon: const Icon(
                          Icons.text_increase_rounded,
                          color: Color(0xFF94A3B8),
                        ),
                        onPressed: () =>
                            ref.read(cookTextSizeProvider.notifier).cycle(),
                      ),
                    ],
                  ),
                ),

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
                    key: const Key('step_instruction'),
                    style: TextStyle(
                      fontSize: CookTextSizeNotifier
                          .sizes[ref.watch(cookTextSizeProvider)],
                      color: Color(0xFFF1F5F9),
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (index < totalSteps - 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      strings.nextStepPreview(
                        steps[index + 1].localizedTitle(strings.locale),
                      ),
                      key: const Key('next_step_preview'),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Timer Widget (if step has timer)
                if (step.timerSeconds > 0)
                  _buildTimerSection()
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          CookingIcons.clock,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            strings.stepFreePrep,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Expandable Pro-Tip Box (Acemi Püf Noktası & Vektörel Animasyon)
                if (step.proTip.isNotEmpty) _buildProTipCard(step),
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
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 8,
                      ),
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
                            strings.prevStep,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 8,
                    ),
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
                              : strings.nextStep,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
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
          color: _isTimerRunning
              ? const Color(0xFFFF5722)
              : const Color(0xFF334155),
          width: _isTimerRunning ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Icon(
                      _isTimerRunning
                          ? CookingIcons.timerActive
                          : CookingIcons.timer,
                      color: _isTimerRunning
                          ? const Color(0xFFFF5722)
                          : const Color(0xFF94A3B8),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        strings.stepTimer,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                label:
                    '${strings.stepTimer}: ${_formatSeconds(_remainingSeconds)}',
                excludeSemantics: true,
                child: Text(
                  _formatSeconds(_remainingSeconds),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: _remainingSeconds == 0
                        ? const Color(0xFF10B981)
                        : (_isTimerRunning
                              ? const Color(0xFFFF5722)
                              : Colors.white),
                  ),
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
              color: _isTimerRunning
                  ? const Color(0xFFFF5722)
                  : const Color(0xFF38BDF8),
            ),
          ),
          if (_runningSteps.any((e) => e != _currentStepIndex))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                strings.timersElsewhere(
                  _runningSteps.where((e) => e != _currentStepIndex).length,
                ),
                key: const Key('timers_elsewhere'),
                style: const TextStyle(fontSize: 12, color: Color(0xFFFBBF24)),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
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
              if (_totalStepSeconds > 0) ...[
                const SizedBox(width: 10),
                Flexible(
                  child: OutlinedButton(
                    key: const Key('add_minute'),
                    onPressed: _addMinute,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF38BDF8),
                      side: const BorderSide(color: Color(0xFF475569)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('+${strings.minutesShort(1)}'),
                    ),
                  ),
                ),
              ],
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
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            iconColor: const Color(0xFFF59E0B),
            collapsedIconColor: const Color(0xFFF59E0B),
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
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
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.tips_and_updates_rounded,
                        color: Color(0xFFF59E0B),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          step.localizedProTip(
                            ref.read(appStringsProvider).locale,
                          ),
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

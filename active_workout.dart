import 'package:flutter/material.dart';

class ActiveWorkoutPage extends StatefulWidget {
  final List<ExerciseDetail> selectedExercises;

  const ActiveWorkoutPage({
    super.key,
    required this.selectedExercises,
  });

  @override
  State<ActiveWorkoutPage> createState() => _ActiveWorkoutPageState();
}

class _ActiveWorkoutPageState extends State<ActiveWorkoutPage> {
  late List<bool> exerciseCompletionStatus;
  int completedCount = 0;

  @override
  void initState() {
    super.initState();
    // Initialize all exercises as not completed
    exerciseCompletionStatus = List.generate(
      widget.selectedExercises.length,
      (index) => false,
    );
  }

  void toggleExerciseCompletion(int index) {
    setState(() {
      exerciseCompletionStatus[index] = !exerciseCompletionStatus[index];
      
      // Count completed exercises
      completedCount = exerciseCompletionStatus.where((completed) => completed).length;
    });
  }

  void finishWorkout() {
    if (completedCount == widget.selectedExercises.length) {
      // All exercises completed
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color.fromARGB(255, 61, 44, 141),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '🎉 Congratulations!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'You completed all exercises! Great job!',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to routine page
                Navigator.pop(context); // Go back to home page
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 140, 66),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Not all exercises completed
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color.fromARGB(255, 61, 44, 141),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Workout Incomplete',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'You have ${widget.selectedExercises.length - completedCount} exercise(s) remaining. Do you want to finish anyway?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Continue Workout',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to routine page
                Navigator.pop(context); // Go back to home page
              },
              child: const Text(
                'Finish Anyway',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 140, 66),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.selectedExercises.isEmpty
        ? 0.0
        : completedCount / widget.selectedExercises.length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 61, 44, 141),
              Color.fromARGB(255, 88, 66, 184),
              Color.fromARGB(255, 107, 79, 194),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        // Show confirmation if workout is not complete
                        if (completedCount < widget.selectedExercises.length) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color.fromARGB(255, 61, 44, 141),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text(
                                'Leave Workout?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: const Text(
                                'Your progress will not be saved. Are you sure?',
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                    Navigator.pop(context); // Go back
                                  },
                                  child: const Text(
                                    'Leave',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Active Workout',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 255, 140, 66),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Progress Text
                    Text(
                      '$completedCount / ${widget.selectedExercises.length} exercises completed',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Exercise List
              Expanded(
                child: widget.selectedExercises.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 80,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No exercises selected',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: widget.selectedExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = widget.selectedExercises[index];
                          final isCompleted = exerciseCompletionStatus[index];

                          return GestureDetector(
                            onTap: () => toggleExerciseCompletion(index),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? const Color.fromARGB(255, 255, 140, 66)
                                        .withOpacity(0.2)
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCompleted
                                      ? const Color.fromARGB(255, 255, 140, 66)
                                      : Colors.white.withOpacity(0.2),
                                  width: isCompleted ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Checkbox
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? const Color.fromARGB(255, 255, 140, 66)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isCompleted
                                            ? const Color.fromARGB(255, 255, 140, 66)
                                            : Colors.white.withOpacity(0.4),
                                        width: 2,
                                      ),
                                    ),
                                    child: isCompleted
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 20,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 15),

                                  // Exercise Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exercise.name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            decoration: isCompleted
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '${exercise.sets} sets × ${exercise.reps} reps',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.7),
                                            decoration: isCompleted
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Exercise Icon
                                  Container(
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? const Color.fromARGB(255, 255, 140, 66)
                                              .withOpacity(0.3)
                                          : Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.fitness_center,
                                      color: isCompleted
                                          ? const Color.fromARGB(255, 255, 140, 66)
                                          : Colors.white70,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Finish Workout Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: widget.selectedExercises.isEmpty
                        ? null
                        : finishWorkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 140, 66),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Finish Workout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
}

// Data Model for Exercise Details
class ExerciseDetail {
  final String name;
  final int sets;
  final int reps;

  ExerciseDetail({
    required this.name,
    required this.sets,
    required this.reps,
  });
}

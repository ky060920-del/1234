import 'package:flutter/material.dart';
import 'active_workout.dart'; // Import the new active workout page

class WorkoutRoutinePage extends StatefulWidget {
  const WorkoutRoutinePage({super.key});

  @override
  State<WorkoutRoutinePage> createState() => _WorkoutRoutinePageState();
}

class _WorkoutRoutinePageState extends State<WorkoutRoutinePage> {
  String? expandedMuscle;
  Map<String, Exercise> selectedExercisesMap = {}; // Store selected exercises by ID

  final Map<String, MuscleGroup> muscleGroups = {
    'chest': MuscleGroup(
      name: 'Chest',
      exercises: [
        Exercise(id: 'bench', name: 'Bench Press', sets: 3, reps: 10),
        Exercise(id: 'incline', name: 'Incline Dumbbell Press', sets: 3, reps: 12),
        Exercise(id: 'pushups', name: 'Push-ups', sets: 3, reps: 15),
        Exercise(id: 'cable-fly', name: 'Cable Chest Fly', sets: 3, reps: 12),
      ],
    ),
    'back': MuscleGroup(
      name: 'Back',
      exercises: [
        Exercise(id: 'pullups', name: 'Pull-ups', sets: 3, reps: 10),
        Exercise(id: 'rows', name: 'Barbell Rows', sets: 3, reps: 12),
        Exercise(id: 'lat-pulldown', name: 'Lat Pulldown', sets: 3, reps: 12),
        Exercise(id: 'deadlift', name: 'Deadlift', sets: 3, reps: 8),
      ],
    ),
    'shoulders': MuscleGroup(
      name: 'Shoulders',
      exercises: [
        Exercise(id: 'overhead-press', name: 'Overhead Press', sets: 3, reps: 10),
        Exercise(id: 'lateral-raise', name: 'Lateral Raise', sets: 3, reps: 15),
        Exercise(id: 'front-raise', name: 'Front Raise', sets: 3, reps: 12),
        Exercise(id: 'reverse-fly', name: 'Reverse Fly', sets: 3, reps: 12),
      ],
    ),
    'legs': MuscleGroup(
      name: 'Legs',
      exercises: [
        Exercise(id: 'squat', name: 'Barbell Squat', sets: 3, reps: 10),
        Exercise(id: 'leg-press', name: 'Leg Press', sets: 3, reps: 12),
        Exercise(id: 'lunges', name: 'Walking Lunges', sets: 3, reps: 15),
        Exercise(id: 'leg-curl', name: 'Leg Curl', sets: 3, reps: 12),
      ],
    ),
    'arms': MuscleGroup(
      name: 'Arms',
      exercises: [
        Exercise(id: 'bicep-curl', name: 'Bicep Curl', sets: 3, reps: 12),
        Exercise(id: 'tricep-dip', name: 'Tricep Dips', sets: 3, reps: 10),
        Exercise(id: 'hammer-curl', name: 'Hammer Curl', sets: 3, reps: 12),
        Exercise(id: 'skull-crusher', name: 'Skull Crushers', sets: 3, reps: 10),
      ],
    ),
  };

  void toggleMuscleGroup(String muscleId) {
    setState(() {
      expandedMuscle = expandedMuscle == muscleId ? null : muscleId;
    });
  }

  void toggleExercise(Exercise exercise) {
    setState(() {
      if (selectedExercisesMap.containsKey(exercise.id)) {
        selectedExercisesMap.remove(exercise.id);
      } else {
        selectedExercisesMap[exercise.id] = exercise;
      }
    });
  }

  void startWorkout() {
    if (selectedExercisesMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one exercise'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Convert selected exercises to ExerciseDetail list
    final exerciseDetails = selectedExercisesMap.values
        .map((exercise) => ExerciseDetail(
              name: exercise.name,
              sets: exercise.sets,
              reps: exercise.reps,
            ))
        .toList();

    // Navigate to Active Workout Page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveWorkoutPage(
          selectedExercises: exerciseDetails,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Choose Your Routine',
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

              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 255, 182, 193),
                      Color.fromARGB(255, 255, 140, 156),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fitness_center,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Subtitle with count
              Text(
                selectedExercisesMap.isEmpty
                    ? 'Select exercises to get started'
                    : '${selectedExercisesMap.length} exercise${selectedExercisesMap.length == 1 ? '' : 's'} selected',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 200, 180, 220),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),

              // Section Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'What muscle group to train?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Muscle Groups List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: muscleGroups.length,
                  itemBuilder: (context, index) {
                    final muscleId = muscleGroups.keys.elementAt(index);
                    final muscle = muscleGroups[muscleId]!;
                    final isExpanded = expandedMuscle == muscleId;

                    return Column(
                      children: [
                        // Muscle Group Header
                        GestureDetector(
                          onTap: () => toggleMuscleGroup(muscleId),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                              borderRadius: isExpanded
                                  ? const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    )
                                  : BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color.fromARGB(255, 200, 180, 220),
                                          width: 2,
                                        ),
                                        color: isExpanded
                                            ? const Color.fromARGB(255, 200, 180, 220)
                                            : Colors.transparent,
                                      ),
                                      child: isExpanded
                                          ? Center(
                                              child: Container(
                                                width: 12,
                                                height: 12,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 15),
                                    Text(
                                      muscle.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_down
                                      : Icons.chevron_right,
                                  color: const Color.fromARGB(255, 200, 180, 220),
                                  size: 28,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Exercise List (when expanded)
                        if (isExpanded)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Column(
                              children: muscle.exercises.map((exercise) {
                                final isSelected = selectedExercisesMap.containsKey(exercise.id);
                                final isLast = exercise == muscle.exercises.last;

                                return GestureDetector(
                                  onTap: () => toggleExercise(exercise),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: isLast
                                          ? null
                                          : Border(
                                              bottom: BorderSide(
                                                color: Colors.white.withOpacity(0.1),
                                                width: 1,
                                              ),
                                            ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: const Color.fromARGB(255, 200, 180, 220),
                                                  width: 2,
                                                ),
                                                color: isSelected
                                                    ? const Color.fromARGB(255, 200, 180, 220)
                                                    : Colors.transparent,
                                              ),
                                              child: isSelected
                                                  ? Center(
                                                      child: Container(
                                                        width: 10,
                                                        height: 10,
                                                        decoration: const BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  exercise.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${exercise.sets} sets of ${exercise.reps} reps',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white.withOpacity(0.6),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.white.withOpacity(0.5),
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
              ),

              // Start Workout Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: startWorkout,
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
                      'Start Workout',
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

// Data Models
class MuscleGroup {
  final String name;
  final List<Exercise> exercises;

  MuscleGroup({
    required this.name,
    required this.exercises,
  });
}

class Exercise {
  final String id;
  final String name;
  final int sets;
  final int reps;

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
  });
}

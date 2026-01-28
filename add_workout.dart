import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddWorkoutPage extends StatefulWidget {
  const AddWorkoutPage({super.key});

  @override
  State<AddWorkoutPage> createState() => _AddWorkoutPageState();
}

class _AddWorkoutPageState extends State<AddWorkoutPage> {
  final exerciseNameController = TextEditingController();
  final setsController = TextEditingController();
  final repsController = TextEditingController();

  @override
  void dispose() {
    exerciseNameController.dispose();
    setsController.dispose();
    repsController.dispose();
    super.dispose();
  }

  Future<void> _addWorkout() async {
    if (exerciseNameController.text.isEmpty ||
        setsController.text.isEmpty ||
        repsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final sets = int.tryParse(setsController.text);
    final reps = int.tryParse(repsController.text);

    if (sets == null || sets <= 0 || reps == null || reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid numbers for sets and reps'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('workouts').add({
        'userId': user.uid,
        'exerciseName': exerciseNameController.text.trim(),
        'sets': sets,
        'reps': reps,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout added successfully! 🎉'),
          backgroundColor: Color.fromARGB(255, 255, 140, 66),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Add Workout',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Exercise Name Field
                  const Text(
                    'Exercise Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: exerciseNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      fillColor: Colors.white.withOpacity(0.1),
                      filled: true,
                      hintText: 'e.g., Push-ups, Squats',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                      prefixIcon: const Icon(
                        Icons.fitness_center,
                        color: Colors.white70,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Sets Field
                  const Text(
                    'Sets',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: setsController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      fillColor: Colors.white.withOpacity(0.1),
                      filled: true,
                      hintText: 'e.g., 3',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                      prefixIcon: const Icon(
                        Icons.repeat,
                        color: Colors.white70,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Reps Field
                  const Text(
                    'Reps',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      fillColor: Colors.white.withOpacity(0.1),
                      filled: true,
                      hintText: 'e.g., 12',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                      prefixIcon: const Icon(
                        Icons.numbers,
                        color: Colors.white70,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Add Workout Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _addWorkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 140, 66),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Add Workout',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

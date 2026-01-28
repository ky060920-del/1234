import 'package:flutter/material.dart';
import 'package:mad_assignment/gymlocator.dart';
import 'loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'leaderboard.dart';
import 'workout.dart';
import 'profile.dart';
import 'workout_routine.dart'; // Add this import


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  Future<List<DocumentSnapshot>> _loadWorkouts(String? userId) async {
    if (userId == null) return [];
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('activeWorkouts')
          .where('userId', isEqualTo: userId)
          .get();
      
      // Sort by timestamp manually
      final docs = snapshot.docs.toList();
      docs.sort((a, b) {
        final aTime = (a.data())['timestamp'] as Timestamp?;
        final bTime = (b.data())['timestamp'] as Timestamp?;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });
      
      // Return only first 5
      return docs.take(5).toList();
    } catch (e) {
      print('Error loading workouts: $e');
      return [];
    }
  }

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _onNavBarTap(int index) {
    if (index == 0) {
      // Home - stay on current page (do nothing or refresh if needed)
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 1) {
      // Leaderboard tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LeaderboardPage()),
      ).then((_) {
        // Reset selection when returning
        setState(() {
          _selectedIndex = 0;
        });
      });
    } else if (index == 2) {
      // Log tab - navigate to workout log
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WorkoutLogPage()),
      ).then((_) {
        // Reset selection when returning
        setState(() {
          _selectedIndex = 0;
        });
      });
    } else if (index == 3) {
      // Start Workout tab - navigate to workout routine
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WorkoutRoutinePage()),
      ).then((_) {
        // Reset selection and refresh workouts when returning
        setState(() {
          _selectedIndex = 0;
        });
      });
    }
  }

  String _formatDuration(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 61, 44, 141),   // Deep purple
              Color.fromARGB(255, 88, 66, 184),   // Medium purple
              Color.fromARGB(255, 107, 79, 194),  // Light purple
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with logo and logout
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DAILY FIT',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Welcome back, ${user?.email?.split('@')[0] ?? 'User'}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.person, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProfilePage()),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: () => logout(context),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Track your progress below:',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GymLocatorPage()),
                        );
                      },
                      icon: const Icon(
                        Icons.location_on,
                        color: Color.fromARGB(255, 255, 140, 66),
                        size: 20,
                      ),
                      label: const Text(
                        'Find Gyms',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 140, 66),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Recent Workouts Section
                Expanded(
                  child: FutureBuilder<List<DocumentSnapshot>>(
                    future: _loadWorkouts(user?.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
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
                                'No workouts yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Start your first workout!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final docs = snapshot.data!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Workouts',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Expanded(
                            child: ListView.builder(
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final data = docs[index].data() as Map<String, dynamic>;
                                final exerciseName = data['exerciseName'] as String? ?? 'Unknown';
                                final sets = data['sets'] as int? ?? 0;
                                final reps = data['reps'] as int? ?? 0;
                                final duration = data['duration'] as int? ?? 0;
                                final completedSets = data['completedSets'] as int? ?? 0;
                                final timestamp = data['timestamp'] as Timestamp?;
                                
                                String timeAgo = 'Just now';
                                if (timestamp != null) {
                                  final diff = DateTime.now().difference(timestamp.toDate());
                                  if (diff.inDays > 0) {
                                    timeAgo = '${diff.inDays}d ago';
                                  } else if (diff.inHours > 0) {
                                    timeAgo = '${diff.inHours}h ago';
                                  } else if (diff.inMinutes > 0) {
                                    timeAgo = '${diff.inMinutes}m ago';
                                  }
                                }

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 45,
                                            height: 45,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(255, 255, 140, 66)
                                                  .withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.fitness_center,
                                              color: Color.fromARGB(255, 255, 140, 66),
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  exerciseName,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  timeAgo,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white.withOpacity(0.5),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Completed',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildStatChip(
                                            Icons.repeat,
                                            '$completedSets/$sets sets',
                                          ),
                                          _buildStatChip(
                                            Icons.fitness_center,
                                            '$reps reps',
                                          ),
                                          _buildStatChip(
                                            Icons.timer,
                                            _formatDuration(duration),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 46, 35, 85),
        selectedItemColor: const Color.fromARGB(255, 255, 140, 66),
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Log'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Start'),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white.withOpacity(0.7),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

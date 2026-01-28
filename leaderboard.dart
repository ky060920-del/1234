import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {

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
                    const Text(
                      'Streak Leaderboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Top users by workout streak 🔥',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Leaderboard List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .orderBy('streak', descending: true)
                      .limit(100)
                      .snapshots(),
                  builder: (context, snapshot) {

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Error loading leaderboard',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No users yet',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    final currentUserId =
                        FirebaseAuth.instance.currentUser?.uid;

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {

                        final data =
                            docs[index].data() as Map<String, dynamic>;

                        final userId = docs[index].id;
                        final userName =
                            data['userName'] ?? 'Unknown';
                        final streak = data['streak'] ?? 0;
                        final isCurrentUser =
                            userId == currentUserId;

                        final rank = index + 1;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? const Color.fromARGB(255, 255, 140, 66)
                                    .withOpacity(0.3)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: isCurrentUser
                                ? Border.all(
                                    color: const Color.fromARGB(255, 255, 140, 66),
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [

                              // Rank
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getRankColor(rank),
                                ),
                                child: Center(
                                  child: Text(
                                    rank <= 3
                                        ? _getRankEmoji(rank)
                                        : '$rank',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 15),

                              // Name
                              Expanded(
                                child: Text(
                                  userName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // Streak
                              Row(
                                children: [
                                  Text(
                                    '$streak',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text('🔥'),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _incrementStreak,
        backgroundColor: const Color.fromARGB(255, 255, 140, 66),
        icon: const Icon(Icons.add),
        label: const Text('Log Workout'),
      ),
    );
  }

  // 🔥 INCREMENT STREAK + UPDATE LEADERBOARD
  Future<void> _incrementStreak() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userId = user.uid;
      final userName =
          user.displayName ?? user.email?.split('@')[0] ?? 'Anonymous';

      final docRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      final doc = await docRef.get();

      int newStreak = 1;

      if (doc.exists) {
        final currentStreak =
            doc.data()?['streak'] as int? ?? 0;
        newStreak = currentStreak + 1;
      }

      await docRef.set({
        'userName': userName,
        'email': user.email,
        'streak': newStreak,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Streak updated: $newStreak 🔥'),
            backgroundColor:
                const Color.fromARGB(255, 255, 140, 66),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color.fromARGB(255, 255, 215, 0);
      case 2:
        return const Color.fromARGB(255, 192, 192, 192);
      case 3:
        return const Color.fromARGB(255, 205, 127, 50);
      default:
        return Colors.white.withOpacity(0.2);
    }
  }

  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }
}

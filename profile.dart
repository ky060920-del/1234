import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// COLLECTION NAME: 'profile'
// This stores user profile data (username, height, weight, targetBMI)

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final usernameController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final targetBMIController = TextEditingController();

  double currentBMI = 0.0;
  double targetBMI = 22.0;
  double height = 0.0;
  double weight = 0.0;
  bool isDataLoaded = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Load from 'profile' collection
    final userDoc = await FirebaseFirestore.instance
        .collection('profile')  // COLLECTION NAME: 'profile'
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data();
      setState(() {
        height = (data?['height'] as num?)?.toDouble() ?? 0.0;
        weight = (data?['weight'] as num?)?.toDouble() ?? 0.0;
        targetBMI = (data?['targetBMI'] as num?)?.toDouble() ?? 22.0;
        usernameController.text = data?['userName'] ?? user.email?.split('@')[0] ?? 'User';
        heightController.text = height > 0 ? height.toString() : '';
        weightController.text = weight > 0 ? weight.toString() : '';
        targetBMIController.text = targetBMI.toString();
        isDataLoaded = true;
        _calculateBMI();
      });
    } else {
      setState(() {
        usernameController.text = user.email?.split('@')[0] ?? 'User';
        targetBMIController.text = '22.0';
        isDataLoaded = true;
      });
    }
  }

  void _calculateBMI() {
    if (height > 0 && weight > 0) {
      setState(() {
        currentBMI = weight / ((height / 100) * (height / 100));
      });
    }
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  void _toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });

    if (!isEditing) {
      _loadUserData();
    }
  }

  Future<void> _updateProfile() async {
    final username = usernameController.text.trim();
    final h = double.tryParse(heightController.text);
    final w = double.tryParse(weightController.text);
    final tBMI = double.tryParse(targetBMIController.text);

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a username')),
      );
      return;
    }

    if (h == null || w == null || h <= 0 || w <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid height and weight')),
      );
      return;
    }

    if (tBMI == null || tBMI <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid target BMI')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Save to 'profile' collection
    await FirebaseFirestore.instance.collection('profile').doc(user.uid).set({
      'userId': user.uid,
      'email': user.email,
      'userName': username,
      'height': h,
      'weight': w,
      'targetBMI': tBMI,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    setState(() {
      height = h;
      weight = w;
      targetBMI = tBMI;
      _calculateBMI();
      isEditing = false;
    });

    if (mounted) {
      final difference = (currentBMI - targetBMI).abs();
      String message;
      Color bgColor;

      if (currentBMI >= targetBMI - 0.5 && currentBMI <= targetBMI + 0.5) {
        message = '🎉 Congratulations! You hit your target BMI!';
        bgColor = Colors.green;
      } else if (currentBMI < targetBMI) {
        message = 'You are ${difference.toStringAsFixed(1)} below your target BMI. Keep going! 💪';
        bgColor = Colors.blue;
      } else {
        message = 'You are ${difference.toStringAsFixed(1)} above your target BMI. Stay focused! 🔥';
        bgColor = Colors.orange;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: bgColor,
          duration: const Duration(seconds: 4),
        ),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header with Edit Button
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        isEditing ? Icons.close : Icons.edit,
                        color: Colors.white,
                      ),
                      onPressed: _toggleEditMode,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                // Username Input
                TextField(
                  controller: usernameController,
                  enabled: isEditing,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    fillColor: Colors.white.withOpacity(isEditing ? 0.1 : 0.05),
                    filled: true,
                    labelText: 'Username',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Height Input
                TextField(
                  controller: heightController,
                  enabled: isEditing,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    fillColor: Colors.white.withOpacity(isEditing ? 0.1 : 0.05),
                    filled: true,
                    labelText: 'Height (cm)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.height, color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Weight Input
                TextField(
                  controller: weightController,
                  enabled: isEditing,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    fillColor: Colors.white.withOpacity(isEditing ? 0.1 : 0.05),
                    filled: true,
                    labelText: 'Weight (kg)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.monitor_weight_outlined, color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Target BMI Input
                TextField(
                  controller: targetBMIController,
                  enabled: isEditing,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    fillColor: Colors.white.withOpacity(isEditing ? 0.1 : 0.05),
                    filled: true,
                    labelText: 'Target BMI',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.flag_outlined, color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Update Button (only visible in edit mode)
                if (isEditing)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 140, 66),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (isEditing) const SizedBox(height: 25),

                // Current Stats Display
                if (isDataLoaded && currentBMI > 0)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Your Stats',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Height', '${height.toStringAsFixed(1)} cm'),
                            _buildStatItem('Weight', '${weight.toStringAsFixed(1)} kg'),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Divider(color: Colors.white30),
                        const SizedBox(height: 15),
                        const Text(
                          'Current BMI',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          currentBMI.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: _getBMIColor(currentBMI),
                          ),
                        ),
                        Text(
                          _getBMICategory(currentBMI),
                          style: TextStyle(
                            fontSize: 18,
                            color: _getBMIColor(currentBMI),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Target BMI: ${targetBMI.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                // BMI Reference
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BMI Categories:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildBMIReference('Underweight', '< 18.5', Colors.blue),
                      _buildBMIReference('Normal', '18.5 - 24.9', Colors.green),
                      _buildBMIReference('Overweight', '25 - 29.9', Colors.orange),
                      _buildBMIReference('Obese', '≥ 30', Colors.red),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBMIReference(String category, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$category: ',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          Text(
            range,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

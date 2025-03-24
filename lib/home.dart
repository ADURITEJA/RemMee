import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'routines.dart';
import 'schedules.dart';
import 'ai_word_game.dart';
import 'memories.dart';
import 'record.dart';
import 'memory_analysis.dart';
import 'medical_chat_screen.dart';
import 'guardian_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> memories = [];
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _loadMemories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndShowVideoPopup();
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadMemories() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? storedMemories = prefs.getStringList('memories');
    if (storedMemories != null) {
      setState(() {
        memories =
            storedMemories
                .map((m) => json.decode(m))
                .cast<Map<String, dynamic>>()
                .toList();
      });
    }
  }

  Future<void> _initializeAndShowVideoPopup() async {
    _videoController = VideoPlayerController.asset('assets/your_video.mp4');
    await _videoController!.initialize();
    setState(() {});
    _videoController!.play();
    _showVideoPopup();
  }

  void _showVideoPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _videoController != null &&
                        _videoController!.value.isInitialized
                    ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                    : Container(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                TextButton(
                  onPressed: () {
                    _videoController?.pause();
                    Navigator.of(context).pop();
                    _videoController?.dispose();
                  },
                  child: const Text("Close"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RemMe - Memory App")),
      drawer: Drawer(
        child: Container(
          color: Colors.deepPurple,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.purple),
                child: Text(
                  "Menu",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              _buildDrawerItem("Routines", Icons.list, RoutinesPage()),
              _buildDrawerItem(
                "Schedules",
                Icons.calendar_today,
                SchedulesPage(),
              ),
              _buildDrawerItem(
                "AI Word Game",
                Icons.games,
                AIWordGameScreen(
                  memoryTexts:
                      memories
                          .map<String>((memory) => memory['text'].toString())
                          .toList(),
                ),
              ),
              _buildDrawerItem(
                "Memories",
                Icons.photo,
                MemoriesScreen(memories: memories),
              ),
              _buildDrawerItem(
                "Memory Analysis",
                Icons.analytics,
                MemoryAnalysisPage(),
              ),
              _buildDrawerItem(
                "Medical Chatbot",
                Icons.medical_services,
                const MedicalChatScreen(),
              ),
              _buildDrawerItem(
                "Guardian Dashboard",
                Icons.supervisor_account,
                GuardianDashboard(),
              ),
            ],
          ),
        ),
      ),
      body:
          _selectedIndex == 0
              ? MemoriesScreen(memories: memories)
              : Container(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RoutinesPage()),
              );
            },
            backgroundColor: Colors.pink,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecordScreen()),
              ).then((newMemory) {
                if (newMemory != null) {
                  setState(() {
                    memories.add(newMemory);
                  });
                }
              });
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.mic),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, Widget screen) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      leading: Icon(icon, color: Colors.white),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }
}

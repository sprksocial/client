import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator, AlwaysStoppedAnimation;
import 'package:ionicons/ionicons.dart';

class CreateVideoScreen extends StatefulWidget {
  const CreateVideoScreen({super.key});

  @override
  State<CreateVideoScreen> createState() => _CreateVideoScreenState();
}

class _CreateVideoScreenState extends State<CreateVideoScreen> {
  int _selectedEffectIndex = 0;
  double _zoomLevel = 1.0;
  bool _isRecording = false;
  
  final List<String> _effects = [
    'None', 'Beauty', 'Filters', 'Green Screen', 'Slow Motion'
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        children: [
          // Camera preview (placeholder)
          Container(
            color: CupertinoColors.black,
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Icon(
                Ionicons.camera_outline,
                size: 100,
                color: CupertinoColors.white.withOpacity(0.3),
              ),
            ),
          ),
          
          // Top controls
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Ionicons.close_outline,
                      color: CupertinoColors.white,
                      size: 30,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Ionicons.flash_outline,
                        color: CupertinoColors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 20),
                      const Icon(
                        Ionicons.time_outline,
                        color: CupertinoColors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 20),
                      const Icon(
                        Ionicons.options_outline,
                        color: CupertinoColors.white,
                        size: 30,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Zoom control
          Positioned(
            top: 100,
            right: 16,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _zoomLevel = (_zoomLevel >= 5.0) ? 5.0 : _zoomLevel + 0.5;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: CupertinoColors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(
                        Ionicons.add_outline,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_zoomLevel.toStringAsFixed(1)}x',
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _zoomLevel = (_zoomLevel <= 1.0) ? 1.0 : _zoomLevel - 0.5;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: CupertinoColors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(
                        Ionicons.remove_outline,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    CupertinoColors.black,
                    CupertinoColors.black.withOpacity(0.0),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Effects scroll
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _effects.length,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedEffectIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedEffectIndex == index 
                                  ? CupertinoColors.systemPink 
                                  : CupertinoColors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: CupertinoColors.white.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _effects[index],
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Recording controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(
                        Ionicons.image_outline,
                        color: CupertinoColors.white,
                        size: 30,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isRecording = !_isRecording;
                          });
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: CupertinoColors.white,
                              width: 5,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: _isRecording ? 40 : 65,
                              height: _isRecording ? 40 : 65,
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemPink,
                                borderRadius: BorderRadius.circular(_isRecording ? 8 : 65),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Icon(
                        Ionicons.checkmark_circle_outline,
                        color: CupertinoColors.white,
                        size: 30,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Duration indicator
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    height: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2.5),
                      child: LinearProgressIndicator(
                        value: _isRecording ? 0.3 : 0,
                        backgroundColor: CupertinoColors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(CupertinoColors.systemPink),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  const Text(
                    '00:15 / 03:00',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
import 'dart:math' as math;
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mic_stream/mic_stream.dart' as mic;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart' as sound;

class MeshWaveScreen extends StatefulWidget {
  const MeshWaveScreen({super.key});

  @override
  State<MeshWaveScreen> createState() => _MeshWaveScreenState();
}

class _MeshWaveScreenState extends State<MeshWaveScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isDetectingSound = false; // State to track sound detection

  // Microphone streaming (for mobile)
  StreamSubscription<Uint8List>? _micSubscription;

  // Flutter Sound (for web)
  sound.FlutterSoundRecorder? _soundRecorder;
  StreamSubscription? _soundSubscription;

  bool _isListening = false;
  String _errorMessage = '';
  double _currentAmplitude = 0.0;

  // Sound detection threshold (lowered for better sensitivity)
  static const double soundThreshold = 5.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Start listening to microphone
    _initializeMicrophone();
  }

  @override
  void dispose() {
    _stopListening();
    _soundRecorder?.closeRecorder();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeMicrophone() async {
    if (kIsWeb) {
      // For web, use flutter_sound
      await _initializeWebMicrophone();
    } else {
      // For mobile, use mic_stream with permission check
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        _startListening();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Microphone permission is required to detect sound',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _initializeWebMicrophone() async {
    try {
      _soundRecorder = sound.FlutterSoundRecorder();
      await _soundRecorder!.openRecorder();
      await _soundRecorder!.setSubscriptionDuration(
        const Duration(milliseconds: 100),
      );
      _startWebListening();
    } catch (e) {
      debugPrint('Error initializing web microphone: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Web microphone error: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize microphone: $e'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startWebListening() async {
    try {
      setState(() {
        _errorMessage = '';
      });

      // Start recording to null (just to get decibel levels)
      // Using opusWebM codec as it's supported on web (pcm16 is not)
      await _soundRecorder!.startRecorder(
        toFile: null, // Don't save to file, just monitor levels
        codec: sound.Codec.opusWebM,
        sampleRate: 16000,
      );

      // Listen to decibel levels
      _soundSubscription = _soundRecorder!.onProgress!.listen((event) {
        if (event.decibels != null) {
          // Convert decibels to amplitude-like value
          // Typical speaking is around 40-60 dB
          // We'll normalize this to match our threshold
          final double dbLevel = event.decibels!;
          // Map dB from range [0, 120] to amplitude scale
          // -120 dB (silence) to 0 dB (very loud)
          final double normalizedAmplitude = ((dbLevel + 120) / 10).clamp(
            0.0,
            100.0,
          );

          setState(() {
            _currentAmplitude = normalizedAmplitude;
            _isDetectingSound = normalizedAmplitude > soundThreshold;
          });
        }
      });

      setState(() {
        _isListening = true;
      });
    } catch (e) {
      debugPrint('Error starting web listening: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to start: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start microphone: $e'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startListening() async {
    try {
      setState(() {
        _errorMessage = '';
      });

      _micSubscription =
          mic.MicStream.microphone(
            audioSource: mic.AudioSource.DEFAULT,
            sampleRate: 16000,
            channelConfig: mic.ChannelConfig.CHANNEL_IN_MONO,
            audioFormat: mic.AudioFormat.ENCODING_PCM_16BIT,
          ).listen(
            (samples) {
              // Calculate sound level from audio samples
              if (samples.isNotEmpty) {
                // Convert bytes to 16-bit integers
                int sum = 0;
                for (int i = 0; i < samples.length - 1; i += 2) {
                  int sample = (samples[i + 1] << 8) | samples[i];
                  // Convert to signed value
                  if (sample > 32767) sample -= 65536;
                  sum += sample.abs();
                }

                final double average = sum / (samples.length / 2);

                setState(() {
                  _currentAmplitude = average;
                  // Detect sound if level exceeds threshold
                  _isDetectingSound = average > soundThreshold;
                });
              }
            },
            onError: (error) {
              if (mounted) {
                setState(() {
                  _errorMessage = 'Microphone error: $error';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Microphone error: $error'),
                    duration: const Duration(seconds: 5),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          );

      setState(() {
        _isListening = true;
      });
    } catch (e) {
      debugPrint('Error starting microphone: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to start: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start microphone: $e'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _stopListening() async {
    if (kIsWeb) {
      // Stop web recording
      _soundSubscription?.cancel();
      _soundSubscription = null;
      if (_soundRecorder != null && _soundRecorder!.isRecording) {
        await _soundRecorder!.stopRecorder();
      }
    } else {
      // Stop mobile mic stream
      _micSubscription?.cancel();
      _micSubscription = null;
    }

    if (mounted) {
      setState(() {
        _isListening = false;
        _isDetectingSound = false;
      });
    }
  }

  void _toggleSoundDetection() {
    if (_isListening) {
      _stopListening();
    } else {
      _initializeMicrophone();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // title: const Text(
        //   'Mesh Wave Visualization',
        //   style: TextStyle(color: Color(0xFF4A6CF7)),
        // ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4A6CF7)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _toggleSoundDetection, // Toggle on tap
                child: Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isDetectingSound
                          ? const Color(0xFF4A6CF7).withOpacity(0.3)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        return CustomPaint(
                          size: Size.infinite,
                          painter: MeshWavePainter(
                            animationValue: _controller.value,
                            waveColor: const Color.fromARGB(255, 1, 28, 136),
                            isDetectingSound:
                                _isDetectingSound, // Pass state to painter
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isDetectingSound ? "Detecting Sound..." : "No Sound Detected",
                style: TextStyle(
                  color: _isDetectingSound
                      ? const Color(0xFF4A6CF7)
                      : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isListening
                    ? "Microphone is listening... Tap to stop"
                    : "Tap to start listening",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              if (_isListening)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Current Amplitude: ${_currentAmplitude.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF4A6CF7),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Threshold: $soundThreshold',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class MeshWavePainter extends CustomPainter {
  final double animationValue;
  final Color waveColor;
  final bool isDetectingSound; // New parameter

  MeshWavePainter({
    required this.animationValue,
    required this.waveColor,
    required this.isDetectingSound,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerY = size.height / 2;

    // Generate exactly 316 smooth flowing wave layers with Bézier curves
    final List<WaveLayer> waveLayers = [];

    for (int i = 0; i < 316; i++) {
      // Normalize index for calculations (0.0 to 1.0)
      final double normalized = i / 315.0;

      // Create varied frequency distribution (low to high frequency)
      // Using sine wave distribution for natural clustering
      final double freqBase = 0.006 + (normalized * 0.024);
      final double freqVariation = math.sin(normalized * math.pi * 4) * 0.003;
      final double frequency = freqBase + freqVariation;

      // Amplitude varies in waves - creating depth perception
      // If not detecting sound, amplitude is 0 (flat line)
      final double ampBase = 0.12 + (math.sin(normalized * math.pi * 6) * 0.10);
      final double ampVariation = math.cos(normalized * math.pi * 3) * 0.05;
      double amplitude =
          size.height * (ampBase + ampVariation).clamp(0.08, 0.32);

      if (!isDetectingSound) {
        amplitude = 0.0;
      }

      // Speed distribution - mix of slow, medium, and fast
      final double speedBase = 0.5 + (normalized * 1.2);
      final double speedVariation = math.sin(normalized * math.pi * 8) * 0.3;
      final double speed = (speedBase + speedVariation).clamp(0.4, 1.8);

      // Phase distribution - ensures waves are well spread temporally
      final double phaseMultiplier = 1.0 + (normalized * 2.5);
      final double phaseVariation = math.cos(normalized * math.pi * 5) * 0.5;
      final double phase =
          animationValue * (phaseMultiplier + phaseVariation) * math.pi;

      // Opacity varies to create depth - some layers more prominent
      final double opacityBase =
          0.04 + (math.sin(normalized * math.pi * 7) * 0.04);
      final double opacityVariation = (1.0 - normalized) * 0.03;
      final double opacity = (opacityBase + opacityVariation).clamp(0.03, 0.12);

      // Stroke width - all 1.0 as requested
      final double strokeWidth = 1.0;

      // Color shift - gradual progression through the color spectrum
      final double colorShift =
          normalized + (math.sin(normalized * math.pi * 3) * 0.1);

      // Vertical offset - spread layers across vertical space
      final double verticalOffsetBase = (normalized - 0.5) * size.height * 0.08;
      final double verticalOffsetVariation =
          math.sin(normalized * math.pi * 9) * size.height * 0.02;
      final double verticalOffset =
          verticalOffsetBase + verticalOffsetVariation;

      waveLayers.add(
        WaveLayer(
          amplitude: amplitude,
          frequency: frequency,
          speed: speed,
          phase: phase,
          opacity: opacity,
          strokeWidth: strokeWidth,
          colorShift: colorShift,
          verticalOffset: verticalOffset,
        ),
      );
    }

    // Draw each wave layer with smooth Bézier curves
    for (final layer in waveLayers) {
      _drawMeshCurve(canvas, size, centerY, layer);
    }
  }

  void _drawMeshCurve(
    Canvas canvas,
    Size size,
    double centerY,
    WaveLayer layer,
  ) {
    // Create subtle gradient color
    final Color layerColor = _getSubtleGradientColor(layer.colorShift);

    final Paint wavePaint = Paint()
      ..color = layerColor.withOpacity(layer.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = layer.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path wavePath = Path();
    final int segments = 800;
    final double segmentWidth = size.width / segments;

    // Apply vertical offset for mesh spreading
    final double adjustedCenterY = centerY + layer.verticalOffset;

    // Generate wave points with complex harmonic combinations
    final List<Offset> wavePoints = [];
    for (int i = 0; i <= segments; i++) {
      final double x = i * segmentWidth;

      // Use multiple harmonics to create organic, flowing curves
      final double wave1 = math.sin(x * layer.frequency + layer.phase);
      final double wave2 =
          math.sin(x * layer.frequency * 1.7 + layer.phase * 0.6) * 0.5;
      final double wave3 =
          math.sin(x * layer.frequency * 0.3 + layer.phase * 1.4) * 0.35;
      final double wave4 =
          math.sin(x * layer.frequency * 2.4 + layer.phase * 0.45) * 0.2;
      final double wave5 =
          math.sin(x * layer.frequency * 3.1 + layer.phase * 0.8) * 0.15;

      // Combine all harmonics for rich, complex curves
      final double combinedWave =
          (wave1 + wave2 + wave3 + wave4 + wave5) * layer.amplitude;
      final double y = adjustedCenterY + combinedWave;

      wavePoints.add(Offset(x, y));
    }

    // Create ultra-smooth path using cubic Bézier curves
    if (wavePoints.isNotEmpty) {
      wavePath.moveTo(wavePoints[0].dx, wavePoints[0].dy);

      // Use cubic bezier for even smoother curves
      for (int i = 0; i < wavePoints.length - 3; i += 3) {
        final p0 = wavePoints[i];
        final p1 = wavePoints[i + 1];
        final p2 = wavePoints[i + 2];
        final p3 = wavePoints[i + 3];

        // Create control points for cubic bezier
        final cp1x = p0.dx + (p1.dx - p0.dx) * 0.66;
        final cp1y = p0.dy + (p1.dy - p0.dy) * 0.66;
        final cp2x = p2.dx - (p3.dx - p2.dx) * 0.66;
        final cp2y = p2.dy - (p3.dy - p2.dy) * 0.66;

        wavePath.cubicTo(cp1x, cp1y, cp2x, cp2y, p3.dx, p3.dy);
      }
    }

    canvas.drawPath(wavePath, wavePaint);
  }

  // Generate very subtle gradient colors - lighter blues and purples
  Color _getSubtleGradientColor(double shift) {
    final double normalizedShift = (shift % 1.0);

    if (normalizedShift < 0.33) {
      // Light blue to medium blue
      return Color.lerp(
        const Color(0xFF7B9EFF),
        const Color(0xFF5B7FFF),
        normalizedShift * 3,
      )!;
    } else if (normalizedShift < 0.66) {
      // Medium blue to purple-blue
      return Color.lerp(
        const Color(0xFF5B7FFF),
        const Color(0xFF6B6FFF),
        (normalizedShift - 0.33) * 3,
      )!;
    } else {
      // Purple-blue to light purple
      return Color.lerp(
        const Color(0xFF6B6FFF),
        const Color(0xFF8B7FEE),
        (normalizedShift - 0.66) * 3,
      )!;
    }
  }

  @override
  bool shouldRepaint(covariant MeshWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isDetectingSound != isDetectingSound;
  }
}

// Helper class to define wave layer properties
class WaveLayer {
  final double amplitude;
  final double frequency;
  final double speed;
  final double phase;
  final double opacity;
  final double strokeWidth;
  final double colorShift;
  final double verticalOffset;

  WaveLayer({
    required this.amplitude,
    required this.frequency,
    required this.speed,
    required this.phase,
    required this.opacity,
    required this.strokeWidth,
    required this.colorShift,
    required this.verticalOffset,
  });
}

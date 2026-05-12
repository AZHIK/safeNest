import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

/// Audio Recording Service
///
/// Handles audio recording functionality for evidence collection.
/// Uses flutter_sound for cross-platform audio recording and playback.
class AudioRecordingService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _currentRecordingPath;

  /// Check if recording is in progress
  bool get isRecording => _isRecording;

  /// Get current recording path
  String? get currentRecordingPath => _currentRecordingPath;

  /// Initialize the recorder
  Future<void> initialize() async {
    try {
      await _recorder.closeRecorder();
    } catch (e) {
      // Ignore if not open
    }
    await _recorder.openRecorder();
  }

  /// Check if recording permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Request recording permission
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Start recording audio
  ///
  /// Returns the path where the recording will be saved
  Future<String> startRecording() async {
    if (_isRecording) {
      throw Exception('Recording is already in progress');
    }

    // Check permission
    if (!await hasPermission()) {
      final granted = await requestPermission();
      if (!granted) {
        throw Exception('Microphone permission not granted');
      }
    }

    // Ensure recorder is initialized
    await initialize();

    // Get temporary directory for recording
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${directory.path}/recording_$timestamp.wav';

    // Start recording without specifying codec (let flutter_sound auto-detect)
    await _recorder.startRecorder(toFile: path);
    _isRecording = true;
    _currentRecordingPath = path;

    return path;
  }

  /// Stop recording and return the file path
  Future<String> stopRecording() async {
    if (!_isRecording) {
      throw Exception('No recording in progress');
    }

    final path = await _recorder.stopRecorder();
    _isRecording = false;
    _currentRecordingPath = null;

    if (path == null) {
      throw Exception('Failed to stop recording');
    }

    return path;
  }

  /// Cancel current recording
  Future<void> cancelRecording() async {
    if (!_isRecording) {
      return;
    }

    await _recorder.stopRecorder();
    _isRecording = false;

    // Delete the recording file if it exists
    if (_currentRecordingPath != null) {
      final file = File(_currentRecordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    _currentRecordingPath = null;
  }

  /// Get recording duration in seconds
  /// Note: This is a placeholder - actual duration tracking would need
  /// to be implemented with a timer during recording
  Duration getRecordingDuration(DateTime startTime) {
    return DateTime.now().difference(startTime);
  }

  /// Dispose resources
  void dispose() {
    _recorder.closeRecorder();
  }
}

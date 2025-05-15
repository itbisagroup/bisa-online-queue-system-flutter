import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';

class AudioPlayerWav {
  Timer? _timer;
  Queue<String> _playlist = Queue<String>();
  bool _isPlaying = false;

  Future<void> play(String assetPath) async {
    if (_isPlaying) {
      // Tambahkan ke antrian jika audio sedang diputar
      _playlist.addLast(assetPath);
      return;
    }

    _isPlaying = true;

    // Load the audio file from assets
    final byteData = await rootBundle.load(assetPath);
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/temp_audio.wav');
    await tempFile.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    // Convert file path to UTF-16 for Win32 API
    final pathPtr = TEXT(tempFile.path);

    // Open the audio file
    final openResult = mciSendString(
        TEXT('open "${tempFile.path}" type mpegvideo alias wav'),
        nullptr,
        0,
        0);
    if (openResult != 0) {
      free(pathPtr);
      _isPlaying = false;
      return;
    }

    // Get the length of the audio file
    final lengthBuffer = malloc.allocate<Utf16>(32);
    final lengthResult =
        mciSendString(TEXT('status wav length'), lengthBuffer, 32, 0);
    if (lengthResult != 0) {

      malloc.free(lengthBuffer);
      free(pathPtr);
      _isPlaying = false;
      return;
    }

    final length = int.parse(lengthBuffer.cast<Utf16>().toDartString());
    malloc.free(lengthBuffer);

    // Play the audio file
    final playResult = mciSendString(TEXT('play wav'), nullptr, 0, 0);
    if (playResult != 0) {

      free(pathPtr);
      _isPlaying = false;
      return;
    }

    // Set a timer to stop the audio after the duration has elapsed
    _timer = Timer(Duration(milliseconds: length), () async {
      await stop();
      _isPlaying = false;
      if (_playlist.isNotEmpty) {
        // Play next audio in the playlist
        play(_playlist.removeFirst());
      }
    });

    // Free the allocated memory
    free(pathPtr);
  }

  Future<void> stop() async {
    _timer?.cancel();
    mciSendString(TEXT('stop wav'), nullptr, 0, 0);
    mciSendString(TEXT('close wav'), nullptr, 0, 0);
  }

  Future<void> playPlaylist(List<String> assetPaths) async {
    if (assetPaths.isEmpty) return;

    _playlist = Queue<String>.from(assetPaths);

    if (!_isPlaying) {
      // Start playing the first audio
      play(_playlist.removeFirst());
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart'; // Using the 'record' package
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';


// --- Data Model for a Single Note Item (Conceptual) ---
// In a real app, this would be more structured and saved to a database.
class NoteContent {
  String text;
  List<String> imagePaths;
  List<String> audioPaths;
  // You might add a Map<String, String> for structured measurements

  NoteContent({
    this.text = "",
    List<String>? imagePaths,
    List<String>? audioPaths,
  })  : this.imagePaths = imagePaths ?? [],
        this.audioPaths = audioPaths ?? [];
}


class NoteScreen extends StatefulWidget {
  const NoteScreen({Key? key}) : super(key: key);

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final _noteTextController = TextEditingController();
  final _measurementFocusNode = FocusNode(); // To focus text field after button press

  NoteContent _currentNote = NoteContent();

  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder(); // From 'record' package
  AudioPlayer _audioPlayer = AudioPlayer(); // From 'audioplayers'
  bool _isRecording = false;
  String? _currentRecordingPath;


  // --- Measurement Shortcut Buttons ---
  final List<String> _measurementShortcuts = [
    "Length:", "Bust:", "Waist:", "Hips:", "Shoulder:", "Sleeve Length:",
    "Armhole:", "Neck:", "Cuff:", "Inseam:", "Rise:", "Thigh:"
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer(); // Initialize here
    // Pre-populate with a date or client name if coming from a list
    // _noteTextController.text = "Measurement for Client X - ${DateFormat.yMMMd().format(DateTime.now())}\n\n";
  }


  @override
  void dispose() {
    _noteTextController.dispose();
    _measurementFocusNode.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // --- Permission Helper ---
  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }

  // --- Image Handling ---
  Future<void> _pickImage(ImageSource source) async {
    if (!await _requestPermission(source == ImageSource.camera ? Permission.camera : Permission.photos)) {
      _showSnackBar("Permission denied for ${source == ImageSource.camera ? 'camera' : 'gallery'}.");
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _currentNote.imagePaths.add(pickedFile.path);
        });
      }
    } catch (e) {
      _showSnackBar("Error picking image: $e");
    }
  }


  // --- Audio Handling ---
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (!await _requestPermission(Permission.microphone)) {
      _showSnackBar("Microphone permission denied.");

      return;
    }
    if (await _audioRecorder.hasPermission()) { // Redundant check, but good practice
      try {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        // Check platform for encoder, m4a (AAC) is good for iOS/Android
        final AudioEncoder encoder = Platform.isIOS ? AudioEncoder.aacLc : AudioEncoder.aacLc;

        await _audioRecorder.start(RecordConfig(encoder: encoder), path: path);


        setState(() {
          _isRecording = true;
          _currentRecordingPath = path;
        });
        _showSnackBar("Recording started...");
      } catch (e) {
        _showSnackBar("Error starting recording: $e");
        print("Recording error: $e");
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        if (path != null) {
          _currentNote.audioPaths.add(path);
          _showSnackBar("Recording saved: ${path.split('/').last}");
        }
        _currentRecordingPath = null;
      });
    } catch (e) {
      _showSnackBar("Error stopping recording: $e");
    }
  }

  Future<void> _playAudio(String path) async {
    try {
      await _audioPlayer.play(DeviceFileSource(path));
      _showSnackBar("Playing audio...");
    } catch (e) {
      _showSnackBar("Error playing audio: $e");
    }
  }

  // --- Text & Measurement Shortcuts ---
  void _addMeasurementShortcut(String shortcut) {
    final currentText = _noteTextController.text;
    final selection = _noteTextController.selection;
    // Add a new line if not already on one, or if text is not empty
    final prefix = (currentText.isEmpty || currentText.endsWith('\n\n') || currentText.endsWith('\n')) ? "" : "\n";
    final newText = "$prefix$shortcut ";

    // Insert the shortcut text
    _noteTextController.value = TextEditingValue(
      text: currentText.substring(0, selection.start) + newText + currentText.substring(selection.end),
      selection: TextSelection.fromPosition(
        TextPosition(offset: selection.start + newText.length),
      ),
    );
    // Focus back on the text field to allow immediate typing of the value
    FocusScope.of(context).requestFocus(_measurementFocusNode);
  }


  void _saveNote() {
    // In a real app, you'd save _currentNote to a database (SQLite, Firebase, etc.)
    // or a local file.
    // For this example, we'll just print it.
    _currentNote.text = _noteTextController.text;
    print("--- Note Saved ---");
    print("Text: ${_currentNote.text}");
    print("Images: ${_currentNote.imagePaths.join(', ')}");
    print("Audio: ${_currentNote.audioPaths.join(', ')}");
    _showSnackBar("Note content (see console). Implement actual saving!");
    // Potentially navigate back or clear the form
    // Navigator.pop(context);
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Measurement Note"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveNote,
            tooltip: "Save Note",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Measurement Shortcut Buttons ---
            _buildMeasurementShortcuts(),
            const SizedBox(height: 16),

            // --- Text Input Area ---
            TextFormField(
              controller: _noteTextController,
              focusNode: _measurementFocusNode,
              decoration: InputDecoration(
                hintText: "Enter measurements, notes, client details...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),

            // --- Action Buttons (Image & Audio) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt),
                  label: Text("Camera"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.photo_library),
                  label: Text("Gallery"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _toggleRecording,
              icon: Icon(_isRecording ? Icons.stop_circle_outlined : Icons.mic),
              label: Text(_isRecording ? "Stop Recording" : "Record Audio"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? Colors.redAccent : Colors.orangeAccent,
              ),
            ),
            if (_isRecording && _currentRecordingPath != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("Recording: ${_currentRecordingPath!.split('/').last}...", style: TextStyle(color: Colors.red)),
              ),


            const SizedBox(height: 20),
            Divider(),

            // --- Display Captured Images ---
            if (_currentNote.imagePaths.isNotEmpty) ...[
              Text("Captured Images:", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildImageGrid(),
              const SizedBox(height: 16),
            ],


            // --- Display Recorded Audio ---
            if (_currentNote.audioPaths.isNotEmpty) ...[
              Text("Recorded Audio:", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildAudioList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementShortcuts() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _measurementShortcuts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final shortcut = _measurementShortcuts[index];
          return ActionChip(
            avatar: Icon(Icons.add_circle_outline, size: 18, color: Colors.white),
            label: Text(shortcut.replaceAll(":", ""), style: TextStyle(color: Colors.white)),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            onPressed: () => _addMeasurementShortcut(shortcut),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 2,
          );
        },
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // To disable GridView's own scrolling
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _currentNote.imagePaths.length,
      itemBuilder: (context, index) {
        final imagePath = _currentNote.imagePaths[index];
        return Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300)
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            IconButton(
              icon: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close, color: Colors.white, size: 16)),
              onPressed: () {
                setState(() {
                  _currentNote.imagePaths.removeAt(index);
                  // Optionally, delete the file from storage here if it's permanent
                });
              },
              tooltip: "Remove Image",
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAudioList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _currentNote.audioPaths.length,
      itemBuilder: (context, index) {
        final audioPath = _currentNote.audioPaths[index];
        final fileName = audioPath.split('/').last; // Get a displayable name
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Icon(Icons.audiotrack, color: Theme.of(context).colorScheme.primary),
            title: Text(fileName, style: TextStyle(fontSize: 14)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.play_circle_fill, color: Colors.green),
                  onPressed: () => _playAudio(audioPath),
                  tooltip: "Play Audio",
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () {
                    setState(() {
                      _currentNote.audioPaths.removeAt(index);
                      // Optionally, delete the file from storage
                      // File(audioPath).delete();
                    });
                  },
                  tooltip: "Delete Audio",
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
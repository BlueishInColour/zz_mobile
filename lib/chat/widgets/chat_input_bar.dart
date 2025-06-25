// chat_input_bar.dart
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart'; // For camera/gallery

class ChatInputBar extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback onRecordAudio;
  final Function(String imageSource) onSendVisual; // 'camera' or 'gallery'

  const ChatInputBar({
    Key? key,
    required this.onSendMessage,
    required this.onRecordAudio,
    required this.onSendVisual,
  }) : super(key: key);

  @override
  _ChatInputBarState createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;
  // final ImagePicker _picker = ImagePicker(); // Initialize if using image_picker

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (mounted) {
        setState(() {
          _isComposing = _textController.text.isNotEmpty;
        });
      }
    });
  }

  void _handleSend() {
    if (_isComposing) {
      widget.onSendMessage(_textController.text);
      _textController.clear();
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Photo Library'),
                  onTap: () {
                    widget.onSendVisual('gallery');
                    Navigator.of(context).pop();
                    // _pickImage(ImageSource.gallery);
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Camera'),
                onTap: () {
                  widget.onSendVisual('camera');
                  Navigator.of(context).pop();
                  // _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Example image picker (requires image_picker package)
  // Future<void> _pickImage(ImageSource source) async {
  //   try {
  //     final XFile? pickedFile = await _picker.pickImage(source: source);
  //     if (pickedFile != null) {
  //       widget.onSendVisual(pickedFile.path); // Or handle the XFile directly
  //     }
  //   } catch (e) {
  //     print("Image picker error: $e");
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 1.0,
            color: Colors.black.withOpacity(0.05),
          )
        ],
      ),
      child: SafeArea( // Ensures padding for notches, etc.
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end, // Align items to bottom if text field grows
          children: <Widget>[
            // Camera Icon
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined),
              onPressed: () => _showImageSourceActionSheet(context),
              tooltip: "Attach image or video",
              color: Theme.of(context).iconTheme.color,
            ),
            const SizedBox(width: 4),

            // Text Field
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2.0), // Minimal padding
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor, // Or a slightly different shade
                    borderRadius: BorderRadius.circular(22.0),
                    border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.5)
                ),
                child: TextField(
                  controller: _textController,
                  minLines: 1,
                  maxLines: 5, // Allow multi-line input
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none, // Remove default border
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // Adjust padding inside text field
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 4),

            // Record Audio or Send Button
            _isComposing
                ? IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
              onPressed: _handleSend,
              tooltip: "Send message",
            )
                : IconButton(
              icon: Icon(Icons.mic_none_outlined, color: Theme.of(context).iconTheme.color),
              onPressed: widget.onRecordAudio,
              tooltip: "Record voice note",
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
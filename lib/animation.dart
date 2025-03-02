import 'package:flutter/material.dart';
import 'package:super_context_menu/super_context_menu.dart';




class HomeScreenAnimation extends StatelessWidget {
  final List<String> messages = [
    "This is a sample message.",
    "Try long-pressing on me!",
    "Smooth animations are key.",
    "Telegram-like context menu.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Context Menu'),
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return MessageTile(
            message: messages[index],
          );
        },
      ),
    );
  }
}

class MessageTile extends StatefulWidget {
  final String message;

  const MessageTile({Key? key, required this.message}) : super(key: key);

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  OverlayEntry? _overlayEntry;

  void _showContextMenu(BuildContext context, Offset position) {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMenuItem(context, "Reply", Icons.reply),
                _buildMenuItem(context, "Forward", Icons.forward),
                _buildMenuItem(context, "Delete", Icons.delete),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildMenuItem(BuildContext context, String text, IconData icon) {
    return InkWell(
      onTap: () {
        _hideContextMenu();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$text selected')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.black54),
            SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _hideContextMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        _showContextMenu(context, details.globalPosition);
      },
      onTap: _hideContextMenu,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          widget.message,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

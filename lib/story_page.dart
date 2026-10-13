
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StoryOverlay extends StatefulWidget {
  final Widget child;
  const StoryOverlay({super.key, required this.child});

  @override
  State<StoryOverlay> createState() => _StoryOverlayState();
}

class _StoryOverlayState extends State<StoryOverlay>
    with WidgetsBindingObserver {
  WebViewController? _controller;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    if (_open) {
      setState(() => _open = false);
      return true;
    }
    return false;
  }

  void _openStory() {
    if (_controller == null) {
      final c = WebViewController();
      c.setJavaScriptMode(JavaScriptMode.unrestricted);
      c.setBackgroundColor(const Color(0xFF07091F));
      c.loadFlutterAsset('story.html');
      _controller = c;
    }
    setState(() => _open = true);
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return Stack(
      children: [
        Positioned.fill(child: widget.child),
        if (_open && _controller != null)
          Positioned.fill(
            child: Material(
              color: const Color(0xFF07091F),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.only(top: pad.top, bottom: pad.bottom),
                      child: WebViewWidget(controller: _controller!),
                    ),
                  ),
                  Positioned(
                    top: pad.top + 8,
                    right: 12,
                    child: _roundButton(
                      Icons.close,
                      () => setState(() => _open = false),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Positioned(
            top: pad.top + 12,
            left: 12,
            child: _roundButton(Icons.auto_stories, _openStory),
          ),
      ],
    );
  }
}

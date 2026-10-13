import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MyluckApp());

const purple = Color(0xFF9D4EDD);

class MyluckApp extends StatelessWidget {
  const MyluckApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Myluck',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(seedColor: purple, brightness: Brightness.dark),
          scaffoldBackgroundColor: Colors.black,
          useMaterial3: true,
        ),
        home: const HomeShell(),
      );
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [FeedScreen(), DiscoverScreen(), ShareScreen(), InboxScreen(), ProfileScreen()];
    return Scaffold(
      body: IndexedStack(index: tab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        backgroundColor: const Color(0xFF111111),
        indicatorColor: purple.withValues(alpha: .25),
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), label: 'Discover'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline, size: 28), label: 'Share'),
          NavigationDestination(icon: Icon(Icons.inbox_outlined), label: 'Inbox'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class DemoVideo {
  const DemoVideo(this.caption, this.creator, this.url, this.likes);
  final String caption, creator, url, likes;
}

const demoVideos = <DemoVideo>[
  DemoVideo('Welcome to Myluck ✨ Your next favourite video is here.', '@myluck_demo',
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', '1.2K'),
  DemoVideo('Discover something new. Demo clip — replace with licensed content.', '@creator_one',
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', '856'),
];

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final controller = PageController();
  final Set<int> liked = {};
  @override
  void dispose() { controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Stack(children: [
    PageView.builder(
      controller: controller,
      scrollDirection: Axis.vertical,
      itemCount: demoVideos.length,
      itemBuilder: (_, i) => VideoCard(video: demoVideos[i], liked: liked.contains(i),
        onLike: () => setState(() { if (!liked.add(i)) liked.remove(i); })),
    ),
    const SafeArea(child: Padding(
      padding: EdgeInsets.all(18),
      child: Row(children: [
        Text('myluck', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
        Spacer(),
        Text('For You', style: TextStyle(fontWeight: FontWeight.bold)),
      ]),
    )),
  ]);
}

class VideoCard extends StatefulWidget {
  const VideoCard({super.key, required this.video, required this.liked, required this.onLike});
  final DemoVideo video;
  final bool liked;
  final VoidCallback onLike;
  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late final VideoPlayerController video;
  bool ready = false, failed = false;

  @override
  void initState() {
    super.initState();
    video = VideoPlayerController.networkUrl(Uri.parse(widget.video.url))
      ..initialize().then((_) {
        if (!mounted) return;
        video.setLooping(true);
        video.setVolume(0);
        video.play();
        setState(() => ready = true);
      }).catchError((_) { if (mounted) setState(() => failed = true); });
  }
  @override
  void dispose() { video.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      if (!ready) return;
      setState(() { video.value.isPlaying ? video.pause() : video.play(); });
    },
    child: Stack(fit: StackFit.expand, children: [
      if (ready)
        FittedBox(fit: BoxFit.cover, child: SizedBox(
          width: video.value.size.width, height: video.value.size.height, child: VideoPlayer(video)))
      else
        Container(color: const Color(0xFF17121F), alignment: Alignment.center,
          child: Text(failed ? 'Demo video unavailable' : 'Loading Myluck…')),
      const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Colors.black54, Colors.transparent, Colors.black87], stops: [0, .35, 1]))),
      Positioned(left: 18, right: 82, bottom: 28, child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.video.creator, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8), Text(widget.video.caption),
          const SizedBox(height: 8), const Text('♫ Original audio · Myluck demo'),
        ])),
      Positioned(right: 12, bottom: 80, child: Column(children: [
        const CircleAvatar(backgroundColor: purple, child: Icon(Icons.person)),
        const SizedBox(height: 16),
        IconButton(onPressed: widget.onLike, iconSize: 32,
          color: widget.liked ? Colors.pinkAccent : Colors.white,
          icon: Icon(widget.liked ? Icons.favorite : Icons.favorite_border)),
        Text(widget.liked ? 'Liked' : widget.video.likes),
        const SizedBox(height: 18), const Icon(Icons.mode_comment_outlined, size: 30),
        const Text('Comment'), const SizedBox(height: 18),
        IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sharing will be connected in a later version.'))),
          icon: const Icon(Icons.share_outlined, size: 28)),
        const Text('Share'),
      ])),
    ]),
  );
}

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Discover')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Explore videos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Open supported videos from other platforms. Myluck does not download or re-host them.'),
      const SizedBox(height: 18),
      _ExternalCard(title: 'YouTube', subtitle: 'Open YouTube or a shared video link',
        icon: Icons.smart_display, color: Colors.red,
        url: 'https://www.youtube.com/shorts/'),
      _ExternalCard(title: 'Instagram', subtitle: 'Open Instagram Reels or a shared link',
        icon: Icons.camera_alt_outlined, color: Colors.pink,
        url: 'https://www.instagram.com/reels/'),
      _ExternalCard(title: 'TikTok', subtitle: 'Open TikTok or a shared video link',
        icon: Icons.music_video, color: Colors.white,
        url: 'https://www.tiktok.com/'),
      const SizedBox(height: 16),
      const Text('Note: These buttons open the platforms. Automatic importing, embedded playback, and API access depend on each platform’s current rules and permissions.',
        style: TextStyle(color: Colors.white70)),
    ]),
  );
}

class _ExternalCard extends StatelessWidget {
  const _ExternalCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.url});
  final String title, subtitle, url;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon, color: color, size: 32),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.open_in_new),
      onTap: () async {
        final uri = Uri.parse(url);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open link.')));
        }
      },
    ),
  );
}

class ShareScreen extends StatelessWidget {
  const ShareScreen({super.key});
  @override
  Widget build(BuildContext context) => const _PlaceholderPage(
    title: 'Share to Myluck',
    message: 'Video uploads are planned for the next version. We will add safe upload limits and storage.',
    icon: Icons.add_circle_outline);
}
class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});
  @override
  Widget build(BuildContext context) => const _PlaceholderPage(
    title: 'Inbox', message: 'Messages and notifications will be added after accounts are connected.',
    icon: Icons.inbox_outlined);
}
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const _PlaceholderPage(
    title: 'Your profile', message: 'Sign-in, profile editing, and your uploaded videos will be added in the next phase.',
    icon: Icons.person_outline);
}
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title, required this.message, required this.icon});
  final String title, message;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Myluck')),
    body: Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(
      mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 64, color: purple), const SizedBox(height: 18),
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12), Text(message, textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70)),
      ]))),
  );
}

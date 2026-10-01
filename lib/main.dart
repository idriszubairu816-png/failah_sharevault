import 'package:flutter/material.dart';

void main() {
  runApp(const FailahShareVaultApp());
}

class FailahShareVaultApp extends StatelessWidget {
  const FailahShareVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FAILAH ShareVault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ShareVaultHomeScreen(),
    );
  }
}

class ShareVaultHomeScreen extends StatefulWidget {
  const ShareVaultHomeScreen({super.key});

  @override
  State<ShareVaultHomeScreen> createState() => _ShareVaultHomeScreenState();
}

class _ShareVaultHomeScreenState extends State<ShareVaultHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const CloudVaultDashboard(),
    const VideoPlayerHub(),
    const SecurityVaultScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAILAH ShareVault 1TB'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: '1TB Cloud',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill),
            label: 'Video Player',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Security',
          ),
        ],
      ),
    );
  }
}

// 1. Shafin 1TB Cloud Storage
class CloudVaultDashboard extends StatelessWidget {
  const CloudVaultDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: const [
                  Icon(Icons.cloud_done, size: 60, color: Colors.indigo),
                  SizedBox(height: 10),
                  Text(
                    '1TB Secure Cloud Storage',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Files saved here do not use your phone memory.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload File to Cloud'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Cloud Vault Files:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  leading: Icon(Icons.video_library, color: Colors.indigo),
                  title: Text('Project_Presentation.mp4'),
                  subtitle: Text('1.2 GB • Saved in Cloud'),
                ),
                ListTile(
                  leading: Icon(Icons.insert_drive_file, color: Colors.indigo),
                  title: Text('Company_Document.pdf'),
                  subtitle: Text('45 MB • Saved in Cloud'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 2. Shafin Built-in Video Player
class VideoPlayerHub extends StatelessWidget {
  const VideoPlayerHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 80,
                color: Colors.white54,
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Cloud Video Streamer',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Play your cloud-stored videos instantly without downloading to device storage.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// 3. Shafin Security
class SecurityVaultScreen extends StatelessWidget {
  const SecurityVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Security & Encryption',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.lock, color: Colors.green),
            title: Text('End-to-End Encryption'),
            subtitle: Text('Active and protecting your 1TB cloud data.'),
          ),
          ListTile(
            leading: Icon(Icons.shield, color: Colors.blue),
            title: Text('Zero Local Footprint'),
            subtitle: Text('Ensuring no temporary files touch your phone.'),
          ),
        ],
      ),
    );
  }
}

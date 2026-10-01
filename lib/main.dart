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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
      ),
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HybridTransferScreen(),
    const CloudVaultScreen(),
    const VideoPlayerScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_rounded),
            selectedIcon: Icon(Icons.swap_horiz, color: Color(0xFF6366F1)),
            label: 'P2P Transfer',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_outlined),
            selectedIcon: Icon(Icons.cloud, color: Color(0xFF6366F1)),
            label: '1TB Cloud',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle, color: Color(0xFF6366F1)),
            label: 'Player',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: Color(0xFF6366F1)),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HybridTransferScreen extends StatelessWidget {
  const HybridTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAILAH ShareVault (Offline P2P)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Offline Mode Active: Tura fayiloli baya buƙatar Data!',
                      style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _BigActionButton(
                    title: 'SEND',
                    subtitle: 'Tura zuwa na\'ura',
                    icon: Icons.upload_rounded,
                    color: Colors.orange,
                    onTap: () => _showP2PDialog(context, 'Binciken Na\'ura...', 'Ana ƙirƙirar Local Hotspot ba tare da Data ba...'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _BigActionButton(
                    title: 'RECEIVE',
                    subtitle: 'Karɓa daga na\'ura',
                    icon: Icons.download_rounded,
                    color: Colors.teal,
                    onTap: () => _showP2PDialog(context, 'Ana Jiran Mai Tura Fayil...', 'Sanya na\'urarka kusa...'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text('Zaɓi Rukunin Fayil (Local Files)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: const [
                  _CategoryCard(title: 'Apps & Games', icon: Icons.apps, count: '14 Apps', color: Colors.blue),
                  _CategoryCard(title: 'Videos', icon: Icons.videocam, count: '32 Videos', color: Colors.purple),
                  _CategoryCard(title: 'Photos', icon: Icons.photo_library, count: '240 Photos', color: Colors.pink),
                  _CategoryCard(title: 'Documents', icon: Icons.folder, count: '18 Files', color: Colors.amber),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showP2PDialog(BuildContext context, String title, String subtitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF6366F1)),
            const SizedBox(height: 20),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kasa'),
          ),
        ],
      ),
    );
  }
}

class _BigActionButton extends StatelessWidget {
  const _BigActionButton({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.title, required this.icon, required this.count, required this.color});
  final String title;
  final IconData icon;
  final String count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(count, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}

class CloudVaultScreen extends StatelessWidget {
  const CloudVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1TB Cloud Vault (Online)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF818CF8)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ajiyar Cloud ɗinka', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 5),
                  Text('1.0 TB Total Space', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  LinearProgressIndicator(value: 0.12, backgroundColor: Colors.white24, color: Colors.orangeAccent),
                  SizedBox(height: 8),
                  Text('An yi amfani da: 120 GB (Yana buƙatar Data)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerScreen extends StatelessWidget {
  const VideoPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Player', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_fill, size: 70, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Kalli Bidiyo Ba Tare da Cika Wayarka ba', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Updates', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: const [
          UserAccountsDrawerHeader(
            accountName: Text('IDRISAN FAILAH'),
            accountEmail: Text('failah.sharevault@app.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Color(0xFF6366F1)),
            ),
            decoration: BoxDecoration(color: Color(0xFF6366F1)),
          ),
          ListTile(
            leading: Icon(Icons.system_update, color: Color(0xFF6366F1)),
            title: Text('Bincika Sabon Update'),
            subtitle: Text('Yana buƙatar Data'),
          ),
          ListTile(
            leading: Icon(Icons.security),
            title: Text('Tsaro da Sirrin Fayiloli (Encryption)'),
            subtitle: Text('AES-256 bit active'),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Game da Manhaja'),
            subtitle: Text('FAILAH ShareVault v1.2.0'),
          ),
        ],
      ),
    );
  }
}

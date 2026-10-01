import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const FailahShareVaultApp());
}

class FailahShareVaultApp extends StatefulWidget {
  const FailahShareVaultApp({super.key});

  @override
  State<FailahShareVaultApp> createState() => _FailahShareVaultAppState();
}

class _FailahShareVaultAppState extends State<FailahShareVaultApp> {
  bool _isDarkMode = false;

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FAILAH ShareVault',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
      ),
      home: MainDashboard(onThemeChanged: _toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key, required this.onThemeChanged, required this.isDarkMode});
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const HybridTransferScreen(),
    const CloudVaultScreen(),
    const PhoneFilesExplorerScreen(),
    SettingsScreen(onThemeChanged: widget.onThemeChanged, isDarkMode: widget.isDarkMode),
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
            icon: Icon(Icons.folder_open),
            selectedIcon: Icon(Icons.folder, color: Color(0xFF6366F1)),
            label: 'Phone Files',
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

class PhoneFilesExplorerScreen extends StatefulWidget {
  const PhoneFilesExplorerScreen({super.key});

  @override
  State<PhoneFilesExplorerScreen> createState() => _PhoneFilesExplorerScreenState();
}

class _PhoneFilesExplorerScreenState extends State<PhoneFilesExplorerScreen> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;
  String _currentPath = '';

  @override
  void initState() {
    super.initState();
    _requestStoragePermissionAndLoadFiles();
  }

  Future<void> _requestStoragePermissionAndLoadFiles() async {
    PermissionStatus status;
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        status = PermissionStatus.granted;
      } else {
        status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
      }
    } else {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      _loadDirectoryFiles();
    } else {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission is required to view phone files!')),
      );
    }
  }

  Future<void> _loadDirectoryFiles([String? customPath]) async {
    setState(() => _isLoading = true);
    try {
      Directory? directory;
      if (customPath != null) {
        directory = Directory(customPath);
      } else {
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/');
        } else {
          directory = await getApplicationDocumentsDirectory();
        }
      }

      if (await directory.exists()) {
        final list = directory.listSync();
        setState(() {
          _currentPath = directory!.path;
          _files = list;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      final appDir = await getApplicationDocumentsDirectory();
      setState(() {
        _currentPath = appDir.path;
        _files = appDir.listSync();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Files Explorer', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadDirectoryFiles(_currentPath),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey.withOpacity(0.1),
            width: double.infinity,
            child: Text(
              'Path: $_currentPath',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_currentPath != '/storage/emulated/0/' && Platform.isAndroid)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Go Up / Back to Root'),
                onPressed: () {
                  final parent = Directory(_currentPath).parent;
                  _loadDirectoryFiles(parent.path);
                },
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                : _files.isEmpty
                    ? const Center(child: Text('No files found or access restricted.'))
                    : ListView.builder(
                        itemCount: _files.length,
                        itemBuilder: (context, index) {
                          final entity = _files[index];
                          final name = entity.path.split('/').last;
                          final isDirectory = entity is Directory;

                          return ListTile(
                            leading: Icon(
                              isDirectory ? Icons.folder : Icons.insert_drive_file,
                              color: isDirectory ? Colors.amber : const Color(0xFF6366F1),
                            ),
                            title: Text(name, style: const TextStyle(fontSize: 14)),
                            subtitle: Text(isDirectory ? 'Folder' : 'File', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            onTap: () {
                              if (isDirectory) {
                                _loadDirectoryFiles(entity.path);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Selected file: $name')),
                                );
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class HybridTransferScreen extends StatefulWidget {
  const HybridTransferScreen({super.key});

  @override
  State<HybridTransferScreen> createState() => _HybridTransferScreenState();
}

class _HybridTransferScreenState extends State<HybridTransferScreen> {
  bool _isTransferring = false;
  String _transferStatus = 'Ready for high-speed offline sharing';

  void _startTransfer(String actionType) {
    setState(() {
      _isTransferring = true;
      _transferStatus = actionType == 'send' ? 'Connecting to nearby receiver...' : 'Waiting for incoming sender...';
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isTransferring = false;
        _transferStatus = 'Transfer completed successfully!';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Files transferred successfully!')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAILAH ShareVault (P2P)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _transferStatus,
                      style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            if (_isTransferring) ...[
              const SizedBox(height: 15),
              const LinearProgressIndicator(value: null, color: Color(0xFF6366F1)),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                    icon: const Icon(Icons.upload_rounded),
                    label: const Text('SEND'),
                    onPressed: () => _startTransfer('send'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('RECEIVE'),
                    onPressed: () => _startTransfer('receive'),
                  ),
                ),
              ],
            ),
          ],
        ),
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
        title: const Text('1TB Cloud Vault', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('1.0 TB Cloud Storage Connected')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.onThemeChanged, required this.isDarkMode});
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: SwitchListTile(
        title: const Text('Dark Theme'),
        value: isDarkMode,
        onChanged: onThemeChanged,
      ),
    );
  }
}

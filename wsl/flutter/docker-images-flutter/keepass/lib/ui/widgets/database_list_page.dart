import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import 'entry_list_page.dart';
import 'settings_page.dart';

class DatabaseListPage extends StatefulWidget {
  const DatabaseListPage({super.key});

  @override
  State<DatabaseListPage> createState() => _DatabaseListPageState();
}

class _DatabaseListPageState extends State<DatabaseListPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Try to automatically open the default database when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized) {
        _hasInitialized = true;
        _tryAutoOpenDatabase();
      }
    });
  }

  Future<void> _tryAutoOpenDatabase() async {
    try {
      final appState = Provider.of<AppStateProvider>(context, listen: false);

      // Get the default database path
      final defaultPath = await appState.getDefaultDatabasePath();

      // Check if database exists
      if (await appState.databaseExists(defaultPath)) {
        // Database exists, show password prompt
        if (mounted) {
          _showPasswordDialog(defaultPath, isNew: false);
        }
      } else {
        // Database doesn't exist, create it
        if (mounted) {
          _showPasswordDialog(defaultPath, isNew: true);
        }
      }
    } catch (e) {
      // Continue with normal flow if auto-initialization fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KeePass Flutter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Password Manager',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const Text(
              'Welcome to your secure password manager',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _createOrOpenDatabase,
              icon: const Icon(Icons.lock_open),
              label: const Text('Access Passwords'),
            ),
            const SizedBox(height: 20),
            const Text(
              'All your passwords are securely encrypted and stored locally on your device.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _createOrOpenDatabase() async {
    try {
      final appState = Provider.of<AppStateProvider>(context, listen: false);

      // Get the default database path
      final defaultPath = await appState.getDefaultDatabasePath();

      // Check if database exists
      if (await appState.databaseExists(defaultPath)) {
        // Database exists, show password prompt
        _showPasswordDialog(defaultPath, isNew: false);
      } else {
        // Database doesn't exist, create it
        _showPasswordDialog(defaultPath, isNew: true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _showPasswordDialog(String path, {required bool isNew}) {
    _passwordController.clear();

    // Ensure we're still mounted before showing dialog
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isNew ? 'Create Master Password' : 'Enter Master Password',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter a strong master password to protect your passwords.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Master Password',
                  border: OutlineInputBorder(),
                ),
              ),
              if (!isNew) const SizedBox(height: 10),
              if (!isNew)
                const Text(
                  'Forgot your password? You will need to reset your database.',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_passwordController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  if (isNew) {
                    _createDatabase(path, _passwordController.text);
                  } else {
                    _openDatabaseWithPassword(path, _passwordController.text);
                  }
                }
              },
              child: Text(isNew ? 'Create' : 'Unlock'),
            ),
          ],
        );
      },
    );
  }

  void _createDatabase(String path, String password) async {
    try {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      final success = await appState.createDatabase(path, password);

      if (success) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EntryListPage()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create database')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _openDatabaseWithPassword(String path, String password) async {
    try {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      final success = await appState.openDatabase(path, password);

      if (success) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EntryListPage()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to unlock database. Check password.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }
}

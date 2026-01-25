import 'package:flutter/material.dart';
// Removed unused imports
// import 'package:provider/provider.dart';
// import '../../providers/app_state_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _autoLockTimeout = 300; // 5 minutes
  bool _enableBiometricAuth = false;
  bool _enableCloudSync = false;
  String _cloudProvider = 'None';
  final TextEditingController _masterPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Change Master Password'),
                      subtitle: const Text('Update your database master password'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _changeMasterPassword,
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Auto-lock Timeout'),
                      subtitle: Text(_formatDuration(_autoLockTimeout)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _changeAutoLockTimeout,
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Biometric Authentication'),
                      subtitle: const Text('Use fingerprint or face unlock'),
                      value: _enableBiometricAuth,
                      onChanged: (value) {
                        setState(() {
                          _enableBiometricAuth = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sync Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Cloud Sync'),
                      subtitle: const Text('Sync your database with cloud storage'),
                      value: _enableCloudSync,
                      onChanged: (value) {
                        setState(() {
                          _enableCloudSync = value;
                        });
                      },
                    ),
                    if (_enableCloudSync) ...[
                      const Divider(),
                      ListTile(
                        title: const Text('Cloud Provider'),
                        subtitle: Text(_cloudProvider),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: _selectCloudProvider,
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Sync Now'),
                        subtitle: const Text('Manually sync your database'),
                        onTap: _syncNow,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'About',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const ListTile(
                      title: Text('App Version'),
                      subtitle: Text('1.0.0'),
                    ),
                    const Divider(),
                    const ListTile(
                      title: Text('License'),
                      subtitle: Text('GNU General Public License v3.0'),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Privacy Policy'),
                      onTap: _viewPrivacyPolicy,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds seconds';
    } else if (seconds < 3600) {
      return '${seconds ~/ 60} minutes';
    } else {
      return '${seconds ~/ 3600} hours';
    }
  }

  void _changeMasterPassword() {
    _masterPasswordController.clear();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Master Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _masterPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Master Password',
                  border: OutlineInputBorder(),
                ),
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
                if (_masterPasswordController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  // In a real implementation, we would update the master password
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Master password updated')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _changeAutoLockTimeout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Auto-lock Timeout'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('30 seconds'),
                onTap: () {
                  setState(() {
                    _autoLockTimeout = 30;
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('1 minute'),
                onTap: () {
                  setState(() {
                    _autoLockTimeout = 60;
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('5 minutes'),
                onTap: () {
                  setState(() {
                    _autoLockTimeout = 300;
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('15 minutes'),
                onTap: () {
                  setState(() {
                    _autoLockTimeout = 900;
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('30 minutes'),
                onTap: () {
                  setState(() {
                    _autoLockTimeout = 1800;
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('1 hour'),
                onTap: () {
                  setState(() {
                    _autoLockTimeout = 3600;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectCloudProvider() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Cloud Provider'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('None'),
                onTap: () {
                  setState(() {
                    _cloudProvider = 'None';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Dropbox'),
                onTap: () {
                  setState(() {
                    _cloudProvider = 'Dropbox';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Google Drive'),
                onTap: () {
                  setState(() {
                    _cloudProvider = 'Google Drive';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('OneDrive'),
                onTap: () {
                  setState(() {
                    _cloudProvider = 'OneDrive';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('WebDAV'),
                onTap: () {
                  setState(() {
                    _cloudProvider = 'WebDAV';
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _syncNow() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Syncing with cloud storage...')),
    );
    // In a real implementation, we would trigger cloud sync
  }

  void _viewPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Viewing privacy policy...')),
    );
    // In a real implementation, we would show the privacy policy
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../models/database_entry.dart';
import 'entry_edit_page.dart';
import 'database_list_page.dart';
import 'settings_page.dart';
import '../../services/search_service.dart';

class EntryListPage extends StatefulWidget {
  const EntryListPage({super.key});

  @override
  State<EntryListPage> createState() => _EntryListPageState();
}

class _EntryListPageState extends State<EntryListPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedTags = [];
  late AppStateProvider _appState;

  @override
  void initState() {
    super.initState();
    _appState = Provider.of<AppStateProvider>(context, listen: false);
    _appState.loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Password Entries'),
            actions: [
              IconButton(
                icon: const Icon(Icons.lock),
                onPressed: _lockDatabase,
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _goToSettings,
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search entries...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    appState.updateSearchQuery(value);
                  },
                ),
              ),
              if (appState.filteredEntries.isNotEmpty)
                _buildTagFilter(appState),
              Expanded(
                child: appState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : appState.errorMessage != null
                    ? Center(child: Text('Error: ${appState.errorMessage}'))
                    : _buildEntryList(appState),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _addNewEntry,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildTagFilter(AppStateProvider appState) {
    final allTags = SearchService.getAllTags(appState.entries);

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: allTags.map((tag) {
          final isSelected = _selectedTags.contains(tag);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                  appState.updateSelectedTags(_selectedTags);
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEntryList(AppStateProvider appState) {
    if (appState.filteredEntries.isEmpty) {
      return const Center(child: Text('No entries found'));
    }

    return ListView.builder(
      itemCount: appState.filteredEntries.length,
      itemBuilder: (context, index) {
        final entry = appState.filteredEntries[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            title: Text(entry.title),
            subtitle: Text('${entry.username} • ${entry.url}'),
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => _copyToClipboard(entry.password),
            ),
            onTap: () => _editEntry(entry),
          ),
        );
      },
    );
  }

  void _addNewEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntryEditPage(
          entry: null, // null indicates new entry
        ),
      ),
    ).then((value) {
      if (value == true) {
        _appState.loadEntries(); // Refresh the list
      }
    });
  }

  void _editEntry(DatabaseEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EntryEditPage(entry: entry)),
    ).then((value) {
      if (value == true) {
        _appState.loadEntries(); // Refresh the list
      }
    });
  }

  void _copyToClipboard(String text) {
    // In a real implementation, we would use Clipboard.setData
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password copied to clipboard')),
    );
  }

  void _lockDatabase() async {
    await _appState.lockDatabase();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DatabaseListPage()),
      );
    }
  }

  void _goToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }
}

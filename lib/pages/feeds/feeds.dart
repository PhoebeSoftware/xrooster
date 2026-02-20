import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xrooster/api/myx.dart';
import 'package:xrooster/models/feed.dart';
import 'package:xrooster/pages/SearchTextField.dart';

class FeedsPage extends StatefulWidget {
  const FeedsPage({super.key, required this.api, required this.onFeedSelected});

  final MyxApi api;
  final VoidCallback onFeedSelected;

  SharedPreferencesAsync get prefs => api.prefs;

  @override
  State<FeedsPage> createState() => FeedsState();
}

class FeedsState extends State<FeedsPage> {
  List<(String, Feed)> _allItems = [];
  List<(String, Feed)> _filteredItems = [];

  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _loadFeeds() async {
    final settings = await widget.api.getSettings();

    setState(() {
      _allItems = settings.feeds.entries
          .map((entry) => (entry.key, entry.value))
          .toList();
      _filteredItems = _allItems;
      _loading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _allItems.where((item) {
        return item.$2.name.contains(query);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFeeds();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          SearchTextField(controller: _searchController),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _loading = true;
                });
                _loadFeeds();
              },
              child: _loading
                  ? ListView(
                      children: [
                        SizedBox(height: 200),
                        Center(child: CircularProgressIndicator()),
                      ],
                    )
                  : _filteredItems.isEmpty
                  ? ListView(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(
                            child: Text(
                              'No attendees found',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      itemCount: _filteredItems.length,
                      separatorBuilder: (context, index) => SizedBox(height: 4.0),
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final feedId = item.$1;
                        final feed = item.$2;

                        return ListTile(
                          title: Text(feed.name),
                          subtitle: Text("Feed ID $feedId"),
                          onTap: () => {},
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  debugPrint('Remove feed button pressed');
                                },
                              ),
                              TextButton(
                                child: Text("Select"),
                                onPressed: () {
                                  widget.prefs.setString("selectedFeed", feedId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${feed.name} ($feedId) selected'),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                  widget.onFeedSelected();
                                },
                              ),
                            ],
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          tileColor: theme.hoverColor,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

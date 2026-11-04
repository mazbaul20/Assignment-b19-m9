import 'package:flutter/material.dart';

class SearchContactBottomSheet extends StatefulWidget {
  final Future<void> Function(String query) onSearchChanged;
  final VoidCallback onClear;

  const SearchContactBottomSheet({
    super.key,
    required this.onSearchChanged,
    required this.onClear,
  });

  @override
  State<SearchContactBottomSheet> createState() => _SearchContactBottomSheetState();
}

class _SearchContactBottomSheetState extends State<SearchContactBottomSheet> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Search Contact by Name",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'Enter name...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  widget.onClear();
                },
              ),
            ),
            onChanged: (value) {
              widget.onSearchChanged(value.trim());
            },
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Done"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
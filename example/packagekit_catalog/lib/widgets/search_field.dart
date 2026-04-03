import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/packages_provider.dart';

class PackageSearchField extends ConsumerStatefulWidget {
  const PackageSearchField({super.key});

  @override
  ConsumerState<PackageSearchField> createState() => _PackageSearchFieldState();
}

class _PackageSearchFieldState extends ConsumerState<PackageSearchField> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchQueryProvider.notifier).state = value.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Search packages...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon:
            _controller.text.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                )
                : null,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: _onChanged,
    );
  }
}

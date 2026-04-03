import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/packages_provider.dart';
import '../widgets/package_list.dart';
import '../widgets/search_field.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text('Catalog', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(width: 24),
              const Expanded(child: PackageSearchField()),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child:
              query.isEmpty
                  ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Search for packages by name'),
                      ],
                    ),
                  )
                  : searchResults.when(
                    data:
                        (packages) =>
                            packages.isEmpty
                                ? Center(child: Text('No results for "$query"'))
                                : PackageListView(packages: packages),
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
        ),
      ],
    );
  }
}

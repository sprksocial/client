import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Discover'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Search videos, users, music',
                prefixIcon: const Icon(Ionicons.search_outline),
                suffixIcon: const Icon(Ionicons.scan_outline),
                onChanged: (value) {
                  // Handle search
                },
              ),
            ),
            
            // Trending hashtags
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Text(
                    'Trending Hashtags',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            // Trending hashtags horizontal scroll
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '#trending${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Content grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(2),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2/3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: 30,
                itemBuilder: (context, index) {
                  return Container(
                    color: index % 3 == 0 
                        ? CupertinoColors.systemPurple.withOpacity(0.7)
                        : index % 3 == 1 
                          ? CupertinoColors.systemIndigo.withOpacity(0.7)
                          : CupertinoColors.systemBlue.withOpacity(0.7),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Center(
                          child: Icon(
                            Ionicons.play_outline,
                            color: CupertinoColors.white.withOpacity(0.7),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Row(
                            children: [
                              const Icon(
                                Ionicons.play_outline,
                                color: CupertinoColors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(index + 1) * 10}K',
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
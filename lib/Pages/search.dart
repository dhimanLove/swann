import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../Pages/details.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _searchResults = []);
    } else {
      _searchSupabase(query);
    }
  }

  Future<void> _searchSupabase(String query) async {
    setState(() => _isSearching = true);
    try {
      final response = await supabase
          .from('interest')
          .select()
          .ilike('description', '%$query%')
          .order('created_at', ascending: false);

      setState(() {
        _searchResults = response.cast<Map<String, dynamic>>();
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  Widget buildShimmerCard(double height) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[600]!,
      highlightColor: Colors.grey[500]!,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[600],
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final crossAxisCount = MediaQuery.of(context).size.width > 600 ? 4 : 2;

    return CupertinoPageScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          "Search",
          style: TextStyle(
            fontFamily: "Chillax",
            fontSize: 25,
            color: isDark ? Colors.white : Colors.grey[800],
            fontWeight: FontWeight.w300,
          ),
        ),
        backgroundColor:
            isDark
                ? Colors.grey[900]?.withOpacity(0.9)
                : Colors.white.withOpacity(0.9),
        border: null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CupertinoSearchTextField(
                  controller: _searchController,
                  placeholder: "Hukum mere aaka....",
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        _searchResults = [];
                        _isSearching = false;
                      });
                    } else {
                      _searchSupabase(value);
                    }
                  },

                  // Balanced inner padding (not oversized)
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 12,
                  ),

                  // Space for search icon
                  prefixInsets: const EdgeInsetsDirectional.fromSTEB(
                    12,
                    0,
                    8,
                    0,
                  ),

                  // Space for clear (X) button
                  suffixInsets: const EdgeInsetsDirectional.fromSTEB(
                    8,
                    0,
                    12,
                    0,
                  ),

                  backgroundColor: Colors.transparent,

                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Expanded(
              child:
                  _isSearching
                      ? MasonryGridView.count(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: 10,
                        itemBuilder:
                            (context, index) =>
                                buildShimmerCard((index % 2 == 0) ? 200 : 280),
                      )
                      : _searchResults.isEmpty &&
                          _searchController.text.isNotEmpty
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                          ),
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text(
                            "No results found",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          TextButton(
                            onPressed: () => _searchController.clear(),
                            child: const Text("Clear Search"),
                          ),
                        ],
                      )
                      : MasonryGridView.count(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final item = _searchResults[index];
                          final imageUrl = item['image_url'];
                          final description = item['description'] ?? "";

                          return GestureDetector(
                            onTap: () {
                              Get.to(
                                () => DetailPage(
                                  imgUrl: imageUrl,
                                  desc: description,
                                ),
                                transition: Transition.cupertino,
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder:
                                        (context, url) => buildShimmerCard(
                                          (index % 2 == 0) ? 200 : 280,
                                        ),
                                    errorWidget:
                                        (context, url, error) => Container(
                                          height: (index % 2 == 0) ? 200 : 280,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.broken_image),
                                        ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black54,
                                          ],
                                        ),
                                      ),
                                      child: Text(
                                        description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

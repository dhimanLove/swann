import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pinterest/components/pptheme.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPage extends StatefulWidget {
  final String imgUrl;
  final String desc;

  const DetailPage({super.key, required this.imgUrl, required this.desc});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with TickerProviderStateMixin {
  bool isLiked = false;
  bool isExpanded = false;
  static const int maxWords = 20;
  Size? imageSize;
  bool imageSizeLoaded = false;

  late final AnimationController _likeController;
  late final Animation<double> _likeScale;

  @override
  void initState() {
    super.initState();
    _loadLikeStatus();
    _loadImageSize();

    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _likeScale = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  Future<void> _loadImageSize() async {
    try {
      final imageProvider = CachedNetworkImageProvider(widget.imgUrl);
      final ImageStream stream = imageProvider.resolve(
        ImageConfiguration.empty,
      );

      stream.addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          if (mounted && !imageSizeLoaded) {
            setState(() {
              imageSize = Size(
                info.image.width.toDouble(),
                info.image.height.toDouble(),
              );
              imageSizeLoaded = true;
            });
          }
        }),
      );
    } catch (e) {
      debugPrint('Error loading image size: $e');
    }
  }

  Future<void> _loadLikeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final liked = prefs.getBool('liked_${widget.imgUrl}') ?? false;
    if (mounted) {
      setState(() {
        isLiked = liked;
      });
    }
  }
  //image description

  Future<void> _shareImageWithCaption() async {
    if (kIsWeb) {
      // Fallback: just share text + raw URL on web
      Share.share('${widget.desc}\n${widget.imgUrl}');
      return;
    }

    // Download image to temp file
    final response = await http.get(Uri.parse(widget.imgUrl));
    if (response.statusCode != 200) {
      _showAlert("Error", "Failed to load image for sharing.");
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/share_image.jpg');
    await file.writeAsBytes(response.bodyBytes);

    // Share image + text
    await Share.shareXFiles([XFile(file.path)], text: widget.desc);

    // Optional: clean up
    await file.delete();
  }

  Future<void> _saveLikeStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('liked_${widget.imgUrl}', value);
  }

  Future<void> saveImgToGallery(String url) async {
    if (kIsWeb) {
      if (mounted) {
        _showAlert("Not Supported", "Image download is not supported on Web.");
      }
      return;
    }

    final status = await Permission.storage.request();
    if (!mounted) return;

    if (!status.isGranted) {
      _showAlert(
        "Permission Required",
        "Storage permission is needed to save images.",
      );
      return;
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (!mounted) return;

      if (response.statusCode != 200) {
        _showAlert("Error", "Failed to download image.");
        return;
      }

      final dir = Directory('/storage/emulated/0/Pictures/Swan');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final fileName = "swan_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final file = File("${dir.path}/$fileName");
      await file.writeAsBytes(response.bodyBytes);

      if (!mounted) return;
      _showAlert("Success", "Image saved to gallery.");
    } catch (e) {
      if (mounted) {
        _showAlert("Error", e.toString());
      }
    }
  }

  void _showAlert(String title, String content) {
    if (!mounted) return;

    showCupertinoDialog(
      context: context,
      builder:
          (_) => CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              CupertinoDialogAction(
                child: const Text("OK"),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
    );
  }

  String _getTruncatedText(String text) {
    final words = text.split(' ');
    if (words.length <= maxWords) return text;
    return '${words.take(maxWords).join(' ')}...';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate proper aspect ratio based on loaded image size
    double aspectRatio = 1.0;
    if (imageSize != null && imageSize!.width > 0) {
      aspectRatio = imageSize!.width / imageSize!.height;
    }

    return Theme(
      data:
          MediaQuery.of(context).platformBrightness == Brightness.dark
              ? PpTheme.darkTheme
              : PpTheme.lightTheme,
      child: CupertinoPageScaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: theme.colorScheme.surface.withOpacity(0.7),
          heroTag: 'detailNavBar',
          transitionBetweenRoutes: false,
          enableBackgroundFilterBlur: true,
          middle: Text(
            "Details",
            style: TextStyle(
              fontFamily: "Chillax",
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: isDark ? Colors.white : Colors.grey.shade800,
            ),
          ),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
              CupertinoIcons.back,
              size: 28,
              color: theme.iconTheme.color,
            ),
            onPressed: () => Get.back(),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  CupertinoIcons.share,
                  size: 26,
                  color: theme.iconTheme.color,
                ),
                onPressed: () async {
                  // 1️⃣ First: Try native image+text share (best UX)
                  try {
                    await _shareImageWithCaption();
                  } catch (e) {
                    // 2️⃣ Fallback: Just share text + clean placeholder (no raw Supabase URL)
                    final fallbackText =
                        widget.desc.length > 100
                            ? '${widget.desc.substring(0, 97)}...'
                            : widget.desc;
                    await Share.share(
                      '$fallbackText\n\nShared via SWAN',
                      subject: 'Check out this pin!',
                    );
                  }
                },
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  CupertinoIcons.down_arrow,
                  size: 26,
                  color: theme.iconTheme.color,
                ),
                onPressed: () => saveImgToGallery(widget.imgUrl),
              ),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Use LayoutBuilder to get available width
                LayoutBuilder(
                  builder: (context, constraints) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: AspectRatio(
                        aspectRatio: aspectRatio,
                        child: GestureDetector(
                          onDoubleTap: () async {
                            setState(() => isLiked = !isLiked);
                            await _saveLikeStatus(isLiked);
                            _likeController.forward(from: 0);
                          },
                          child: CachedNetworkImage(
                            imageUrl: widget.imgUrl,
                            fit: BoxFit.cover,
                            placeholder:
                                (_, __) => Container(
                                  color: theme.cardColor,
                                  child: const Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                                ),
                            errorWidget:
                                (_, __, ___) => Container(
                                  color: theme.cardColor,
                                  child: const Center(
                                    child: Icon(
                                      CupertinoIcons.exclamationmark_triangle,
                                      size: 40,
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              isExpanded
                                  ? widget.desc
                                  : _getTruncatedText(widget.desc),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          if (widget.desc.split(' ').length > maxWords)
                            GestureDetector(
                              onTap:
                                  () =>
                                      setState(() => isExpanded = !isExpanded),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  isExpanded ? "See less" : "See more",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () async {
                        setState(() => isLiked = !isLiked);
                        await _saveLikeStatus(isLiked);
                        _likeController.forward(from: 0);
                      },
                      child: AnimatedBuilder(
                        animation: _likeController,
                        builder:
                            (_, __) => Transform.scale(
                              scale: _likeScale.value,
                              child: Icon(
                                isLiked
                                    ? CupertinoIcons.heart_solid
                                    : CupertinoIcons.heart,
                                size: 28,
                                color:
                                    isLiked
                                        ? CupertinoColors.systemRed
                                        : theme.iconTheme.color,
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

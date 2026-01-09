import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'pptheme.dart';

void showCupertinoSearchPopup() {
  final List<String> items = [
    'Love Hampers',
    'Birthday Gifts',
    'Anniversary Boxes',
    'Personalized Hampers',
    'Diwali Specials',
    'Cute DIYs',
    'Custom Orders',
  ];

  String searchQuery = '';

  Get.bottomSheet(
    CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      child: StatefulBuilder(
        builder: (context, setState) {
          final textStyle = PpTheme.darkTheme.textTheme.bodyMedium;

          return SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Search Gifts',
                        style: textStyle?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.black,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(
                          CupertinoIcons.clear_circled_solid,
                          color: CupertinoColors.systemGrey,
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CupertinoSearchTextField(
                    onChanged:
                        (value) =>
                            setState(() => searchQuery = value.toLowerCase()),
                    placeholder: 'Search products...',
                    backgroundColor: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(10),
                    prefixInsets: const EdgeInsetsDirectional.only(start: 12),
                    prefixIcon: const Icon(
                      CupertinoIcons.search,
                      color: Color(0xFFE60023),
                    ),
                    style: textStyle,
                  ),
                ),

                const SizedBox(height: 10),

                // Filtered list
                Expanded(
                  child: CupertinoListSection.insetGrouped(
                    backgroundColor: const Color(0xFFF2F2F7),
                    children:
                        items
                            .where(
                              (item) =>
                                  item.toLowerCase().contains(searchQuery),
                            )
                            .map(
                              (filteredItem) => CupertinoListTile(
                                title: Text(filteredItem, style: textStyle),
                                trailing: const Icon(
                                  CupertinoIcons.chevron_right,
                                  size: 20,
                                  color: Color(0xFF767676),
                                ),
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  Get.back(result: filteredItem);
                                },
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
    isScrollControlled: true,
    barrierColor: CupertinoColors.black.withOpacity(0.4),
  );
}

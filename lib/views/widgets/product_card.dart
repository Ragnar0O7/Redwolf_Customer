import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/product.dart';
import '../../utils/responsive_helper.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;

  void _navigateToDetail() {
    context.push('/product/${widget.product.id}');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobileOrTablet = isMobile || isTablet;

    // For mobile and tablet: use 12px padding as per design spec
    // Reduced padding to eliminate remaining overflow
    // For desktop: keep existing padding (web interface is perfect)
    final contentPadding = isMobileOrTablet
        ? const EdgeInsets.fromLTRB(12, 10, 12, 8)
        : const EdgeInsets.all(16);

    return InkWell(
      onTap: _navigateToDetail,
      borderRadius: BorderRadius.zero,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// IMAGE - With zoom animation on hover (container border preserved)
            Expanded(
              flex: isMobileOrTablet
                  ? 2
                  : 3, // Reduced flex for mobile/tablet to give more space to content
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(),
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => setState(() => _isHovered = false),
                  child: AnimatedScale(
                    scale: _isHovered ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Image.network(
                      widget.product.imageUrl,
                      fit: BoxFit
                          .cover, // Cover to make image larger and balance with product info
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[100],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.grey,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            /// CONTENT - Exact padding matching design specifications for mobile/tablet
            /// Design spec: 12px overall padding, 12px above tag, 12px between tag-title,
            /// 16px between title-view details, 12px below view details
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                padding: contentPadding,
                constraints: const BoxConstraints(minHeight: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Category tag - matching design specs
                    // 12px padding above tag is handled by container's top padding
                    if (widget.product.category.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.product.category,
                          style: TextStyle(
                            fontSize: 10, // 10px font size (design spec)
                            color: Colors.grey[700],
                            fontWeight:
                                FontWeight.w400, // 400 weight (design spec)
                            height:
                                1.4, // 14px line height (14/10 = 1.4) (design spec)
                          ),
                        ),
                      ),

                    // 12 PX spacing between tag and title (design spec)
                    // Reduced to 8px for mobile/tablet to prevent overflow
                    if (widget.product.category.isNotEmpty)
                      SizedBox(height: isMobileOrTablet ? 8 : 12),

                    // Product name - flexible for multi-line text based on screen size
                    // Wrap in SizedBox to ensure it uses full available width for proper text wrapping
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        widget.product.name,
                        maxLines: 2, // Allow 2 lines for longer names
                        overflow: TextOverflow.ellipsis,
                        softWrap:
                            true, // Enable text wrapping to adapt to different phone widths
                        style: TextStyle(
                          fontSize: isMobileOrTablet
                              ? 14
                              : 16, // 14px for mobile/tablet (design spec), 16px for desktop
                          fontWeight:
                              FontWeight.w500, // 500 weight (design spec)
                          height: isMobileOrTablet
                              ? 1.428
                              : 1.5, // 20px line height for mobile/tablet (20/14 = 1.428) (design spec)
                          color: Colors.black,
                        ),
                      ),
                    ),

                    // 16 PX spacing between title and view details (design spec)
                    // Reduced to 8px for mobile/tablet to prevent overflow in constrained grid
                    SizedBox(height: isMobileOrTablet ? 8 : 16),

                    // View details CTA - matching design specs
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'view details',
                          style: TextStyle(
                            color: const Color(0xFFDC2626),
                            fontWeight:
                                FontWeight.w600, // 600 weight (design spec)
                            fontSize: isMobileOrTablet
                                ? 12
                                : 14, // 12px for mobile/tablet (design spec)
                            height:
                                1.5, // 18px line height (18/12 = 1.5) (design spec)
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward,
                          size: isMobileOrTablet ? 12 : 14, // Match font size
                          color: const Color(0xFFDC2626),
                        ),
                      ],
                    ),
                    // 12px padding below view details is handled by container's bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

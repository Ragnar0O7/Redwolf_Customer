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
              flex: 3, // Increased flex to make image larger
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
                      fit: BoxFit.cover, // Cover to make image larger and balance with product info
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

            /// CONTENT - Exact padding matching design specifications
            Expanded(
              flex: 1, // Fixed flex to make content section smaller
              child: Container(
                padding: const EdgeInsets.all(12), // 12 PX padding on all sides
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category tag - matching design specs
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
                            fontSize: 10, // 10px font size
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w400, // 400 weight
                            height: 1.4, // 14px line height (14/10 = 1.4)
                          ),
                        ),
                      ),

                    // 12 PX spacing between tag and title
                    if (widget.product.category.isNotEmpty)
                      const SizedBox(height: 12),

                    // Product name - matching design specs
                    Flexible(
                      child: Text(
                        widget.product.name,
                        maxLines: 2, // Allow 2 lines for longer names
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14, // 14px font size
                          fontWeight: FontWeight.w500, // 500 weight
                          height: 1.428, // 20px line height (20/14 = 1.428)
                          color: Colors.black,
                        ),
                      ),
                    ),

                    // 16 PX spacing between title and view details
                    const SizedBox(height: 16),

                    // View details CTA - matching design specs
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'view details',
                          style: const TextStyle(
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.w600, // 600 weight
                            fontSize: 12, // 12px font size
                            height: 1.5, // 18px line height (18/12 = 1.5)
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward,
                          size: 12, // Match font size
                          color: const Color(0xFFDC2626),
                        ),
                      ],
                    ),
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

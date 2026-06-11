import 'dart:async';
import '../common_imports.dart';
import '../mock/mock_database.dart';

class OrderingWindowBanner extends StatefulWidget {
  final EdgeInsetsGeometry? margin;
  const OrderingWindowBanner({super.key, this.margin});

  @override
  State<OrderingWindowBanner> createState() => _OrderingWindowBannerState();
}

class _OrderingWindowBannerState extends State<OrderingWindowBanner> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Check timing state periodically
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = MockDatabase();
    final isOpen = db.isOrderingOpen();
    final isCombine = db.isCombineOption;
    final isDark = context.isDarkMode;

    Color bannerColor;
    Color borderColor;
    Color textColor;
    IconData icon;
    String statusTitle;
    String statusSubtitle;

    if (!isOpen) {
      bannerColor = AppTheme.error.withValues(alpha: isDark ? 0.12 : 0.08);
      borderColor = AppTheme.error.withValues(alpha: 0.3);
      textColor = AppTheme.error;
      icon = Icons.lock_clock_rounded;
      statusTitle = "Ordering is Closed";
      statusSubtitle = "Hours: ${db.orderStartTime} to ${db.orderCutoffTime}";
    } else {
      if (isCombine) {
        bannerColor = AppTheme.primary.withValues(alpha: isDark ? 0.12 : 0.08);
        borderColor = AppTheme.primary.withValues(alpha: 0.3);
        textColor = AppTheme.primary;
        icon = Icons.group_work_rounded;
        statusTitle = "Combined Ordering Active";
        statusSubtitle = "Orders will aggregate. Cutoff at ${db.orderCutoffTime}";
      } else {
        bannerColor = AppTheme.success.withValues(alpha: isDark ? 0.12 : 0.08);
        borderColor = AppTheme.success.withValues(alpha: 0.3);
        textColor = AppTheme.success;
        icon = Icons.electric_bolt_rounded;
        statusTitle = "Single Ordering Active";
        statusSubtitle = "Orders processed instantly. Cutoff at ${db.orderCutoffTime}";
      }
    }

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: GlassContainer(
        borderRadius: 20,
        color: bannerColor,
        borderColor: borderColor,
        borderWidth: 1.5,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: textColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    statusTitle,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    statusSubtitle,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white60 : Colors.black87,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import '../common_imports.dart';

class BentoCard extends StatelessWidget {
  final Widget? child;
  final String? title;
  final String? subtitle;
  final String? value;
  final Widget? icon;
  final List<Color>? gradient;
  final Color? color;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry padding;

  const BentoCard({
    super.key,
    this.child,
    this.title,
    this.subtitle,
    this.value,
    this.icon,
    this.gradient,
    this.color,
    this.onTap,
    this.height,
    this.width,
    this.padding = const EdgeInsets.all(20.0),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    Widget content =
        child ??
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: icon,
                  ),
                ] else
                  const SizedBox.shrink(),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (value != null) ...[
                  Text(
                    value!,
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (title != null)
                  Text(
                    title!,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ],
        );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color:
              color ??
              (gradient != null
                  ? null
                  : (isDark ? const Color(0xFF1E293B) : Colors.white)),
          gradient: gradient != null
              ? LinearGradient(
                  colors: gradient!,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}

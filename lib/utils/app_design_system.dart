import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/utils/responsive.dart';

/// Max width for main content on large screens (web/desktop) for readable layout.
const double kMaxContentWidth = 1280;

/// Professional design system: consistent cards, loading, empty states, and layout.
class AppDesignSystem {
  AppDesignSystem._();

  /// Wraps content with max width and centers on large screens. Use for page body.
  static Widget constrainedContent({
    required BuildContext context,
    required Widget child,
    double maxWidth = kMaxContentWidth,
    EdgeInsets? padding,
  }) {
    final pad = padding ?? ResponsiveUtils.getResponsivePadding(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: pad, child: child),
      ),
    );
  }

  /// Standard card decoration using theme colors.
  static BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(
        ResponsiveUtils.getResponsiveBorderRadius(
          context,
          mobile: 12,
          tablet: 14,
          desktop: 16,
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: ResponsiveUtils.isMobile(context) ? 8 : 12,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Section title style (e.g. "Book a Ride", "Earnings").
  static TextStyle sectionTitle(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: ResponsiveUtils.getResponsiveFontSize(
        context,
        mobile: 18,
        tablet: 20,
        desktop: 22,
      ),
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );
  }

  /// Body / description text.
  static TextStyle bodyText(BuildContext context, {Color? color}) {
    return GoogleFonts.poppins(
      fontSize: ResponsiveUtils.getResponsiveFontSize(
        context,
        mobile: 14,
        tablet: 15,
        desktop: 16,
      ),
      color: color ?? Mycolors.gray,
    );
  }

  /// Caption / hint text.
  static TextStyle caption(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: ResponsiveUtils.getResponsiveFontSize(
        context,
        mobile: 12,
        tablet: 13,
        desktop: 14,
      ),
      color: Colors.grey[600],
    );
  }
}

/// Centered loading indicator with theme color.
class AppLoading extends StatelessWidget {
  final String? message;

  const AppLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: ResponsiveUtils.getResponsiveIconSize(
              context,
              mobile: 36,
              tablet: 40,
              desktop: 44,
            ),
            height: ResponsiveUtils.getResponsiveIconSize(
              context,
              mobile: 36,
              tablet: 40,
              desktop: 44,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Mycolors.basecolor),
            ),
          ),
          if (message != null && message!.isNotEmpty) ...[
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
            ),
            Text(
              message!,
              style: AppDesignSystem.bodyText(context),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty state placeholder (no data, no rides, etc.).
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const AppEmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(
                ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 24,
                  tablet: 28,
                  desktop: 32,
                ),
              ),
              decoration: BoxDecoration(
                color: Mycolors.basecolor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: ResponsiveUtils.getResponsiveIconSize(
                  context,
                  mobile: 48,
                  tablet: 56,
                  desktop: 64,
                ),
                color: Mycolors.basecolor.withOpacity(0.7),
              ),
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            Text(
              title,
              style: AppDesignSystem.sectionTitle(context),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                ),
              ),
              Text(
                subtitle!,
                style: AppDesignSystem.bodyText(context),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 20,
                  tablet: 24,
                  desktop: 28,
                ),
              ),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state with optional retry.
class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: ResponsiveUtils.getResponsiveIconSize(
                context,
                mobile: 48,
                tablet: 56,
                desktop: 64,
              ),
              color: Mycolors.red.withOpacity(0.8),
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            Text(
              message,
              style: AppDesignSystem.bodyText(context),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: Text(
                  'Try again',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Mycolors.basecolor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

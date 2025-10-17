import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/utils/responsive.dart';

/// Mixin to add responsive capabilities to any widget
mixin ResponsiveHelper {
  // Responsive Padding
  EdgeInsets responsivePadding(BuildContext context) =>
      ResponsiveUtils.getResponsivePadding(context);

  EdgeInsets responsiveHPadding(BuildContext context) =>
      ResponsiveUtils.getResponsiveHorizontalPadding(context);

  EdgeInsets responsiveVPadding(BuildContext context) =>
      ResponsiveUtils.getResponsiveVerticalPadding(context);

  // Responsive Spacing
  double spacing(BuildContext context, double mobile, [double? tablet, double? desktop]) =>
      ResponsiveUtils.getResponsiveSpacing(
        context,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );

  // Responsive Font Sizes
  double fontSize(BuildContext context, double mobile, [double? tablet, double? desktop]) =>
      ResponsiveUtils.getResponsiveFontSize(
        context,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );

  // Responsive Icon Sizes
  double iconSize(BuildContext context, double mobile, [double? tablet, double? desktop]) =>
      ResponsiveUtils.getResponsiveIconSize(
        context,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );

  // Responsive Border Radius
  double borderRadius(BuildContext context, double mobile, [double? tablet, double? desktop]) =>
      ResponsiveUtils.getResponsiveBorderRadius(
        context,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );

  // Quick Text Styles with Responsive Sizes
  TextStyle titleStyle(BuildContext context, {Color? color}) => GoogleFonts.poppins(
        fontSize: fontSize(context, 24, 28, 32),
        fontWeight: FontWeight.bold,
        color: color ?? Colors.black,
      );

  TextStyle subtitleStyle(BuildContext context, {Color? color}) => GoogleFonts.poppins(
        fontSize: fontSize(context, 16, 18, 20),
        color: color ?? Colors.grey[600],
      );

  TextStyle bodyStyle(BuildContext context, {Color? color}) => GoogleFonts.poppins(
        fontSize: fontSize(context, 14, 15, 16),
        color: color ?? Colors.black87,
      );

  TextStyle captionStyle(BuildContext context, {Color? color}) => GoogleFonts.poppins(
        fontSize: fontSize(context, 12, 13, 14),
        color: color ?? Colors.grey[500],
      );

  TextStyle buttonStyle(BuildContext context, {Color? color}) => GoogleFonts.poppins(
        fontSize: fontSize(context, 16, 17, 18),
        fontWeight: FontWeight.w600,
        color: color ?? Colors.white,
      );

  // Screen Size Checks
  bool isMobile(BuildContext context) => ResponsiveUtils.isMobile(context);
  bool isTablet(BuildContext context) => ResponsiveUtils.isTablet(context);
  bool isDesktop(BuildContext context) => ResponsiveUtils.isDesktop(context);
}

/// Extension on BuildContext for quick access to responsive values
extension ResponsiveContext on BuildContext {
  // Padding
  EdgeInsets get responsivePadding => ResponsiveUtils.getResponsivePadding(this);
  EdgeInsets get responsiveHPadding => ResponsiveUtils.getResponsiveHorizontalPadding(this);
  EdgeInsets get responsiveVPadding => ResponsiveUtils.getResponsiveVerticalPadding(this);

  // Screen checks
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);

  // Screen size
  double get screenWidth => ResponsiveUtils.screenWidth(this);
  double get screenHeight => ResponsiveUtils.screenHeight(this);

  // Grid columns
  int get gridColumns => ResponsiveUtils.getResponsiveGridColumns(this);

  // Quick spacing
  SizedBox heightBox(double mobile, [double? tablet, double? desktop]) => SizedBox(
        height: ResponsiveUtils.getResponsiveSpacing(
          this,
          mobile: mobile,
          tablet: tablet,
          desktop: desktop,
        ),
      );

  SizedBox widthBox(double mobile, [double? tablet, double? desktop]) => SizedBox(
        width: ResponsiveUtils.getResponsiveSpacing(
          this,
          mobile: mobile,
          tablet: tablet,
          desktop: desktop,
        ),
      );
}

/// Responsive Container Widget
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final BoxDecoration? decoration;
  final double? width;
  final double? height;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.decoration,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? context.responsivePadding,
      color: color,
      decoration: decoration,
      width: width,
      height: height,
      constraints: ResponsiveUtils.getResponsiveConstraints(context),
      child: child,
    );
  }
}

/// Responsive Card Widget
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final double? elevation;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: ResponsiveUtils.getResponsiveElevation(
        context,
        mobile: elevation ?? 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
        ),
      ),
      color: color,
      child: Padding(
        padding: padding ?? context.responsivePadding,
        child: child,
      ),
    );
  }
}

/// Responsive Button
class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isOutlined;

  const ResponsiveButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      mobile: 16,
      tablet: 17,
      desktop: 18,
    );

    final height = ResponsiveUtils.getResponsiveSpacing(
      context,
      mobile: 50,
      tablet: 55,
      desktop: 60,
    );

    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(
      context,
      mobile: 12,
      tablet: 14,
      desktop: 16,
    );

    if (isOutlined) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: icon != null ? Icon(icon, size: fontSize + 2) : const SizedBox.shrink(),
          label: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor,
            side: BorderSide(color: backgroundColor ?? Colors.grey),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: fontSize + 2) : const SizedBox.shrink(),
        label: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

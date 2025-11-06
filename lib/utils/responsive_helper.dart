import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getResponsiveWidth(BuildContext context, double mobileWidth, {double? tabletWidth, double? desktopWidth}) {
    if (isDesktop(context)) {
      return desktopWidth ?? tabletWidth ?? mobileWidth;
    } else if (isTablet(context)) {
      return tabletWidth ?? mobileWidth;
    }
    return mobileWidth;
  }

  static double getResponsiveHeight(BuildContext context, double mobileHeight, {double? tabletHeight, double? desktopHeight}) {
    if (isDesktop(context)) {
      return desktopHeight ?? tabletHeight ?? mobileHeight;
    } else if (isTablet(context)) {
      return tabletHeight ?? mobileHeight;
    }
    return mobileHeight;
  }

  static double getResponsiveFontSize(BuildContext context, double mobileSize, {double? tabletSize, double? desktopSize}) {
    if (isDesktop(context)) {
      return desktopSize ?? tabletSize ?? mobileSize;
    } else if (isTablet(context)) {
      return tabletSize ?? mobileSize;
    }
    return mobileSize;
  }

  static EdgeInsets getResponsivePadding(BuildContext context, EdgeInsets mobilePadding, {EdgeInsets? tabletPadding, EdgeInsets? desktopPadding}) {
    if (isDesktop(context)) {
      return desktopPadding ?? tabletPadding ?? mobilePadding;
    } else if (isTablet(context)) {
      return tabletPadding ?? mobilePadding;
    }
    return mobilePadding;
  }

  static double getResponsiveSpacing(BuildContext context, double mobileSpacing, {double? tabletSpacing, double? desktopSpacing}) {
    if (isDesktop(context)) {
      return desktopSpacing ?? tabletSpacing ?? mobileSpacing;
    } else if (isTablet(context)) {
      return tabletSpacing ?? mobileSpacing;
    }
    return mobileSpacing;
  }

  static int getResponsiveColumns(BuildContext context, int mobileColumns, {int? tabletColumns, int? desktopColumns}) {
    if (isDesktop(context)) {
      return desktopColumns ?? tabletColumns ?? mobileColumns;
    } else if (isTablet(context)) {
      return tabletColumns ?? mobileColumns;
    }
    return mobileColumns;
  }

  static double getAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width / size.height;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static double getSafeAreaTop(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static double getSafeAreaBottom(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  static double getAvailableHeight(BuildContext context) {
    return getScreenHeight(context) - getSafeAreaTop(context) - getSafeAreaBottom(context);
  }

  static double getAvailableWidth(BuildContext context) {
    return getScreenWidth(context);
  }

  // Responsive breakpoints for different screen sizes
  static double getBreakpointValue(BuildContext context, Map<String, double> breakpoints) {
    if (isDesktop(context)) {
      return breakpoints['desktop'] ?? breakpoints['tablet'] ?? breakpoints['mobile'] ?? 0;
    } else if (isTablet(context)) {
      return breakpoints['tablet'] ?? breakpoints['mobile'] ?? 0;
    }
    return breakpoints['mobile'] ?? 0;
  }

  // Get responsive icon size
  static double getIconSize(BuildContext context, double mobileSize, {double? tabletSize, double? desktopSize}) {
    return getResponsiveFontSize(context, mobileSize, tabletSize: tabletSize, desktopSize: desktopSize);
  }

  // Get responsive button height
  static double getButtonHeight(BuildContext context, double mobileHeight, {double? tabletHeight, double? desktopHeight}) {
    return getResponsiveHeight(context, mobileHeight, tabletHeight: tabletHeight, desktopHeight: desktopHeight);
  }

  // Get responsive card elevation
  static double getCardElevation(BuildContext context, double mobileElevation, {double? tabletElevation, double? desktopElevation}) {
    return getBreakpointValue(context, {
      'mobile': mobileElevation,
      'tablet': tabletElevation ?? mobileElevation,
      'desktop': desktopElevation ?? tabletElevation ?? mobileElevation,
    });
  }
}










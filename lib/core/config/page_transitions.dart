import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom page transitions for the app
/// Provides smooth, premium-feeling animations

Widget _wrapWithRouteSafeArea(Widget child) {
  return SafeArea(child: child);
}

/// Fade transition - gentle and elegant
class FadeTransitionPage<T> extends CustomTransitionPage<T> {
  FadeTransitionPage({required super.child, super.key, super.name})
    : super(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final wrappedChild = _wrapWithRouteSafeArea(child);
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: wrappedChild,
          );
        },
      );
}

/// Slide up transition - for modals and sheets
class SlideUpTransitionPage<T> extends CustomTransitionPage<T> {
  SlideUpTransitionPage({required super.child, super.key, super.name})
    : super(
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final wrappedChild = _wrapWithRouteSafeArea(child);
          final slideAnimation =
              Tween<Offset>(
                begin: const Offset(0, 0.15),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );

          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(opacity: fadeAnimation, child: wrappedChild),
          );
        },
      );
}

/// Slide from right transition - standard navigation
class SlideRightTransitionPage<T> extends CustomTransitionPage<T> {
  SlideRightTransitionPage({required super.child, super.key, super.name})
    : super(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final wrappedChild = _wrapWithRouteSafeArea(child);
          final slideAnimation =
              Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

          return SlideTransition(position: slideAnimation, child: wrappedChild);
        },
      );
}

/// Scale transition - for opening dialogs or detail screens
class ScaleTransitionPage<T> extends CustomTransitionPage<T> {
  ScaleTransitionPage({required super.child, super.key, super.name})
    : super(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final wrappedChild = _wrapWithRouteSafeArea(child);
          final scaleAnimation = Tween<double>(begin: 0.92, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );

          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );

          return ScaleTransition(
            scale: scaleAnimation,
            child: FadeTransition(opacity: fadeAnimation, child: wrappedChild),
          );
        },
      );
}

/// Zoom fade transition - premium feel
class ZoomFadeTransitionPage<T> extends CustomTransitionPage<T> {
  ZoomFadeTransitionPage({required super.child, super.key, super.name})
    : super(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final wrappedChild = _wrapWithRouteSafeArea(child);
          final scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutQuart),
          );

          final fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0, 0.65, curve: Curves.easeOut),
            ),
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(scale: scaleAnimation, child: wrappedChild),
          );
        },
      );
}

/// Shared axis transition - Material 3 style
class SharedAxisTransitionPage<T> extends CustomTransitionPage<T> {
  SharedAxisTransitionPage({
    required super.child,
    super.key,
    super.name,
    bool horizontal = true,
  }) : super(
         transitionDuration: const Duration(milliseconds: 350),
         reverseTransitionDuration: const Duration(milliseconds: 300),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final wrappedChild = _wrapWithRouteSafeArea(child);
           final slideAnimation =
               Tween<Offset>(
                 begin: Offset(horizontal ? 0.1 : 0, horizontal ? 0 : 0.1),
                 end: Offset.zero,
               ).animate(
                 CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
               );

           final fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
             CurvedAnimation(
               parent: animation,
               curve: const Interval(0, 0.6, curve: Curves.easeOut),
             ),
           );

           return SlideTransition(
             position: slideAnimation,
             child: FadeTransition(opacity: fadeAnimation, child: wrappedChild),
           );
         },
       );
}

/// No transition - instant change
class NoTransitionPage<T> extends CustomTransitionPage<T> {
  NoTransitionPage({required super.child, super.key, super.name})
    : super(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return _wrapWithRouteSafeArea(child);
        },
      );
}

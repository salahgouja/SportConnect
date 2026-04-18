import 'package:flutter/material.dart';

/// Reusable loading indicator widget
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.color, this.size});
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size ?? 40,
        height: size ?? 40,
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}

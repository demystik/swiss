import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiss/core/provider/loading_overlay_provider.dart';

class AppLoadingOverlay extends StatelessWidget {
  final Widget child;

  const AppLoadingOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LoadingOverlayProvider>(
      builder: (_, loading, _) {
        return Stack(
          children: [

            child,

            if (loading.isLoading)

              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),

          ],
        );
      },
    );
  }
}
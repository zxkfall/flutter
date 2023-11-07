import 'package:flutter/widgets.dart';

class PreviewPage extends StatelessWidget {

  final Image image;

  const PreviewPage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {

    ;
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(100),
          minScale: 0.2,
          maxScale: 10,
          child: image,
        ),
      ),
    );
  }
}
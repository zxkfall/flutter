import 'package:flutter/widgets.dart';

class PreviewPage extends StatelessWidget {

  final Image image;

  const PreviewPage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: image,
    );
  }
}
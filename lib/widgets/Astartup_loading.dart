import 'package:flutter/material.dart';

class StartupLoader extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const StartupLoader({
    Key? key,
    this.text = 'Easy Scoot',
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double imageSize = screenSize.width * 0.5;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipOval(
                child: Image.asset(
                  'images/loaderlogo.jpg',
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                width: imageSize + 20,
                height: imageSize + 20,
                child: CircularProgressIndicator(
                  color: const Color(0xFF74E5E7),
                  strokeWidth: 4,
                ),
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.02),
          Text(
            text,
            style: style ?? Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

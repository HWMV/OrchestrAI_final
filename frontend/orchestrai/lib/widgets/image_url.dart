import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageUrlWidget extends StatelessWidget {
  final String title;
  final String imageUrl;

  const ImageUrlWidget({
    Key? key,
    required this.title,
    required this.imageUrl,
  }) : super(key: key);

  Future<void> _launchURL() async {
    if (await canLaunch(imageUrl)) {
      await launch(imageUrl);
    } else {
      throw 'Could not launch $imageUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: _launchURL,
          child: Text(
            imageUrl,
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

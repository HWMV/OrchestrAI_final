import 'package:flutter/material.dart';
import 'package:orchestrai/widgets/image_url.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  ResultScreen({required this.result});

  @override
  Widget build(BuildContext context) {
    print('Received result: $result');
    print('Image URL: ${result['generated_image_url']}');
    final textOutput = result['raw_result'] ?? '';
    final imageUrl = result['generated_image_url'];
    final dallePrompt = result['dalle_prompt'];

    return Scaffold(
      appBar: AppBar(
        title: Text('협업 실행 결과', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF6050DC),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 왼쪽: 텍스트 결과물
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '결과:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(textOutput),
                      if (dallePrompt != null) ...[
                        SizedBox(height: 16),
                        Text(
                          'DALL-E 프롬프트:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(dallePrompt),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            // 오른쪽: 이미지 URL
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl != null)
                      ImageUrlWidget(
                        title: '생성된 이미지:',
                        imageUrl: imageUrl,
                      )
                    else
                      Text('생성된 이미지가 없습니다.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

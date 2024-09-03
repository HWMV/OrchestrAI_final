import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/crew_model.dart';

class AITeamPopup extends StatefulWidget {
  final VoidCallback onCreateTeam;

  AITeamPopup({required this.onCreateTeam});

  @override
  _AITeamPopupState createState() => _AITeamPopupState();
}

class _AITeamPopupState extends State<AITeamPopup> {
  final TextEditingController _teamNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(24),
      title: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              'AI 팀과 협업해보세요!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width * 0.6, // 화면 너비의 60%로 설정
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'AI 에이전트가 당신의 팀이 됩니다.\nNoCode로 누구나 쉽게 사용해보세요.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48, // 버튼과 동일한 높이 설정
                    child: TextField(
                      controller: _teamNameController,
                      decoration: InputDecoration(
                        hintText: '팀 이름을 입력해주세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero, // 모서리를 둥글지 않게 설정
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12), // 내부 패딩 조정
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  height: 48, // TextField와 동일한 높이 설정
                  child: ElevatedButton(
                    child: Text('AI팀 만들기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6050DC),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16), // 버튼 내부 패딩 조정
                    ),
                    onPressed: () {
                      if (_teamNameController.text.isNotEmpty) {
                        Provider.of<CrewModel>(context, listen: false)
                            .setTeamName(_teamNameController.text);
                        widget.onCreateTeam();
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('팀 이름을 입력해주세요.')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              child: Text('사용방법'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                ),
              ),
              onPressed: () {
                // 사용방법 버튼 기능 구현
              },
            ),
            TextButton(
              child: Text('데모 체험'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                ),
              ),
              onPressed: () {
                // 데모 체험 버튼 기능 구현
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }
}

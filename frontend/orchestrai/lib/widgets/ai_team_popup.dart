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
      title: Text('AI 팀 생성'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('AI 팀의 이름을 입력해주세요.'),
          SizedBox(height: 20),
          TextField(
            controller: _teamNameController,
            decoration: InputDecoration(
              hintText: '팀 이름',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('취소'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text('생성'),
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
      ],
    );
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }
}

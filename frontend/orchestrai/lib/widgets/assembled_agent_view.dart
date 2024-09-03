import 'package:flutter/material.dart';
import '../models/crew_model.dart';

class AssembledAgentView extends StatelessWidget {
  final AgentModel agent;

  AssembledAgentView({required this.agent});

  @override
  Widget build(BuildContext context) {
    // 에이전트 이름을 파일 이름으로 변환 (공백 및 특수 문자 제거)
    String assetName = agent.name.replaceAll(RegExp(r'\s+'), '_').toLowerCase();
    assetName = assetName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

    return Center(
      child: ClipOval(
        child: Container(
          width: 320, // 원의 크기를 두 배로 키움
          height: 320,
          child: Image.asset(
            'assets/$assetName.png', // 에이전트의 이름을 사용하여 자산 이름을 동적으로 생성
            fit: BoxFit.contain, // 이미지를 원 안에 맞춤
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return Container(
                width: 320,
                height: 320,
                color: Colors.blue,
                child: Center(
                  child: Text(
                    agent.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(fontSize: 32, color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

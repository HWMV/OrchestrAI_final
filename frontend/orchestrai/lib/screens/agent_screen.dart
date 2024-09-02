import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/crew_model.dart';
import '../widgets/assembled_agent_view.dart';
import '../widgets/parameter_settings_view.dart';

class AgentScreen extends StatelessWidget {
  final int agentIndex;

  AgentScreen({required this.agentIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI 에이전트 상세'),
        backgroundColor: Colors.lightBlue.shade700, // 앱바 색상 설정
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.lightBlue.shade200, Colors.blue.shade900], // 블루 계열 그라데이션
          ),
        ),
        child: Consumer<CrewModel>(
          builder: (context, crewModel, child) {
            final selectedAgent = crewModel.selectedAgents[agentIndex];
            return Row(
              children: [
                // 좌측: 선택된 Agent 에셋 출력
                Expanded(
                  flex: 1,
                  child: selectedAgent != null
                      ? AssembledAgentView(agent: selectedAgent)
                      : Center(child: Text('Agent를 선택해주세요', style: TextStyle(color: Colors.black87))),
                ),
                // 중앙: 사용 가능한 Agent 목록
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: crewModel.availableAgentNames.length,
                    itemBuilder: (context, index) {
                      final agentName = crewModel.availableAgentNames[index];
                      return ListTile(
                        leading: Icon(Icons.person, color: Colors.black87),
                        title: Text(agentName, style: TextStyle(color: Colors.black87)),
                        onTap: () => crewModel.selectAgent(agentIndex, agentName),
                      );
                    },
                  ),
                ),
                // 우측: 선택된 Agent에 대한 정보 표시
                Expanded(
                  flex: 2,
                  child: selectedAgent != null
                      ? ParameterSettingsView(
                          agent: selectedAgent,
                          onInputChanged: (String input) {
                            crewModel.updateUserInput(input);
                          },
                        )
                      : Center(child: Text('Agent를 선택해주세요', style: TextStyle(color: Colors.black87))),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
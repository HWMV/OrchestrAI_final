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
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        color: Colors.grey[200], // 배경색을 회색으로 설정
        child: Consumer<CrewModel>(
          builder: (context, crewModel, child) {
            final selectedAgent = crewModel.selectedAgents[agentIndex];
            return Column(
              children: [
                AppBar(
                  title: Text('AI 에이전트를 선택해주세요'),
                  backgroundColor: Colors.grey[200], // 앱바 색상 설정
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    children: [
                      // 좌측: 사용 가능한 Agent 목록
                      Expanded(
                        flex: 1,
                        child: ListView.builder(
                          itemCount: crewModel.availableAgentNames.length,
                          itemBuilder: (context, index) {
                            final agentName =
                                crewModel.availableAgentNames[index];
                            final isSelected =
                                crewModel.selectedAgents[agentIndex]?.name ==
                                    agentName;
                            return GestureDetector(
                                onTap: () => crewModel.selectAgent(
                                    agentIndex, agentName),
                                child: Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Color(0xFFFFD966)
                                          : Color(0xFF6050DC),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    width: 100, // 사각형의 너비를 150으로 설정
                                    child: Text(
                                      agentName,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                      textAlign: TextAlign.center,
                                    )));
                          },
                        ),
                      ),
                      // 중앙: 선택된 Agent 에셋 출력
                      Expanded(
                        flex: 1,
                        child: selectedAgent != null
                            ? AssembledAgentView(agent: selectedAgent)
                            : Center(
                                child: Text('Agent를 선택해주세요',
                                    style: TextStyle(color: Colors.black87))),
                      ),
                      // 우측: 선택된 Agent에 대한 정보 표시
                      Expanded(
                        flex: 1,
                        child: selectedAgent != null
                            ? ParameterSettingsView(
                                agent: selectedAgent,
                                onInputChanged: (input) {
                                  // 여기에 입력 변경 시 수행할 작업을 추가할 수 있습니다.
                                  // 예: crewModel.updateAgentInput(agentIndex, input);
                                },
                              )
                            : Center(child: Text('Agent를 선택해주세요')),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6050DC), // 버튼 색상 설정
                      ),
                      child: Text('선택', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

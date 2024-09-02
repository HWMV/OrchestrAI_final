import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/crew_model.dart';
import '../widgets/hamburger_view.dart';
import '../widgets/agent_dependency_popup.dart';
import '../widgets/ai_team_popup.dart';
import 'agent_screen.dart';

class CrewScreen extends StatefulWidget {
  @override
  _CrewScreenState createState() => _CrewScreenState();
}

class _CrewScreenState extends State<CrewScreen> {
  bool _hasShownPopup = false;

  final List<Offset> chairPositions = [
    Offset(0.35, 0.34),
    Offset(0.35, 0.53),
    Offset(0.62, 0.34),
    Offset(0.62, 0.53),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTeamNamePopupIfNeeded();
    });
  }

  void _showTeamNamePopupIfNeeded() {
    final crewModel = Provider.of<CrewModel>(context, listen: false);
    if (crewModel.teamName == null && !_hasShownPopup) {
      _hasShownPopup = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AITeamPopup(
            onCreateTeam: () {
              setState(() {});
            },
          );
        },
      ).then((_) {
        // 팝업이 닫힌 후 플래그를 재설정하지 않음
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OrchestrAI'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue.shade700, // 앱바 색상 설정
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          TextButton(
            child: Text('로그인', style: TextStyle(color: Colors.black87)),
            onPressed: () {
              // TODO: Implement login functionality
            },
          ),
          TextButton(
            child: Text('회원가입', style: TextStyle(color: Colors.black87)),
            onPressed: () {
              // TODO: Implement signup functionality
            },
          ),
        ],
      ),
      drawer: HamburgerView(),
      body: Consumer<CrewModel>(
        builder: (context, crewModel, child) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.lightBlue.shade200,
                      Colors.blue.shade900
                    ], // 블루 계열 그라데이션
                  ),
                ),
              ),
              if (crewModel.teamName != null)
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.35,
                  left: MediaQuery.of(context).size.width * 0.5 - 100,
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFF6050DC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        crewModel.teamName!,
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ...List.generate(4, (index) {
                return Positioned(
                  left: MediaQuery.of(context).size.width *
                      chairPositions[index].dx,
                  top: MediaQuery.of(context).size.height *
                      chairPositions[index].dy,
                  child: GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AgentScreen(agentIndex: index),
                        ),
                      );
                      setState(() {});
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (crewModel.selectedAgents[index] == null)
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.black87,
                              size: 24,
                            ),
                          )
                        else
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                crewModel.selectedAgents[index]!.name
                                    .substring(0, 1),
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<CrewModel>(
        builder: (context, crewModel, child) {
          List<AgentModel> activeAgents =
              crewModel.selectedAgents.whereType<AgentModel>().toList();

          if (activeAgents.isEmpty) {
            return SizedBox.shrink();
          }

          return Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter user input for the crew',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => crewModel.updateUserInput(value),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  child: Text(
                    '협업 시작',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (activeAgents.isNotEmpty) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AgentDependencyPopup(
                            agents: activeAgents,
                            onDependenciesSet:
                                (List<AgentModel> orderedAgents) async {
                              List<Map<String, dynamic>> orderedAgentData =
                                  orderedAgents.map((agent) {
                                return {
                                  'agent_name': agent.name,
                                  'role': agent.role,
                                  'goal': agent.goal,
                                  'backstory': agent.backstory,
                                };
                              }).toList();

                              crewModel.updateAgentOrder(orderedAgentData);
                              String result = await crewModel.executeAgents();
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('협업 결과'),
                                    content: Text(result),
                                    actions: [
                                      TextButton(
                                        child: Text('확인'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에이전트를 먼저 추가해주세요.')),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

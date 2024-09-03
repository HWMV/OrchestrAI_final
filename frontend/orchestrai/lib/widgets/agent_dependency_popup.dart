import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import '../models/crew_model.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class AgentDependencyPopup extends StatefulWidget {
  final List<AgentModel> agents;
  final String userInput;

  const AgentDependencyPopup({
    Key? key,
    required this.agents,
    required this.userInput,
  }) : super(key: key);

  @override
  _AgentDependencyPopupState createState() => _AgentDependencyPopupState();
}

class _AgentDependencyPopupState extends State<AgentDependencyPopup> {
  late List<AgentModel> _orderedAgents;

  @override
  void initState() {
    super.initState();
    _orderedAgents = List.from(widget.agents);
  }

  Future<void> _executeCrew() async {
    try {
      final apiService = ApiService();
      final crewData = {
        "agents": _orderedAgents
            .map((agent) => {
                  "agent_name": agent.name,
                  "user_input": widget.userInput,
                  "depends_on": _orderedAgents.indexOf(agent) > 0
                      ? [_orderedAgents[_orderedAgents.indexOf(agent) - 1].name]
                      : []
                })
            .toList(),
        "user_input": widget.userInput
      };

      final result = await apiService.executeCrew(crewData);

      if (result.containsKey('result')) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              result: result['result'],
            ),
          ),
        );
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('Error executing crew: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred while executing crew: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('에이전트 실행 순서 설정'),
      content: Container(
        width: double.maxFinite,
        child: ReorderableListView(
          children: _orderedAgents.map((agent) {
            return ListTile(
              key: ValueKey(agent),
              title: Text(agent.name),
              trailing: Icon(Icons.drag_handle),
            );
          }).toList(),
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final AgentModel item = _orderedAgents.removeAt(oldIndex);
              _orderedAgents.insert(newIndex, item);
            });
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('취소'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('협업 실행'),
          onPressed: _executeCrew,
        ),
      ],
    );
  }
}

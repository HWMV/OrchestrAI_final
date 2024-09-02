import 'package:flutter/material.dart';
import '../models/crew_model.dart';

class AgentDependencyPopup extends StatefulWidget {
  final List<AgentModel> agents;
  final Function(List<AgentModel>) onDependenciesSet;

  const AgentDependencyPopup({
    Key? key,
    required this.agents,
    required this.onDependenciesSet,
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
          child: Text('확인'),
          onPressed: () {
            widget.onDependenciesSet(_orderedAgents);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

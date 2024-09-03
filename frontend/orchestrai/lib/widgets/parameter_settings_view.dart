import 'package:flutter/material.dart';
import '../models/crew_model.dart';

class ParameterSettingsView extends StatelessWidget {
  final AgentModel agent;
  final Function(String) onInputChanged;

  ParameterSettingsView({
    required this.agent,
    required this.onInputChanged,
  });

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            content,
            style: TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            agent.name,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          _buildInfoSection('역할', agent.role),
          _buildInfoSection('목표', agent.goal),
          _buildInfoSection('배경', agent.backstory),
          // SizedBox(height: 24),
          // Text(
          //   '에이전트에게 지시하기',
          //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          // ),
          // SizedBox(height: 8),
          // TextField(
          //   decoration: InputDecoration(
          //     hintText: '에이전트에게 지시할 내용을 입력하세요',
          //     border: OutlineInputBorder(),
          //     filled: true,
          //     fillColor: Colors.white,
          //   ),
          //   maxLines: 5,
          //   onChanged: onInputChanged,
          // ),
        ],
      ),
    );
  }
}

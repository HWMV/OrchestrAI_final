import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crew_model.dart';

class ApiService {
  final String baseUrl =
      'https://orchestrai-app-196731605483.asia-northeast3.run.app'; // 현재 백엔드 URL, 로컬 테스트용 URL : http://localhost:8000

  Future<List<String>> getAvailableAgents() async {
    print('Requesting agents from: $baseUrl/agents');
    final response = await http.get(
      Uri.parse('$baseUrl/agents'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> agentsJson = data['agents'];
      return agentsJson.cast<String>();
    } else {
      throw Exception(
          'Failed to load available agents: ${response.statusCode}');
    }
  }

  Future<AgentModel> getAgentDetails(String agentName) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/agents/$agentName'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> agentJson = json.decode(response.body);
        return AgentModel(
          name: agentJson['name'],
          role: agentJson['role'],
          goal: agentJson['goal'],
          backstory: agentJson['backstory'],
        );
      } else {
        throw Exception('Failed to load agent details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAgentDetails: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> executeCrew(
      Map<String, dynamic> crewData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/execute-crew'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(crewData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to execute crew: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error executing crew: $e');
    }
  }
}

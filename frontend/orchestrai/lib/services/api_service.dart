import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crew_model.dart';

class ApiService {
  final String baseUrl = 'http://localhost:8000'; // 로컬 테스트용 URL

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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(crewData), // crewData를 그대로 사용
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data; // 전체 응답 데이터를 반환
      } else {
        throw Exception('Failed to execute crew: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in executeCrew: $e');
      rethrow;
    }
  }
}

// ------- 수정 전 -------
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ApiService {
//   final String baseUrl = 'http://localhost:8000'; // 백엔드 서버 주소
//   // 'http://13.209.41.78:8000'; // 백엔드 서버 주소

//   // 사용 가능한 도구 목록을 반환하는 엔드포인트
//   Future<List<Map<String, String>>> getAvailableTools() async {
//     try {
//       print('Requesting available tools from: $baseUrl/available_tools');
//       final response = await http.get(Uri.parse('$baseUrl/available_tools'));
//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final toolsList = data['tools'] as List;
//         return toolsList
//             .map((tool) => {
//                   'name': tool['name'] as String,
//                   'description': tool['description'] as String,
//                 })
//             .toList();
//       } else {
//         throw Exception(
//             'Failed to load available tools. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error in getAvailableTools: $e');
//       throw Exception('Failed to load available tools: $e');
//     }
//   }

//   Future<Map<String, dynamic>> executeCrew(
//       Map<String, dynamic> crewData) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/execute_crew'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(crewData),
//       );

//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to execute crew: ${response.body}');
//       }
//     } catch (e) {
//       throw Exception('Error executing crew: $e');
//     }
//   }
// }

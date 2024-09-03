import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class CrewModel extends ChangeNotifier {
  List<AgentModel?> selectedAgents = List.filled(4, null);
  List<String> availableAgentNames = [];
  late ApiService apiService;

  // teamName 입력 창 2번 뜨는 버그 때문에 추가
  String? _teamName;
  bool _hasShownTeamNamePopup = false;

  String? get teamName => _teamName;
  bool get hasShownTeamNamePopup => _hasShownTeamNamePopup;

  String userInput = '';
  bool _isLoading = false;

  bool isPopupShown = false;

  CrewModel() {
    apiService = ApiService();
    _fetchAvailableAgents();
  }

  Future<void> _fetchAvailableAgents() async {
    if (_isLoading || availableAgentNames.isNotEmpty) return;
    _isLoading = true;
    try {
      print('Fetching available agents...');
      availableAgentNames = await apiService.getAvailableAgents();
      print('Fetched agents: $availableAgentNames');
      notifyListeners();
    } catch (e) {
      print('Error fetching available agents: $e');
    } finally {
      _isLoading = false;
    }
  }

  // teamName 2번 뜨는 버그 때문에 수정
  void setTeamName(String name) {
    _teamName = name;
    notifyListeners();
  }

  Future<void> selectAgent(int index, String agentName) async {
    try {
      AgentModel agent = await apiService.getAgentDetails(agentName);
      selectedAgents[index] = agent;
      notifyListeners();
    } catch (e) {
      print('Error selecting agent: $e');
    }
  }

  void updateAgentOrder(List<Map<String, dynamic>> orderedAgents) {
    for (int i = 0; i < orderedAgents.length; i++) {
      Map<String, dynamic> agentData = orderedAgents[i];
      String agentName = agentData['agent_name'];

      // selectedAgents 리스트에서 해당 에이전트를 찾습니다.
      int index = selectedAgents.indexWhere((a) => a?.name == agentName);
      if (index != -1) {
        AgentModel updatedAgent = selectedAgents[index]!;
        // 현재 에이전트 이전의 모든 에이전트들을 의존성으로 추가합니다.
        updatedAgent.dependencies = orderedAgents
            .sublist(0, i)
            .map((a) => a['agent_name'] as String)
            .toList();
        selectedAgents[index] = updatedAgent;
      }
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> executeAgents() async {
    List<AgentModel> activeAgents =
        selectedAgents.whereType<AgentModel>().toList();
    if (activeAgents.isEmpty) return {'error': 'No agents selected'};

    try {
      List<Map<String, dynamic>> agentData = activeAgents.map((agent) {
        return {
          'agent_name': agent.name,
          'user_input': userInput,
          'depends_on': agent.dependencies,
        };
      }).toList();

      Map<String, dynamic> crewData = {
        'agents': agentData,
        'user_input': userInput,
      };

      Map<String, dynamic> result = await apiService.executeCrew(crewData);

      if (result.containsKey('result')) {
        return result['result'];
      } else {
        return {'error': 'Unexpected response from server'};
      }
    } catch (e) {
      print('Error executing agents: $e');
      return {'error': 'Error: $e'};
    }
  }

  void removeAgent(int index) {
    selectedAgents[index] = null;
    notifyListeners();
  }

  void updateUserInput(String input) {
    userInput = input;
    notifyListeners();
  }
}

class AgentModel {
  final String name;
  final String role;
  final String goal;
  final String backstory;
  List<String> dependencies;

  AgentModel({
    required this.name,
    required this.role,
    required this.goal,
    required this.backstory,
    this.dependencies = const [],
  });
}

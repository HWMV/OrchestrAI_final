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

  Future<String> executeAgents() async {
    List<AgentModel> activeAgents =
        selectedAgents.whereType<AgentModel>().toList();
    if (activeAgents.isEmpty) return 'No agents selected';

    try {
      // 백엔드 API 호출을 위한 데이터 준비
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

      // 백엔드 API 호출 (userInput은 이미 crewData에 포함되어 있으므로 별도로 전달하지 않습니다)
      Map<String, dynamic> result = await apiService.executeCrew(crewData);

      // 결과 처리
      if (result.containsKey('result')) {
        return result['result'].toString();
      } else {
        return 'Unexpected response from server';
      }
    } catch (e) {
      print('Error executing agents: $e');
      return 'Error: $e';
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

// ------ 수정 전 -------
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import '../Taskbuilder/task_utils..dart';
// import '../services/api_service.dart';

// class CrewModel extends ChangeNotifier {
//   List<AgentModel?> agents = List.filled(5, null);
//   late ApiService apiService;
//   List<Map<String, String>> availableTools = [];

//   String? teamName;

//   CrewModel() {
//     apiService = ApiService();
//     loadAvailableTools();
//   }

//   static const List<String> predefinedAgentNames = [
//     'Lead Market Analyst',
//     'Chief Marketing Strategist',
//     'Creative Content Creator',
//     'Senior Photographer',
//     'Chief Creative Director',
//     'Researcher',
//     'Technical Analyst',
//     'Financial Analyst',
//     'Investment Advisor',
//     'Custom Agent',
//   ];

//   static const Map<String, String> customAgentDisplayNames = {
//     'Lead Market Analyst': '선두 시장 분석가',
//     'Chief Marketing Strategist': '수석 마케팅 전략가',
//     'Creative Content Creator': '창의적 콘텐츠 제작자',
//     'Senior Photographer': '수석 사진작가',
//     'Chief Creative Director': '수석 크리에이티브 디렉터',
//     'Researcher': '연구원',
//     'Technical Analyst': '테크니컬 애널리스트',
//     'Financial Analyst': '파이낸셜 애널리스트',
//     'Investment Advisor': '투자 자문가',
//     'Custom Agent': '사용자 정의 에이전트',
//   };

//   static const Map<String, String> customTaskDisplayNames = {
//     'Product Analysis': '프로덕트 분석',
//     'Competitor Analysis': '경쟁사 분석',
//     'Campaign Development': '캠페인 개발',
//     'Instagram ad Copy': '인스타그램 광고카피',
//     'Photoshooting': '사진찍기',
//     'Research': '리서치',
//     'Technical Analysis': '기술적 분석',
//     'Financial Analysis': '재무 분석',
//     'Investment Advice': '투자 조언',
//     'Custom Task': '사용자 정의 태스크',
//   };

//   static Map<String, Map<String, String>> predefinedAgentDetails = {
//     'Lead Market Analyst': {
//       'role': 'Lead Market Analyst',
//       'goal':
//           'Conduct comprehensive analysis of the market and competitors, providing in-depth insights to guide marketing strategies.',
//       'backstory':
//           'As the Lead Market Analyst at a premier digital marketing firm, you specialize in dissecting online business landscapes and identifying key trends and opportunities.',
//     },
//     'Chief Marketing Strategist': {
//       'role': 'Chief Marketing Strategist',
//       'goal':
//           'Develop innovative and effective marketing strategies based on market analysis and business objectives.',
//       'backstory':
//           'With years of experience in various marketing roles, you have risen to become the Chief Marketing Strategist, known for your ability to craft compelling campaigns that drive results.',
//     },
//     'Creative Content Creator': {
//       'role': 'Creative Content Creator',
//       'goal':
//           'Produce engaging and original content across various platforms that resonates with the target audience and supports marketing objectives.',
//       'backstory':
//           'Your passion for storytelling and your knack for understanding audience preferences have made you a standout Creative Content Creator in the digital marketing world.',
//     },
//     'Senior Photographer': {
//       'role': 'Senior Photographer',
//       'goal':
//           'Capture high-quality, visually striking images that enhance marketing materials and effectively communicate brand messages.',
//       'backstory':
//           'With a keen eye for composition and lighting, you have built a reputation as a Senior Photographer who can bring any product or concept to life through your lens.',
//     },
//     'Chief Creative Director': {
//       'role': 'Chief Creative Director',
//       'goal':
//           'Oversee and guide the creative direction of all marketing campaigns, ensuring cohesive and impactful brand messaging across all channels.',
//       'backstory':
//           'Your innovative vision and ability to inspire teams have led you to the role of Chief Creative Director, where you shape the visual and conceptual identity of major brands.',
//     },
//   };

//   static const List<String> predefinedTaskNames = [
//     'Product Analysis',
//     'Competitor Analysis',
//     'Campaign Development',
//     'Instagram ad Copy',
//     'Photoshooting',
//     'Research',
//     'Technical Analysis',
//     'Financial Analysis',
//     'Investment Advice',
//     'Custom Task',
//   ];

//   static const List<String> predefinedToolNames = [
//     'Search internet',
//     'Search instagram',
//     'Dall-E Image Generaton',
//     'Stock Price Search',
//     'Stock News Search',
//     'Income Statement Search',
//     'Balance Sheet Search',
//     'Insider Transations Search',
//     'Custom Tool',
//   ];
//   static const Map<String, String> customToolDisplayNames = {
//     'Search internet': '인터넷 검색',
//     'Search instagram': '인스타그램 검색',
//     'Dall-E Image Generaton': 'Dall-E 이미지 생성',
//     'Stock Price Search': '주가 검색',
//     'Stock News Search': '주식 뉴스 검색',
//     'Income Statement Search': '손익계산서 검색',
//     'Balance Sheet Search': '대차대조표 검색',
//     'Insider Transations Search': '내부자 거래 검색',
//     'Custom Tool': '사용자 정의 도구',
//   };

//   static const Map<String, Map<String, String>> predefinedTaskDetails = {
//     'Market Analysis': {
//       'description':
//           'Analyze the current market trends and competitor rategies.',
//       'expectedOutput': 'Comprehensive market analysis report',
//     },
//     'Strategy Development': {
//       'description':
//           'Develop a marketing strategy based on the market analysis.',
//       'expectedOutput': 'Detailed marketing strategy document',
//     },
//     'Content Creation': {
//       'description': 'Create engaging content for various marketing channels.',
//       'expectedOutput': 'Content pieces for different platforms',
//     },
//     'Photo Shooting': {
//       'description': 'Capture high-quality photos for marketing materials.',
//       'expectedOutput': 'Set of professional photographs',
//     },
//     'Creative Direction': {
//       'description':
//           'Provide overall creative direction for the marketing campaign.',
//       'expectedOutput': 'Creative brief and guidelines',
//     },
//   };

//   Future<void> loadAvailableTools() async {
//     try {
//       availableTools = await apiService.getAvailableTools();
//       notifyListeners();
//     } catch (e) {
//       print('Error loading available tools: $e');
//     }
//   }

//   void addDefaultAgent(int index) {
//     if (index < 0 || index >= agents.length) return;

//     String agentRole = predefinedAgentNames[index];
//     Map<String, String> agentDetails = predefinedAgentDetails[agentRole] ?? {};

//     agents[index] = AgentModel(
//       displayName: customAgentDisplayNames[agentRole] ?? agentRole,
//       role: agentDetails['role'] ?? '',
//       goal: agentDetails['goal'] ?? '',
//       backstory: agentDetails['backstory'] ?? '',
//       tools: [],
//       headAsset: '${index + 1}',
//       bodyAsset: '${index + 1}',
//       toolAsset: 'default',
//     );
//     assignTaskToAgent(agentRole);
//     notifyListeners();
//   }

//   void updateAgent(AgentModel updatedAgent, int index) {
//     if (index < 0 || index >= agents.length) return;
//     agents[index] = updatedAgent;
//     notifyListeners();
//   }

//   void setTeamName(String name) {
//     teamName = name;
//     notifyListeners();
//   }

//   String _getAssetName(String agentName) {
//     switch (agentName) {
//       case 'Lead Market Analyst':
//         return 'market_analyst';
//       case 'Chief Marketing Strategist':
//         return 'marketing_strategist';
//       case 'Creative Content Creator':
//         return 'content_creator';
//       case 'Senior Photographer':
//         return 'photographer';
//       case 'Chief Creative Director':
//         return 'creative_director';
//       default:
//         return 'default';
//     }
//   }

//   void assignTaskToAgent(String agentRole) {
//     final agent =
//         agents.firstWhere((a) => a?.role == agentRole, orElse: () => null);
//     if (agent != null) {
//       var object = 'apple';
//       switch (agentRole) {
//         case 'Lead Market Analyst':
//           agent.task = generateMarketAnalysisTask(object);
//           break;
//         case 'Chief Marketing Strategist':
//           agent.task = generateStrategyDevelopmentTask();
//           break;
//         case 'Creative Content Creator':
//           agent.task = generateContentCreationTask(object);
//           break;
//         case 'Senior Photographer':
//           agent.task = generateMarketAnalysisTask(object);
//           break;
//         case 'Chief Creative Director':
//           agent.task = generateCreativeDirectionTask(object);
//           break;
//         default:
//           agent.task = generateMarketAnalysisTask(object);
//           break;
//       }
//       notifyListeners();
//     }
//   }

//   Future<String> executeCrew() async {
//     try {
//       final crewData = {
//         'crew_resources': {
//           'agents': agents
//               .where((agent) => agent != null)
//               .map((agent) => {
//                     'role': agent!.role,
//                     'goal': agent.goal,
//                     'backstory': agent.backstory,
//                     'tools': agent.tools
//                         .map((tool) => {'name': tool['name']})
//                         .toList(),
//                     'task_description': agent.task?['description'],
//                   })
//               .toList(),
//           'tasks': [
//             for (var agent in agents.where((a) => a != null))
//               {
//                 'description': agent!.task?['prompt'],
//                 'target_agent': agent.role,
//                 'expected_output': agent.task?['expectedOutput'],
//               }
//           ],
//         }
//       };

//       print('Sending crew data: ${json.encode(crewData)}');

//       final result = await apiService.executeCrew(crewData);
//       return result['result'] as String;
//     } catch (e) {
//       print('Error executing crew: $e');
//       return 'Error: $e';
//     }
//   }
// }

// class AgentModel {
//   String displayName;
//   String role;
//   String goal;
//   String backstory;
//   Map<String, String>? task;
//   // List<String> tools;
//   List<Map<String, String>> tools;
//   String headAsset;
//   String bodyAsset;
//   String toolAsset;

//   AgentModel({
//     required this.displayName,
//     required this.role,
//     required this.goal,
//     required this.backstory,
//     this.task,
//     required this.tools,
//     required this.headAsset,
//     required this.bodyAsset,
//     required this.toolAsset,
//   });
// }

// // class Task {
// //   String displayName;
// //   String description;
// //   String expectedOutput;
// //   List<String> outputFiles;

// //   Task({
// //     required this.displayName,
// //     required this.description,
// //     required this.expectedOutput,
// //     required this.outputFiles,
// //   }) {
// //     if (this.expectedOutput.isEmpty) {
// //       this.expectedOutput = "Task output";
// //     }
// //   }
// // }

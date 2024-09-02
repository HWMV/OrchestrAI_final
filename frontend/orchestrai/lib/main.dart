import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/crew_model.dart';
import 'screens/crew_screen.dart';
import 'widgets/ai_team_popup.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CrewModel(),
      child: OrchestrAIApp(),
    ),
  );
}

class OrchestrAIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrchestrAI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AITeamPopupOverlay(),
    );
  }
}

class AITeamPopupOverlay extends StatefulWidget {
  @override
  _AITeamPopupOverlayState createState() => _AITeamPopupOverlayState();
}

class _AITeamPopupOverlayState extends State<AITeamPopupOverlay> {
  bool _showPopup = true;

  void _navigateToCrewScreen() {
    setState(() {
      _showPopup = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CrewModel>(
      builder: (context, crewModel, child) {
        if (_showPopup) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AITeamPopup(
                  onCreateTeam: _navigateToCrewScreen,
                );
              },
            );
          });
        }
        return CrewScreen();
      },
    );
  }
}

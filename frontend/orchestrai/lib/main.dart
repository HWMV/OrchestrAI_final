import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/crew_model.dart';
import 'screens/crew_screen.dart';
import 'widgets/ai_team_popup.dart';

//projectId: "orchestrai-a81a7",
//HOSTING URL : https://orchestrai-a81a7.web.app
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CrewModel(),
      child: OrchestrAIApp(),
    ),
  );
}

class OrchestrAIApp extends StatefulWidget {
  @override
  _OrchestrAIAppState createState() => _OrchestrAIAppState();
}

class _OrchestrAIAppState extends State<OrchestrAIApp> {
  bool _showedPopup = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPopupOnce();
    });
  }

  void _showPopupOnce() {
    if (!_showedPopup) {
      setState(() {
        _showedPopup = true;
      });
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AITeamPopup(
            onCreateTeam: () {
              Navigator.of(context).pop();
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrchestrAI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CrewScreen(),
    );
  }
}

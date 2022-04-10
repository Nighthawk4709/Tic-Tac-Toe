import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utility.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final String title = 'Tic Tac Toe';

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        theme: ThemeData(
          primaryColor: Colors.green,
        ),
        home: MainPage(title: title),
      );
}

class MainPage extends StatefulWidget {
  final String title;

  const MainPage({
    required this.title,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class Player {
  static const none = '';
  static const X = 'X';
  static const O = 'O';
}

class _MainPageState extends State<MainPage> {
  late int scoreX =0;
  late int scoreY = 0;
  static const countMatrix = 3;
  static const double size = 92;

  String lastMove = Player.none;
  late List<List<String>> matrix;

  @override
  void initState() {
    super.initState();

    setEmptyFields();
  }

  void setEmptyFields() => setState(() => matrix = List.generate(
        countMatrix,
        (_) => List.generate(countMatrix, (_) => Player.none),
      ));

  Color getBackgroundColor() {
    final thisMove = lastMove == Player.X ? Player.O : Player.X;

    return getFieldColor(thisMove).withAlpha(150);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: getBackgroundColor(),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(widget.title),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
           
            Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: TicTacToeLogicUtil.modelBuilder(matrix, (x, value) => buildRow(x)),
        ),
        Column(children: [
          Column(children:[
          Center(child: Text("Score",style: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.bold)),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("Player X score is : $scoreX",style: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.bold),)],),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("Player O score is : $scoreY",style: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.bold))])
        ])])]));

  Widget buildRow(int x) {
    final values = matrix[x];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: TicTacToeLogicUtil.modelBuilder(
        values,
        (y, value) => buildField(x, y),
      ),
    );
  }

  Color getFieldColor(String value) {
    switch (value) {
      case Player.O:
        return Colors.teal;
      case Player.X:
        return Colors.pink;
      default:
        return Colors.white;
    }
  }

  Widget buildField(int x, int y) {
    final value = matrix[x][y];
    final color = getFieldColor(value);

    return Container(
      margin: EdgeInsets.all(4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(size, size),
          primary: color,
        ),
        child: Text(value, style: const TextStyle(fontSize: 32)),
        onPressed: () => selectField(value, x, y),
      ),
    );
  }

  void selectField(String value, int x, int y) {
    if (value == Player.none) {
      final newValue = lastMove == Player.X ? Player.O : Player.X;

      setState(() {
        lastMove = newValue;
        matrix[x][y] = newValue;
      });

      if (isWinner(x, y)) {
        if(newValue == Player.X) {
          scoreX += 1;
        } else  if(newValue == Player.O){
          scoreY +=1;
        }
        showEndDialog('Player $newValue Won');
      } else if (isEnd()) {
        showEndDialog('Undecided Game');
      }
    }
  }

  bool isEnd() =>
      matrix.every((values) => values.every((value) => value != Player.none));

  /// Check out logic here: https://stackoverflow.com/a/1058804
  bool isWinner(int x, int y) {
    var col = 0, row = 0, diag = 0, rdiag = 0;
    final player = matrix[x][y];
    const n = countMatrix;

    for (int i = 0; i < n; i++) {
      if (matrix[x][i] == player) col++;
      if (matrix[i][y] == player) row++;
      if (matrix[i][i] == player) diag++;
      if (matrix[i][n - i - 1] == player) rdiag++;
    }

    return row == n || col == n || diag == n || rdiag == n;
  }

  Future showEndDialog(String title) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: const Text("Press to Restart the Game"),
          actions: [
            ElevatedButton(
              onPressed: () {
                setEmptyFields();
                Navigator.of(context).pop();
              },
              child: const Text('Restart'),
            )
          ],
        ),
      );
}
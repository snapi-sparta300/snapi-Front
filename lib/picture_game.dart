import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'main_page.dart';

class PictureGamePage extends StatefulWidget {
  @override
  _PictureGamePageState createState() => _PictureGamePageState();
}

class _PictureGamePageState extends State<PictureGamePage> {
  int _score = 0;
  int _stage = 1;
  int? _differentPictureIndex;
  List<String> _pictureList = [];
  Timer? _timer;
  int _secondsLeft = 3;

  @override
  void initState() {
    super.initState();
    _startNewGameRound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startNewGameRound() {
    if (_stage > 10) {
      _endGame();
      return;
    }
    _timer?.cancel();
    _pictureList = List.generate(9, (index) => 'same_picture.jpg');
    _differentPictureIndex = Random().nextInt(9);
    _pictureList[_differentPictureIndex!] = 'different_picture.jpg';

    setState(() {
      _secondsLeft = 3;
    });

    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (_secondsLeft == 1) {
        _handleTimeOut();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  void _handlePictureTap(int index) {
    if (index == _differentPictureIndex) {
      setState(() {
        _score++;
        _stage++;
      });
    } else {
      setState(() {
        _stage++;
      });
    }
    _startNewGameRound();
  }

  void _handleTimeOut() {
    //_showResultDialog('시간 초과!');
    setState(() {
      _stage++;
    });
    _startNewGameRound();
  }

  void _showResultDialog(String resultText) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(resultText),
          content: Text('현재 점수: $_score\n다음 스테이지: $_stage'),
          actions: <Widget>[
            TextButton(
              child: Text('다음 라운드'),
              onPressed: () {
                Navigator.of(context).pop();
                _startNewGameRound();
              },
            ),
          ],
        );
      },
    );
  }

  void _endGame() async {
    _timer?.cancel();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('게임 종료'),
          content: Text('최종 점수: ${_score}\n+10P 적립되었습니다!'),
          actions: <Widget>[
            TextButton(
              child: Text('다시 시작'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _score = 0;
                  _stage = 1;
                });
                _startNewGameRound();
              },
            ),
            TextButton(
              child: Text('끝내기'),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()),
                      (Route<dynamic> route) => false, // 이 부분이 모든 이전 페이지를 제거
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('숨은 그림 찾기'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              child: Column(
                children: [
                  Expanded(
                    child: SizedBox(),
                    flex: 1,
                  ),
                  Text('${_stage} / 10', style: TextStyle(fontSize: 18)),
                  Text('남은 시간: ${_secondsLeft}초', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Expanded(
                    flex: 4,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _handlePictureTap(index),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.asset(
                              'assets/images/${_pictureList[index]}',
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: SizedBox(),
                    flex: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tinder_swipe/src/swipe_child.dart';

enum CardStatus { like, dislike, removed, rewind, none }

class SwipeController<T> extends ChangeNotifier {
  Function(CardStatus status, int length, T? data)? callback;
  Function(T? data)? nextCardCallback;

  void initCallback({
    Function<T>(CardStatus status, int length, T? data)? callback,
    Function<T>(T? data)? nextCardCallback,
  }) {
    this.callback = callback;
    this.nextCardCallback = nextCardCallback;
  }

  CardStatus? prevStatus;

  List<T> _data = [];
  List<T> get data => _data;

  bool isEmpty() => data.isEmpty;

  SwipeChild? get dataSecondLast {
    if (data.length < 2) return null;
    return SwipeChild(index: data.length - 2, data: data[data.length - 2]);
  }

  SwipeChild? get dataLast {
    if (data.isEmpty) return null;
    return SwipeChild(index: data.length - 1, data: data[data.length - 1]);
  }

  //START: ANIMATION PART
  bool _isAnimate = false;

  Offset _position = Offset.zero;
  Offset get position => _position;

  bool _isDragging = false;
  bool get isDragging => _isDragging;

  Size _screenSize = Size.zero;
  Size get screenSize => _screenSize;

  double _angle = 0;
  double get angle => _angle;

  void startPosition(DragStartDetails details) {
    _isDragging = true;
  }

  void updatePosition(DragUpdateDetails details) {
    _position += details.delta;

    final x = _position.dx;
    _angle = 45 * x / _screenSize.width;

    notifyListeners();
  }

  void endPosition() {
    _isDragging = false;

    final status = getStatus(isForce: true);

    switch (status) {
      case CardStatus.like:
        like();
        break;
      case CardStatus.dislike:
        dislike();
        break;
      default:
        resetPosition();
    }
  }
  //END: ANIMATION PART

  double getStatusOpacity() {
    const delta = 100;
    final pos = max(_position.dx.abs(), _position.dy.abs());
    final opacity = pos / delta;

    return min(opacity, 1);
  }

  CardStatus? getStatus({bool isForce = false}) {
    final x = _position.dx;

    if (isForce) {
      const delta = 100;

      if (x >= delta) {
        return CardStatus.like;
      } else if (x <= -delta) {
        return CardStatus.dislike;
      }
    } else {
      const delta = 20;

      if (x >= delta) {
        return CardStatus.like;
      } else if (x <= -delta) {
        return CardStatus.dislike;
      }
    }
    return null;
  }

  void like() {
    if (!_isAnimate) {
      _isAnimate = true;
      _angle = 20;
      _position += Offset(screenSize.width * 1.5, 0);
      notifyListeners();

      _nextCard();
      prevStatus = CardStatus.like;
    }
  }

  void dislike() {
    if (!_isAnimate) {
      _isAnimate = true;
      _angle = -20;
      _position -= Offset(screenSize.width * 1.5, 0);
      notifyListeners();

      _nextCard();
      prevStatus = CardStatus.dislike;
    }
  }

  void removed() {
    if (!_isAnimate) {
      _isAnimate = true;
      _angle = 0;
      _position -= Offset(0, -screenSize.height);
      notifyListeners();

      _nextCard();
      prevStatus = CardStatus.removed;
    }
  }

  void _nextCard() async {
    if (data.isEmpty) return;
    await Future.delayed(const Duration(milliseconds: 400));
    final lastData = _data.removeLast();
    notifyListeners();
    callback?.call(prevStatus ?? CardStatus.none, data.length, lastData);
    if (_data.isNotEmpty) nextCardCallback?.call(_data.last);
    resetPosition();
  }

  void rewind({required T prevData, CardStatus? fromStatus}) async {
    _isDragging = true;
    _data.add(prevData);
    notifyListeners();

    final directionStatus = fromStatus ?? prevStatus;
    _angle = directionStatus == CardStatus.like ? 20 : -20;
    _position = directionStatus == CardStatus.like
        ? Offset(screenSize.width * 1.5, 0)
        : Offset(-screenSize.width * 1.5, 0);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 200));
    _isDragging = false;
    _angle = 0;
    _position = const Offset(0, 0);
    notifyListeners();
    callback?.call(CardStatus.rewind, data.length, data.last);
  }

  void resetPosition() {
    _position = Offset.zero;
    _angle = 0;
    _isAnimate = false;
    notifyListeners();
  }

  void setScreenSize(Size size) {
    _screenSize = size;
  }

  void addData(List<T> newData) {
    if (data.isEmpty) {
      _data = newData.reversed.toList();
    } else {
      _data.insertAll(0, newData.reversed.toList());
    }
    notifyListeners();
  }

  void clearData() {
    _data = [];
    notifyListeners();
  }
}

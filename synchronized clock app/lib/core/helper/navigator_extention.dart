import 'package:flutter/material.dart';

extension NavigatorExtention on BuildContext {
  void push(Widget page) {
    Navigator.push(this, MaterialPageRoute(builder: (context) => page));
  }

  void pop() {
    Navigator.pop(this);
  }

  void pushReplacement(Widget page) {
    Navigator.pushReplacement(
      this,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  void pushAndRemoveUntil(Widget page) {
    Navigator.pushAndRemoveUntil(
      this,
      MaterialPageRoute(
        builder: (context) => page,
      ),
      (route) => false,
    );
  }
}

import 'package:flutter/material.dart';

abstract class TStateful<T extends StatefulWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    onInit();
  }

  void onInit() {}
}


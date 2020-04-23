import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressWidget extends StatelessWidget {
  final double progress;

  const ProgressWidget(this.progress, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator(value: progress,),);
  }
}

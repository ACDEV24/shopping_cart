import 'package:flutter/material.dart';

class CustomCircularProgressIndicator extends StatelessWidget {

  final Color color;
  final double size;

  const CustomCircularProgressIndicator({
    this.color = Colors.white,
    this.size = 35.0
  });

  @override
  Container build(BuildContext context) => Container(
    padding: EdgeInsets.all(5.0),
    height: size,
    width: size,
    child: Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
      )
    )
  );
}
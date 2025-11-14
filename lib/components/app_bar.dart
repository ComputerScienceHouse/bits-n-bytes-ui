import 'package:flutter/material.dart';

class BnBAppBar extends StatelessWidget implements PreferredSizeWidget {
  
  final String title;
  final List<Widget> children;
  
  const BnBAppBar({
    super.key,
    required this.title,
    this.children = const []
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 8),
        alignment: Alignment.topLeft,
        color: Colors.transparent,
        // we can set width here with conditions
        height: kToolbarHeight,
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 30, 
                fontWeight: FontWeight.w600, 
                fontFamily: Theme.of(context).textTheme.displayLarge?.fontFamily
              )
            ),
            ...children
          ],
        ),
      );
  }

  ///width doesnt matter
  @override
  Size get preferredSize => Size(200, kToolbarHeight);
}
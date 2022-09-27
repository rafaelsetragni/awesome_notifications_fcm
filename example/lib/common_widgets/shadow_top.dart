import 'package:flutter/material.dart';

class ShadowTop extends StatelessWidget {
  static Color _shade1 = Colors.black.withAlpha(45);
  static Color _shade2 = Colors.black.withAlpha(28);
  static Color _shade3 = Colors.black.withAlpha(6);
  static Color _shade4 = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return themeData.platform == TargetPlatform.android ?
        SizedBox() :
        Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: mediaQueryData.size.width,
              height: mediaQueryData.padding.top + 10,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _shade1,
                    _shade2,
                    _shade3,
                    _shade4
                  ],
                  stops: [
                      0.15,
                      0.45,
                      0.85,
                      0.95
                  ]
                )
              ),
            )
        );
  }
}

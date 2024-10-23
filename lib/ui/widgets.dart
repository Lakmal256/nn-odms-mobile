import 'package:flutter/material.dart';

class AppBarWithTM extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWithTM({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 7,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                "assets/images/tm_001.png",
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.grey,
                  size: 30,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class PageWithBackground extends StatelessWidget {
  const PageWithBackground({
    Key? key,
    required this.background,
    required this.child,
  }) : super(key: key);

  final Widget background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [background, child],
    );
  }
}

class PageWithBackgroundImage extends PageWithBackground {
  PageWithBackgroundImage({super.key, required Widget child, required String path})
      : super(
          child: child,
          background: Image.asset(
            path,
            alignment: Alignment.bottomCenter,
            fit: BoxFit.cover,
          ),
        );
}

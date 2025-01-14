import 'package:flutter/widgets.dart';

class Invisible extends StatelessWidget {
  const Invisible({
    Key? key,
    this.child,
    this.visible,
  }) : super(key: key);

  final bool? visible;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible!,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: visible! ? 1.0 : 0.0,
        child: child,
      ),
    );
  }
}

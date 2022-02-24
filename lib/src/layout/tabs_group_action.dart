import 'package:flutter/widgets.dart';
import 'package:tabs/src/layout/tabs_group.dart';

class TabsGroupAction extends StatelessWidget {
  const TabsGroupAction({Key? key, this.icon, this.onTap}) : super(key: key);

  final IconData? icon;
  final void Function(TabGroupController)? onTap;

  @override
  Widget build(BuildContext context) {
    final group = TabGroupProvider.of(context)!.controller;
    return GestureDetector(
      onTap: () => onTap!(group),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.only(bottom: 2),
          child: Icon(
            icon,
            size: 30,
            color: Color.fromARGB(255, 201, 201, 201),
          ),
        ),
      ),
    );
  }
}

class TabsGroupActions extends InheritedWidget {
  const TabsGroupActions({
    Key? key,
    required this.child,
    this.actions = const [],
  }) : super(key: key, child: child);

  @override
  // ignore: overridden_fields
  final Widget child;

  final List<TabsGroupAction> actions;

  static TabsGroupActions? of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<TabsGroupActions>());
  }

  @override
  bool updateShouldNotify(TabsGroupActions oldWidget) {
    return false;
  }
}

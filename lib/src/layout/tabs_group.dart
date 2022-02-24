import 'package:flutter/material.dart' hide Tab, TabController, VerticalDivider;
import 'package:tabs/src/layout/close_listener.dart';
import 'package:tabs/src/layout/replace_listener.dart';
import 'package:tabs/src/layout/tabs_accept_region.dart';
import 'package:tabs/src/layout/tabs_group_action.dart';
import 'package:tabs/src/layout/tabs_layout.dart';
import 'package:tabs/src/tab.dart';
import 'package:tabs/src/util/divider.dart';

class TabGroupController with ChangeNotifier {
  final _tabs = <Tab>[];

  List<Tab> get tabs => _tabs;

  int get length => tabs.length;

  void addTab(Tab tab, {bool activate = false}) {
    _tabs.add(tab);

    if (_activeTabIndex == null || activate) {
      setActiveTab(_tabs.length - 1);
    }

    notifyListeners();
  }

  void insertTab(int index, Tab tab, {bool focus = false}) {
    _tabs.insert(index, tab);

    if (_activeTabIndex == null || focus) {
      setActiveTab(_tabs.length - 1);
    }

    notifyListeners();
  }

  int? _activeTabIndex;

  int? get activeTabIndex => _activeTabIndex;

  void setActiveTab(int index) {
    if (index < 0 || index >= _tabs.length) {
      return;
    }

    _activeTabIndex = index;

    tabs[index].onActivate?.call();

    notifyListeners();
  }

  Tab getActiveTab() {
    if (_activeTabIndex == null || _activeTabIndex! >= _tabs.length) {
      _activeTabIndex = 0;
    }

    return _tabs[_activeTabIndex!];
  }

  void removeTabIndex(int index) {
    if (index < 0 || index >= _tabs.length) {
      return;
    }

    _tabs.removeAt(index);

    if (_tabs.isEmpty) {
      _activeTabIndex = null;
    } else {
      setActiveTab(_activeTabIndex!.clamp(0, _tabs.length - 1));
    }

    notifyListeners();
  }

  void removeTab(Tab tab) {
    _tabs.remove(tab);

    if (_tabs.isEmpty) {
      _activeTabIndex = null;
    } else {
      _activeTabIndex = _activeTabIndex!.clamp(0, _tabs.length - 1);
    }

    notifyListeners();
  }
}

class TabGroupProvider extends InheritedWidget {
  const TabGroupProvider({
    Key? key,
    required this.child,
    required this.controller,
  }) : super(key: key, child: child);

  final Widget child;

  final TabGroupController controller;

  static TabGroupProvider? of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<TabGroupProvider>());
  }

  @override
  bool updateShouldNotify(TabGroupProvider oldWidget) {
    return false;
  }
}

class TabsGroup extends StatefulWidget implements TabsLayout {
  const TabsGroup({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final TabGroupController controller;

  @override
  TabsGroupState createState() => TabsGroupState();
}

class TabsGroupState extends State<TabsGroup> {
  void onChange() {
    setState(() {});
  }

  @override
  void initState() {
    widget.controller.addListener(onChange);
    super.initState();
  }

  @override
  void didUpdateWidget(TabsGroup oldWidget) {
    oldWidget.controller.removeListener(onChange);
    widget.controller.addListener(onChange);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.controller.removeListener(onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TabGroupProvider(
      controller: widget.controller,
      child: TabAcceptRegion(
        original: widget,
        onReplace: (layout) {
          ReplaceListener.of(context)!.requestReplace(layout);
        },
        child: Column(
          children: [
            _buildTabs(context),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final children = <Widget>[];

    const backgroundColor = Color.fromARGB(255, 186, 185, 185);
    const tabBarHeight = 32.0;

    const borderColor = Color(0xFF4A4A4C);
    const borderWidth = 1.0;
    const div = VerticalDivider(
      color: borderColor,
      width: borderWidth,
    );

    for (var i = 0; i < widget.controller.tabs.length; i++) {
      final tab = widget.controller.tabs[i];

      final isActive = i == widget.controller.activeTabIndex;

      BoxConstraints? lastConstraints;
      var isAccepting = false;

      // final child = Expanded(
      //   // flex: 1,
      //   child: Draggable<Tab>(
      //     axis: Axis.horizontal,
      //     data: tab,
      //     childWhenDragging: Container(),
      //     child: LayoutBuilder(builder: (context, constraints) {
      //       lastConstraints = constraints;
      //       return DragTarget<Tab>(
      //         builder: (context, _, __) => GestureDetector(
      //           child: tab.build(isActive, isAccepting),
      //           onTap: () {
      //             print("set active tab $i");
      //             widget.controller.setActiveTab(i);
      //           },
      //         ),
      //         onAcceptWithDetails: (details) {
      //           isAccepting = false;
      //           widget.controller.insertTab(i, details.data.copy());
      //         },
      //         onWillAccept: (_) {
      //           isAccepting = true;
      //           return true;
      //         },
      //         onLeave: (_) {
      //           isAccepting = false;
      //         },
      //       );
      //     }),
      //     feedback: Builder(builder: (context) {
      //       return Container(
      //         height: tabBarHeight,
      //         width: lastConstraints?.maxWidth ?? 200,
      //         color: backgroundColor,
      //         child: DefaultTextStyle(
      //           style: const TextStyle(),
      //           child: tab.build(isActive, isAccepting),
      //         ),
      //       );
      //     }),
      //     // onDragStarted: () {
      //     //   // widget.controller.setActiveTab(i);
      //     //   if (widget.controller.length <= 1) {
      //     //     ReplaceListener.of(context)!.requestReplace(null);
      //     //   }
      //     // },
      //     onDragEnd: (detail) {
      //       print("darg end ${detail.offset} ${context.size}");
      //       if (detail.wasAccepted) {
      //         widget.controller.removeTab(tab);
      //         tab.onDrop?.call();
      //       }
      //     },
      //   ),
      // );
      // final child2 = Expanded(flex: 1, child: tab.build(isActive, isAccepting));
      final child2 = Expanded(
        child: GestureDetector(
            child: tab.build(isActive),
            onTap: () {
              widget.controller.setActiveTab(i);
            }),
        // child: TextButton(
        //     style: ButtonStyle(),
        //     onPressed: (() {
        //       widget.controller.setActiveTab(i);
        //     }),
        //     child: tab.build(isActive))
      );
      // final child2 = TextButton(onPressed: onPressed, child: child)
      children.add(child2);
      children.add(div);
    }

    // children.add(div);

    final tabRow = CloseListener(
      onClose: (tab) {
        widget.controller.removeTab(tab!);
        if (widget.controller.length <= 0) {
          ReplaceListener.of(context)!.requestReplace(null);
        }
      },
      child: Row(
        children: children,
        mainAxisSize: MainAxisSize.max,
      ),
    );

    return Container(
      height: tabBarHeight,
      child: Row(
        children: [
          Expanded(child: tabRow),
          _buildActions(context),
        ],
      ),
      decoration: const BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(color: borderColor, width: borderWidth),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final actions = TabsGroupActions.of(context)!.actions;

    final actionButtons = <Widget>[];

    for (var action in actions) {
      actionButtons.add(action);
    }

    return Row(children: actions);
  }

  Widget _buildContent(BuildContext context) {
    final activeTab = widget.controller.getActiveTab();
    return TabContent(
      tab: activeTab.controller,
    );
  }
}

class TabContent extends StatefulWidget {
  const TabContent({
    Key? key,
    required this.tab,
  }) : super(key: key);

  final TabController tab;

  @override
  _TabContentState createState() => _TabContentState();
}

class _TabContentState extends State<TabContent> {
  void onChange() {
    setState(() {});
  }

  @override
  void initState() {
    widget.tab.addListener(onChange);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TabContent oldWidget) {
    oldWidget.tab.removeListener(onChange);
    widget.tab.addListener(onChange);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.tab.removeListener(onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.tab.content ?? Container();
  }
}

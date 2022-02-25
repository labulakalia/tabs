import 'package:flutter/cupertino.dart';
import 'package:tabs/src/layout/close_listener.dart';
import 'package:tabs/src/util/invisible.dart';

class TabController with ChangeNotifier {
  TabController();

  TabController._(this._title, this._content);

  String? _title;

  Widget? _content;

  String? get title => _title;

  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }

  Widget? get content => _content;

  void setContent(Widget content) {
    _content = content;
    notifyListeners();
  }

  final closeRequest = ChangeNotifier();

  void requestClose() {
    closeRequest.notifyListeners();
  }

  TabController copy() {
    return TabController._(_title, _content);
  }
}

class Tab {
  Tab(
      {this.title,
      required this.controller,
      this.onClose,
      this.onActivate,
      this.onDrop,
      required this.index});

  final TabController controller;
  final String? title;
  final void Function()? onClose;
  final void Function()? onActivate;
  final void Function()? onDrop;
  int index;

  Widget build(bool isActive, [bool isAccepting = false]) {
    return TabWidget(
      tab: this,
      isActive: isActive,
      isAccepting: isAccepting,
    );
  }

  Tab copy() {
    return Tab(
      title: title,
      controller: controller.copy(),
      onClose: onClose,
      onActivate: onActivate,
      onDrop: onDrop,
      index: index,
    );
  }
}

const _kInactiveTextColor = Color(0xFF8B8B8B);

class TabWidget extends StatefulWidget {
  const TabWidget({
    Key? key,
    this.tab,
    this.isActive,
    this.isAccepting,
  }) : super(key: key);

  final Tab? tab;
  final bool? isActive;
  final bool? isAccepting;

  @override
  _TabWidgetState createState() => _TabWidgetState();
}

class _TabWidgetState extends State<TabWidget> {
  String? title = '';
  var hover = false;

  void onChange() {
    if (widget.tab!.controller.title != null) {
      setState(() {
        title = widget.tab!.controller.title;
      });
    }
  }

  @override
  void initState() {
    title = widget.tab!.controller.title ?? widget.tab!.title ?? title;
    widget.tab!.controller.addListener(onChange);
    widget.tab!.controller.closeRequest.addListener(close);
    super.initState();
  }

  @override
  void didUpdateWidget(TabWidget oldWidget) {
    title = widget.tab!.controller.title ?? widget.tab!.title ?? title;
    oldWidget.tab!.controller.removeListener(onChange);
    oldWidget.tab!.controller.closeRequest.removeListener(close);
    widget.tab!.controller.addListener(onChange);
    widget.tab!.controller.closeRequest.addListener(close);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.tab!.controller.removeListener(onChange);
    widget.tab!.controller.closeRequest.removeListener(close);
    super.dispose();
  }

  void close() {
    CloseListener.of(context)!.close(widget.tab);
    widget.tab!.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration;

    if (widget.isAccepting!) {
      decoration = const BoxDecoration(
        color: Color.fromARGB(255, 181, 181, 181),
      );
    } else if (widget.isActive!) {
      // 活跃
      decoration = const BoxDecoration(
        color: Color.fromARGB(255, 232, 232, 232),
        //  color: Color.fromARGB(255, 232, 232, 232),
        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   colors: [Color(0xffF7F5F5)],
        // ),
      );
    } else {
      decoration = const BoxDecoration(
        color: Color.fromARGB(255, 198, 196, 196),
      );
    }

    final content = Center(
      child: Text(
        title!,
        // style: TextStyle(color: Color.fromARGB(255, 29, 29, 29)),
        softWrap: false,
        overflow: TextOverflow.fade,
      ),
    );

    return MouseRegion(
      onEnter: (_) {
        if (!mounted) return;
        setState(() => hover = true);
      },
      onExit: (_) {
        if (!mounted) return;
        setState(() => hover = false);
      },
      child: Container(
        height: double.infinity,
        decoration: decoration,
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Invisible(
              visible: hover || widget.isActive!,
              child: _CloseButton(onClick: close),
            ),
            const Spacer(),
            Expanded(
              child: content,
            ),
            const Spacer(),
            Container(
                child: Text("⌘${widget.tab!.index + 1}"),
                // child: Icon(),
                padding: EdgeInsets.only(right: 10))
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({Key? key, this.onClick}) : super(key: key);

  final void Function()? onClick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          margin: const EdgeInsets.only(left: 6, right: 6, bottom: 3),
          child: const Icon(
            CupertinoIcons.clear_thick,
            color: _kInactiveTextColor,
            size: 15,
          ),
        ),
      ),
    );
  }
}

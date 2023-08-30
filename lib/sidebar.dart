import 'package:flutter/material.dart';

import 'main.dart';

class NavigationListTile extends StatefulWidget {
  final String route;
  final Widget title;
  final bool selected;

  const NavigationListTile({
    super.key,
    required this.route,
    required this.title,
    this.selected = false,
  });

  @override
  State<NavigationListTile> createState() => _NavigationListTileState();
}

class _NavigationListTileState extends State<NavigationListTile> {
  @override
  Widget build(BuildContext context) {
    final navContext = MyApp.navigatorKey.currentContext!;

    return Builder(builder: (context) {
      return ListTile(
        title: widget.title,
        selected: ModalRoute.of(navContext)?.settings.name == widget.route,
        onTap: () {
          Navigator.of(navContext).pushReplacementNamed(widget.route);
        },
      );
    });
  }
}

class Sidebar extends StatefulWidget {
  final double width;
  final List<NavigationListTile> navs;
  Sidebar({
    Key? key,
    this.width = 300,
    required this.navs,
    // this.children = const <Widget>[],
  }) : super(key: key) {
    if (width <= 0) {
      throw RangeError.value(width, 'width', 'Must be > 0');
    }
  }

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  var _currentRoute = '/';

  @override
  void initState() {
    super.initState();
    if (_navContext != null) {
      _currentRoute = ModalRoute.of(_navContext!)?.settings.name ?? '/';
    }
    // TODO: listen for route changes app-wide
  }

  BuildContext? get _navContext => MyApp.navigatorKey.currentContext;

  @override
  Widget build(BuildContext context) {
    final children = widget.navs
        .map<Widget>((x) => ListTile(
              title: x.title,
              selectedTileColor:
                  Theme.of(context).colorScheme.secondaryContainer,
              selected: x.route == _currentRoute,
              onTap: () {
                MyApp.navigatorKey.currentState!.pushReplacementNamed(x.route);
                setState(() => _currentRoute = x.route);
              },
            ))
        .intersperse(const Divider(
          height: 2,
        ))
        .toList();

    return Material(
      color: Theme.of(context).colorScheme.background,
      elevation: 8,
      child: SizedBox(
        width: widget.width,
        child: ListView(
          children: children,
        ),
      ),
    );
  }
}

extension IterableUtils<T> on Iterable<T> {
  /// The intersperse function takes an element and *intersperses*
  /// that element between the elements of this iterable.
  ///
  /// Example:
  /// ```dart
  /// var xs = [1, 2, 3, 4];
  ///
  /// // returns [1, 0, 2, 0, 3, 0, 4]
  /// xs.intersperse(0)
  /// ```
  Iterable<T> intersperse(T joinItem) sync* {
    var i = 0;
    for (var elem in this) {
      if (i > 0) {
        yield joinItem;
      }

      yield elem;
      i++;
    }
  }
}

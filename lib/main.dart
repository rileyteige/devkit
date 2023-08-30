import 'package:flutter/material.dart';

import 'routes.dart';
import 'sidebar.dart';
import 'toast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey(debugLabel: 'Main Navigator');

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Riley's Dev Kit",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      initialRoute: Routes.initial,
      onGenerateRoute: Routes.onGenerateRoute,
      builder: (context, child) {
        return Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("Riley's Dev Kit"),
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              ),
              body: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Builder(builder: (context) {
                    return Sidebar(
                      navs: const [
                        NavigationListTile(
                          route: Routes.hashes,
                          title: Text('Hashes'),
                        ),
                        NavigationListTile(
                          route: Routes.imageResizer,
                          title: Text('Image Resizer'),
                        ),
                        NavigationListTile(
                          route: Routes.regexTester,
                          title: Text('Regex'),
                        ),
                        NavigationListTile(
                          route: Routes.stringTransformations,
                          title: Text('String Transforms'),
                        ),
                      ],
                    );
                  }),
                  const VerticalDivider(width: 2),
                  if (child != null) Expanded(child: child),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

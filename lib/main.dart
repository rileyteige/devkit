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
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      initialRoute: Routes.initial,
      routes: Routes.all,
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
                          route: Routes.imageResizer,
                          title: Text('Image Resizer'),
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

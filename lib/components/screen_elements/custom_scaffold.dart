import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final bool showAppDrawer;
  final bool showAppBar;
  final List<Widget>? appBarActions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final Widget? drawer;
  final PreferredSizeWidget? appBar;
  final bool responsive;

  const CustomScaffold(
      {Key? key,
      this.title = '',
      this.drawer,
      this.showAppBar = true,
      required this.body,
      this.floatingActionButton,
      this.showAppDrawer = true,
      this.appBarActions,
      this.bottomNavigationBar,
      this.backgroundColor,
      this.appBar,
      this.responsive = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    if (responsive && kIsWeb) {
      width = MediaQuery.of(context).size.width > 800
          ? MediaQuery.of(context).size.width * 0.5
          : MediaQuery.of(context).size.width * 0.8;
    }
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar ??
          (showAppBar
              ? AppBar(
                  title: Text(title),
                  actions: appBarActions,
                )
              : null),
      bottomNavigationBar: bottomNavigationBar,
      drawer: showAppDrawer ? drawer : null,
      body: Center(child: SizedBox(width: width, child: body)),
      floatingActionButton: floatingActionButton,
    );
  }
}

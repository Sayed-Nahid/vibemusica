import 'package:flutter/material.dart';
import 'package:vibemusica/common/color_extension.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> with SingleTickerProviderStateMixin{

  TabController? controller;
  int selectTab = 0;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    controller?.addListener( () {
      selectTab = controller?.index ?? 0;
      setState( () {

      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: controller,
        children: [
          Container(),
          Container(),
          Container(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: TabBar(
          controller: controller,
          indicatorColor: Colors.transparent,
          indicatorWeight: 1,
          labelColor: TColor.primary,
          labelStyle: const TextStyle(fontSize: 10),
          unselectedLabelColor: TColor.primaryText28,
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          tabs: [
            Tab(
              text: "Home",
              icon: Image.asset( selectTab == 0 ? "assets/img/home_tab.png" : "assets/img/home_tab_un.png", width: 25, height: 25,),

            ),
            Tab(
              text: "Songs",
              icon: Image.asset( selectTab == 0 ? "assets/img/songs_tab.png" : "assets/img/songs_tab_un.png", width: 25, height: 25,),

            ),
            Tab(
              text: "Settings",
              icon: Image.asset( selectTab == 0 ? "assets/img/setting_tab.png" : "assets/img/setting_tab_un.png", width: 25, height: 25,),

            ),
          ],
        ),
      ),
    );
  }
}

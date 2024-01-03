import 'package:drivers_app/tabsPages/earningsTabPage.dart';
import 'package:drivers_app/tabsPages/homeTabPage.dart';
import 'package:drivers_app/tabsPages/profileTabPage.dart';
import 'package:drivers_app/tabsPages/ratingTabPage.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  static const String idScreen = "mainScreen";

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {

  late TabController tabController;
  int selectedIndex=0;

  void onItemClicked(int index)
  {
    setState(() {
      selectedIndex = index;
      tabController.index = selectedIndex;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tabController=TabController(length: 4, vsync: this);
    tabController.addListener(() {
      setState(() {
        selectedIndex = tabController.index;
      });

  });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          HomeTabPage(),
          EarningsTabPage(),
          RatingTabPage(),
          ProfileTabPage(),

        ],
      ),
    bottomNavigationBar: BottomNavigationBar(
    items: <BottomNavigationBarItem>[

    BottomNavigationBarItem(
    icon: Icon(Icons.home),
    label: "Home",
    ),

    BottomNavigationBarItem(
    icon: Icon(Icons.credit_card),
    label: "Earnings",
    ),

    BottomNavigationBarItem(
    icon: Icon(Icons.star),
    label: "Ratings",
    ),

    BottomNavigationBarItem(
    icon: Icon(Icons.person),
    label: "Account",
    ),

    ],

      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.green[400],
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 12.0),
      showUnselectedLabels: true,
      currentIndex: selectedIndex,
      onTap: onItemClicked,

    ),
    );
  }
}

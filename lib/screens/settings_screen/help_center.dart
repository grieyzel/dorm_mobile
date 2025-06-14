import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:scribblr/components/text_styles.dart';

import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/constant.dart';

class HelpCenter extends StatefulWidget {
  const HelpCenter({super.key});

  @override
  State<HelpCenter> createState() => _HelpCenterState();
}

class _HelpCenterState extends State<HelpCenter> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          surfaceTintColor: appStore.isDarkMode ? scaffoldDarkColor : context.scaffoldBackgroundColor,
          iconTheme: IconThemeData(color: appStore.isDarkMode ? Colors.white : Colors.black),
          title: Text('Help Center', style: primarytextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black)),
          backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : context.scaffoldBackgroundColor,
          bottom: TabBar(
            controller: _tabController,
            labelColor: appStore.isDarkMode ? scaffoldLightColor : scribblrPrimaryColor,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            indicatorPadding: EdgeInsets.symmetric(horizontal: 16),
            indicatorColor: Theme.of(context).primaryColor,
            tabs: [
              Tab(text: 'FAQ'),
              Tab(text: 'Contact Us'),
            ],
          ),
        ),
        body: TabBarView(controller: _tabController, children: [
          //FAQ Tab
          Column(children: faqTileWidgets),
          //Contact Us Tab
          Column(children: contactUsWidgets),
        ]),
      );
    });
  }
}

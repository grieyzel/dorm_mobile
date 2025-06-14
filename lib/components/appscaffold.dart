import 'package:scribblr/components/body.dart';
import 'package:scribblr/utils/commonbase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

class AppScaffold extends StatelessWidget {
  final bool hideAppBar;
  //
  final Widget? leadingWidget;
  final Widget? appBarTitle;
  final List<Widget>? actions;
  final bool isCenterTitle;
  final bool automaticallyImplyLeading;
  final double? appBarelevation;
  final String? appBartitleText;
  final Color? appBarbackgroundColor;
  final double? appBarheight;
  //
  final Widget body;
  final Color? scaffoldBackgroundColor;
  final RxBool? isLoading;
  //
  final Widget? bottomNavBar;
  final Widget? fabWidget;
  final bool hasLeadingWidget;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool? resizeToAvoidBottomPadding;
  final PreferredSizeWidget? appBarWidget;

  const AppScaffold({
    Key? key,
    this.hideAppBar = false,
    //
    this.leadingWidget,
    this.appBarTitle,
    this.actions,
    this.appBarelevation = 0,
    this.appBartitleText,
    this.appBarbackgroundColor,
    this.isCenterTitle = false,
    this.hasLeadingWidget = true,
    this.automaticallyImplyLeading = false,
    this.appBarheight,
    //
    required this.body,
    this.isLoading,
    //
    this.bottomNavBar,
    this.fabWidget,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomPadding,
    this.scaffoldBackgroundColor,
    this.appBarWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomPadding,
      appBar: hideAppBar
          ? null
          : PreferredSize(
              preferredSize: Size(screenWidth, appBarheight ?? 66),
              child: AppBar(
                elevation: appBarelevation,
                automaticallyImplyLeading: automaticallyImplyLeading,
                backgroundColor:
                    appBarbackgroundColor ?? context.scaffoldBackgroundColor,
                centerTitle: isCenterTitle,
                titleSpacing: 2,
                title: appBarTitle ??
                    Text(
                      appBartitleText ?? "",
                      style: primaryTextStyle(size: 16),
                    ).paddingLeft(hasLeadingWidget ? 0 : 16),
                actions: actions,
                leading:
                    leadingWidget ?? (hasLeadingWidget ? backButton() : null),
              ).paddingTop(10),
            ),
      backgroundColor:
          scaffoldBackgroundColor ?? context.scaffoldBackgroundColor,
      body: Body(
        child: body,
      ),
      bottomNavigationBar: bottomNavBar,
      floatingActionButton: fabWidget,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

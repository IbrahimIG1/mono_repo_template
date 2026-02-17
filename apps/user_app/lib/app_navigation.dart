import 'package:core/helper/current_flavor.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKeyDev = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> navigatorKeyPro = GlobalKey<NavigatorState>();

BuildContext? get activeContext =>
    CurrentFlavor.isDev
        ? navigatorKeyDev.currentContext
        : navigatorKeyPro.currentContext;

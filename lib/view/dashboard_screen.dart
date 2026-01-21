import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:joizone_app/view/create_lead.dart';
import 'package:joizone_app/view/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_constent.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Connectivity _connectivity = Connectivity();
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  bool _isDialogShowing = false; // track karega dialog chal raha hai ya nahi

  String name = '';
  String mobile = '';
  String uid = '';
  String rolename = '';
  String roleId = '';
  String branchId = '';
  String branch_name = '';
  String authId = '';
  String image = '';
  String address = '';

  void loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
      mobile = prefs.getString('mobile') ?? '';
      uid = prefs.getString('uid') ?? '';
      rolename = prefs.getString('rolename') ?? '';
      roleId = prefs.getString('roleId') ?? '';
      branchId = prefs.getString('branchId') ?? '';
      branch_name = prefs.getString('branch_name') ?? '';
      authId = prefs.getString('authId') ?? '';
      image = prefs.getString('image') ?? '';
      address = prefs.getString('address') ?? '';
      // Pehle local data check karo
    });
  }

  DateTime _currentTime = DateTime.now();

  // A Timer variable to control the  periodic updates.
  late Timer _timer;

  //user permission allow


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadUserData();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
    _checkConnection();
    // Listen continuously
    _connectivity.onConnectivityChanged.listen((
        List<ConnectivityResult> results,
        ) {
      final result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;

      setState(() {
        _connectionStatus = result;
      });

      if (result == ConnectivityResult.none) {
        _showNoInternetDialog();
      } else {
        _closeDialogIfOpen();
      }
    });
  }

  Future<void> _checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    setState(() {
      _connectionStatus = result as ConnectivityResult;
    });

    if (result == ConnectivityResult.none) {
      _showNoInternetDialog();
    }
  }

  void _launchInBrowser(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showNoInternetDialog() {
    if (!_isDialogShowing && mounted) {
      _isDialogShowing = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("No Internet"),
            content: const Text(
              "Your internet is off. Please check WiFi or Mobile Data.",
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  _isDialogShowing = false;
                  Navigator.of(context).pop();

                  // ✅ Close the app
                  if (Platform.isAndroid) {
                    SystemNavigator.pop(); // Android style close
                  } else if (Platform.isIOS) {
                    exit(
                      0,
                    ); // iOS में यह Apple guideline के खिलाफ है, लेकिन काम करेगा
                  } else {
                    exit(0); // fallback
                  }
                },
                child: const Text("Retry & Exit"),
              ),
            ],
          );
        },
      ).then((_) {
        _isDialogShowing = false;
      });
    }
  }

  void _closeDialogIfOpen() {
    if (_isDialogShowing && Navigator.canPop(context)) {
      Navigator.of(context).pop(); // close dialog
      _isDialogShowing = false;
    }
  }

  String getConnectionType() {
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        return "✅ Connected via WiFi";
      case ConnectivityResult.mobile:
        return "✅ Connected via Mobile Data";
      case ConnectivityResult.none:
        return "❌ No Internet";
      default:
        return "Unknown";
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appTextWhiteColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset("assets/img/joiyzone-logo.png",height: 40,width: 40,),
            Text("Joizone Ventures Pvt Ltd",style: TextStyle(color: AppConstant.appTextDarkColor,fontFamily: 'sens-serif',fontWeight: FontWeight.normal,fontSize: 16)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 20,
                      color: AppConstant.appTextDarkColor,
                    ),
                  ),
                  content: Text(
                    "Are you sure you want to logout of your account?",
                    style: TextStyle(
                      color: AppConstant.appTextDarkColor,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "No",
                        style: TextStyle(
                          color: AppConstant.appTextDarkColor,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final prefs =
                        await SharedPreferences.getInstance();
                        await prefs.clear();
                        Get.offAll(() => LoginScreen());
                      },
                      child: Text(
                        "Yes",
                        style: TextStyle(
                          color: AppConstant.appMainColor,
                        ),
                      ),
                    ),
                  ],
                  elevation: 10,
                  backgroundColor: AppConstant.appTextWhiteColor,
                ),
              );
            },
            icon: Icon(
              Icons.logout,
              color: AppConstant.appTextDarkColor,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Container(
              height: 50,
              color: Colors.grey[50],
              padding: const EdgeInsets.all(5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        "Hello! - $name",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppConstant.appTextDarkColor,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
            SizedBox(height: 5,),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.4,
                children: [
                  _dashboardBox(
                    title: "Create Lead",
                    icon: Icons.account_tree,
                    onTap: () {
                      Get.to(()=>CreateLead(userid:uid));
                    },
                  ),
                  _dashboardBox(
                    title: "User Verify",
                    icon: Icons.schedule,
                    onTap: () {
                    },
                  ),
                  _dashboardBox(
                    title: "Profile",
                    icon: Icons.person,
                    onTap: () {
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardBox({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppConstant.appIconColor),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

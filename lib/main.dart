import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:joizone_app/utils/app_constent.dart';
import 'package:joizone_app/view/dashboard_screen.dart';
import 'package:joizone_app/view/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');
    return uid != null && uid.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final localVersion = AppConstant.appVersion; // e.g. v1.0.1
          print(localVersion);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Joizone',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      builder: EasyLoading.init(),
      home: FutureBuilder<String?>(
        future: fetchLatestVersion(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Scaffold(
              body: Center(child: Text("Something went wrong..")),
            );
          }

          final latestVersion = snapshot.data!;
          debugPrint("Local: $localVersion | Firebase: $latestVersion");
          print("latest version");
          print(latestVersion);
          /// 🔴 Version mismatch → force update
          if (localVersion != latestVersion) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(Icons.system_update,
                      //     size: 80, color: AppConstant.iconColor),
                      // const SizedBox(height: 20),
                      // Text(
                      //   "Current Version: $localVersion",
                      //   style: const TextStyle(fontSize: 12),
                      // ),
                      // const SizedBox(height: 20),
                      Text(
                        "Something went wrong..",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      // const SizedBox(height: 30),
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     await launchUrl(
                      //       Uri.parse(
                      //         "https://drive.google.com/drive/folders/1cW5XkhTHqU-rZFnWnRra4DM5EJ6cgFOF",
                      //       ),
                      //       mode: LaunchMode.externalApplication,
                      //     );
                      //
                      //     SystemNavigator.pop();
                      //   },
                      //   child: const Text("Download Latest Version"),
                      // ),
                    ],
                  ),
                ),
              ),
            );
          }

          /// ✅ Version OK → Login / Dashboard
          return FutureBuilder<bool>(
            future: isLoggedIn(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return snapshot.data == true
                  ? DashboardScreen()
                  : LoginScreen();
            },
          );
        },
      ),
    );
  }
}

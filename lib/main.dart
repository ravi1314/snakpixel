import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snakpix/firebase_options.dart';
import 'package:snakpix/screen/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:snakpix/screen/splas_screen.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
 WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
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
          brightness: Brightness.dark),
     initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/HomeScreen': (context) => HomeScreen(),
        // Add other routes here
      },
    );
  }
}

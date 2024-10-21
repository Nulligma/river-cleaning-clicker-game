import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gold_miner/home.dart';
import 'package:gold_miner/shop.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Full screen app
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [
      SystemUiOverlay.top, // Shows Status bar and hides Navigation bar
    ],
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int miners = 0;

  addMiners() {
    setState(() {
      miners++;
    });
    saveMiners();
  }

  @override
  void initState() {
    super.initState();
    loadMiners();
  }

  Future<void> loadMiners() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      miners = prefs.getInt('miners') ?? 0;
    });
  }

  Future<void> saveMiners() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('miners', miners);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AstroCoin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        fontFamily: GoogleFonts.ubuntu().fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) => LiquidSwipe(
          pages: [
            HomeClickerUi(
              miners: miners,
            ),
            Shop(
              onAdd: addMiners,
            )
          ],
          positionSlideIcon: 0.5,
          slideIconWidget:
              const Icon(Icons.arrow_back_ios, color: Colors.white),
          waveType: WaveType.liquidReveal,
          fullTransitionValue: 500,
          enableSideReveal: true,
          preferDragFromRevealedArea: true,
          enableLoop: true,
          ignoreUserGestureWhileAnimating: true,
        ),
      ),
    );
  }
}

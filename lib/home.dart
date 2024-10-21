import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gold_miner/widgets/border_text.dart';
import 'package:vibration/vibration.dart';

class HomeClickerUi extends StatefulWidget {
  final int miners;
  const HomeClickerUi({super.key, required this.miners});

  @override
  State<HomeClickerUi> createState() => _HomeClickerUiState();
}

class _HomeClickerUiState extends State<HomeClickerUi>
    with TickerProviderStateMixin {
  int _clickCount = 0;
  double _batteryPercentage = 1.0; // 100%
  late Timer _batteryTimer;
  DateTime? _appClosedTime;
  DateTime? _appOpenedTime;
  @override
  void initState() {
    super.initState();

    _loadClickCount();
    _loadBattery();

    _appOpenedTime = DateTime.now();
    _saveAppOpenedTime();

    _updateBatteryPercentage();

    _startBatteryRechargeTimer();
  }

  @override
  void dispose() {
    _batteryTimer.cancel();
    super.dispose();
  }

  // Lifecycle listener methods
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _appClosedTime = DateTime.now();
      _saveAppClosedTime();
    } else if (state == AppLifecycleState.resumed) {
      _appOpenedTime = DateTime.now();
      _saveAppOpenedTime();

      // Calculate and update battery percentage based on closed-open duration
      _updateBatteryPercentage();
    }
  }

  // Save the app closed time to SharedPreferences
  void _saveAppClosedTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('appClosedTime', _appClosedTime!.millisecondsSinceEpoch);
  }

  // Save the app opened time to SharedPreferences
  void _saveAppOpenedTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('appOpenedTime', _appOpenedTime!.millisecondsSinceEpoch);
  }

  // Calculate and update battery percentage based on closed-open duration
  void _updateBatteryPercentage() async {
    final prefs = await SharedPreferences.getInstance();
    final int? closedTimeMillis = prefs.getInt('appClosedTime');
    final int? openedTimeMillis = prefs.getInt('appOpenedTime');

    if (closedTimeMillis != null && openedTimeMillis != null) {
      final Duration closedOpenDuration =
          Duration(milliseconds: openedTimeMillis - closedTimeMillis);
      final double chargeAmount = closedOpenDuration.inSeconds * 0.0001;

      setState(() {
        _batteryPercentage += chargeAmount;

        // Ensure battery percentage doesn't exceed 1.0 (100%)
        if (_batteryPercentage > 1.0) {
          _batteryPercentage = 1.0;
        }

        // Save battery percentage to SharedPreferences
        prefs.setDouble('batteryPercentage', _batteryPercentage);
      });
    }
  }

  void _loadClickCount() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _clickCount = pref.getInt("gold") ?? 0;
    });
  }

  void _loadBattery() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _batteryPercentage = pref.getDouble("batteryPercentage") ?? 1;
    });
  }

  void _saveBattery() async {
    final pref = await SharedPreferences.getInstance();
    pref.setDouble("batteryPercentage", _batteryPercentage);

    _appClosedTime = DateTime.now();
    _saveAppClosedTime();
  }

  void _incrementClickCount() async {
    final prefs = await SharedPreferences.getInstance();
    bool? canVibrate = await Vibration.hasVibrator();

    if (_batteryPercentage > 0.01) {
      if (canVibrate != null && canVibrate) {
        Vibration.vibrate(amplitude: 200, duration: 100);
      }
      setState(() {
        _clickCount += 1;
        prefs.setInt("gold", _clickCount);
        _batteryPercentage -= 0.01;
      });
    }
  }

  void _startBatteryRechargeTimer() {
    const rechargeInterval = Duration(seconds: 1);

    _batteryTimer = Timer.periodic(rechargeInterval, (timer) {
      if (!mounted || _batteryPercentage >= 1.0) return;

      setState(() {
        if (_batteryPercentage < 1.0) {
          _batteryPercentage += 0.0003;
        }
        if (_batteryPercentage >= 1.0) {
          _batteryPercentage = 1.0;
        }
      });

      _saveBattery();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: InkWell(
        onTap: _incrementClickCount,
        child: Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/gold_rock.png"), fit: BoxFit.cover),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBatteryIndicator(),
                  Column(
                    children: [
                      BorderText(text: "Gold: $_clickCount"),
                      const Text(
                        "Tap to mine ",
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  )
                ],
              ),
              if (_batteryPercentage <= 0.01)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.battery_alert),
                          Text('Low Power')
                        ],
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatteryIndicator() {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Column(
        children: [
          Text(
            "Power: ${(_batteryPercentage * 4000).toInt()}",
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          Row(
            children: [
              Icon(
                Icons.bolt,
                color: Colors.yellow.shade800,
                size: width * 0.07,
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: _batteryPercentage,
                  borderRadius: BorderRadius.circular(width * 0.02),
                  minHeight: 10,
                  backgroundColor: Colors.amber.shade100,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.amber.shade800),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

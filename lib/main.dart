// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_state/phone_state.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(CallTrackerApp());
}

class CallTrackerApp extends StatefulWidget {
  @override
  _CallTrackerAppState createState() => _CallTrackerAppState();
}

class _CallTrackerAppState extends State<CallTrackerApp> {
  static const methodChannel = MethodChannel('com.app.call_tracker');
  PhoneStateStatus currentState = PhoneStateStatus.NOTHING;
  DateTime? callInitiatedAt;
  DateTime? ringingInitiatedAt;
  Duration totalCallDuration = Duration.zero;
  bool isProductionMode = false;

  @override
  void initState() {
    super.initState();
    _checkPhonePermissions();
    _checkIfProductionMode();
  }

  Future<void> _checkPhonePermissions() async {
    final phoneStatus = await Permission.phone.status;
    if (!phoneStatus.isGranted) {
      final permissionResult = await Permission.phone.request();
      if (permissionResult.isDenied || permissionResult.isPermanentlyDenied) {
        print('Phone permission denied');
        return;
      }
    }
    _startListeningToPhoneState();
  }

  void _startListeningToPhoneState() {
    PhoneState.stream.listen((PhoneState event) {
      setState(() {
        currentState = event.status;

        if (isProductionMode && currentState == PhoneStateStatus.CALL_INCOMING) {
          ringingInitiatedAt = DateTime.now();
        } else if (currentState == PhoneStateStatus.CALL_STARTED) {
          callInitiatedAt = DateTime.now();
        } else if (currentState == PhoneStateStatus.CALL_ENDED && callInitiatedAt != null) {
          final callEndedAt = DateTime.now();
          if (isProductionMode && ringingInitiatedAt != null) {
            totalCallDuration = callEndedAt.difference(ringingInitiatedAt!);
          } else {
            totalCallDuration = callEndedAt.difference(callInitiatedAt!);
          }
          callInitiatedAt = null;
          ringingInitiatedAt = null;
        }
      });
    });
  }

  Future<void> _checkIfProductionMode() async {
    if (Platform.isIOS) {
      final isProdMode = await methodChannel.invokeMethod<bool>('isProductionMode');
      setState(() {
        isProductionMode = isProdMode ?? false;
      });
    }
  }

  String _formattedCallDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final currentSeconds = totalCallDuration.inSeconds % 60;
    const maxSecondsForProgress = 60;
    final progressValue = currentSeconds / maxSecondsForProgress;
    final formattedTime = _formattedCallDuration(totalCallDuration);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFFEFEFEF),
        appBar: AppBar(
          title: const Text('Call Duration Tracker'),
          backgroundColor: Colors.indigo[700],
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: currentState == PhoneStateStatus.CALL_ENDED || currentState == PhoneStateStatus.CALL_STARTED
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 450,
                      height: 450,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progressValue,
                            strokeWidth: 135.0,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                            backgroundColor: Colors.grey[300],
                          ),
                          Text(
                            formattedTime,
                            style: const TextStyle(fontSize: 36, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Tracking Call Duration',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  ],
                )
              : currentState == PhoneStateStatus.CALL_INCOMING
                  ? const Text(
                      'Incoming Call Detected...',
                      style: TextStyle(fontSize: 22, color: Colors.redAccent),
                    )
                  : const Text(
                      'Waiting for Call...',
                      style: TextStyle(fontSize: 22, color: Colors.black87),
                    ),
        ),
      ),
    );
  }
}

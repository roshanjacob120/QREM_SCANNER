import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _scannedData = "";

  _scanQR() async {
    String? scannedData = await scanner.scan();
    setState(() {
      _scannedData = scannedData;
    });
  }

  _storeDataToFirestore(String? data) async {
    await FirebaseFirestore.instance.collection("log").add({
      'scannedData': data,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  _approveData() {
    if (_scannedData != null && _scannedData!.isNotEmpty) {
      _storeDataToFirestore(_scannedData);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Data Approved"),
            content: Text("The scanned data has been approved and sent to the database."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("No Data"),
            content: Text("No data has been scanned yet."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  _rejectData() {
    setState(() {
      _scannedData = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QReM Scanner",style: GoogleFonts.sulphurPoint(),),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "SCAN QR CODE",
              style:GoogleFonts.sulphurPoint(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: Colors.teal
              ),
            ),
            SizedBox(height: 20),
            QrImage(
              data: "QREM REQUEST MANAGEMENT APPLICATION.odjrnhjrgosdfnokdfskngoeofkjnskdnlsdkfnsdfnsidjgjbsdidjnsdio",
              version: QrVersions.auto,
              size: 200.0,
            ),
            SizedBox(height: 20),
            Text(
              _scannedData ?? "No data scanned yet",
              textAlign: TextAlign.center,
              style: GoogleFonts.sulphurPoint(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scanQR,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: Text("Scan QR Code",
              style: GoogleFonts.sulphurPoint(),),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _approveData,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: Text("Approve",
                    style: GoogleFonts.sulphurPoint(),),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _rejectData,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: Text("Reject",style: GoogleFonts.sulphurPoint(),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

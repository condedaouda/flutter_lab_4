import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flip_panel/flip_panel.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  DateTime selectedDate = DateTime.now().toLocal();
  TimeOfDay selectedTime = TimeOfDay.fromDateTime(DateTime.now().toLocal());

  DateTime tempDate;

  initializeNotifications() async {
    var initializedAndroid = AndroidInitializationSettings('ic_launcher');
    var initializedIOS = IOSInitializationSettings();
    await localNotificationsPlugin.initialize(
      InitializationSettings(initializedAndroid, initializedIOS),
    );
  }

  @override
  void initState() {
    super.initState();
    initializeNotifications();
  }

  Widget _buildFlip(Duration duration) {
    return Center(
      child: SizedBox(
        height: 64.0,
        child: FlipClock.reverseCountdown(
          duration: duration,
          digitColor: Colors.white,
          backgroundColor: Colors.purpleAccent,
          digitSize: 34.0,
          borderRadius: const BorderRadius.all(Radius.circular(3.0)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lab 4',
      theme: ThemeData(primaryColor: Colors.purple),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Day Reminder'),
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 4,
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            elevation: 4.0,
            onPressed: () async {},
            child: Container(
              alignment: Alignment.center,
              height: 30.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(
                    Icons.date_range,
                    size: 16,
                  ),
                  Text(
                    "Choosen: ${(DateFormat.yMd().add_Hm().format(selectedDate)).toString()}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: tempDate == null
            ? Center(
                child: Text(
                  'Choose the date!\nCurrent time: ${(DateFormat.yMd().add_Hm().format(DateTime.now()))}',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              )
            : _buildFlip(tempDate.difference(DateTime.now())),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            backgroundColor: Colors.purpleAccent,
            child: Icon(Icons.notifications),
            onPressed: () async {
              setState(() {
                tempDate = null;
              });
              final DateTime picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2015, 8),
                lastDate: DateTime(2041),
              );

              final TimeOfDay pickedTime = await showTimePicker(
                context: context,
                initialTime: selectedTime,
                builder: (BuildContext context, Widget child) {
                  return MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(alwaysUse24HourFormat: false),
                    child: child,
                  );
                },
              );

              if (pickedTime != null &&
                  pickedTime != selectedTime &&
                  picked != null &&
                  picked != selectedDate) {
                setState(() {
                  selectedDate = DateTime(picked.year, picked.month, picked.day,
                      pickedTime.hour, pickedTime.minute);

                  tempDate = DateTime(
                    picked.year,
                    picked.month,
                    picked.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                });
                if (tempDate != null) {
                  await singleNotification(
                    tempDate.add(Duration(milliseconds: 200)),
                    'Reminder Notification',
                    'This is to remind you the duration you set is over',
                    98123871,
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Future singleNotification(
      DateTime datetime, String message, String subtext, int hashcode,
      {String sound}) async {
    var androidChannel = AndroidNotificationDetails(
      'channel-id',
      'channel-name',
      'channel-description',
      importance: Importance.Max,
      priority: Priority.Max,
    );

    var iosChannel = IOSNotificationDetails();

    var platformChannel = NotificationDetails(androidChannel, iosChannel);

    localNotificationsPlugin.schedule(
        hashcode, message, subtext, datetime, platformChannel,
        payload: hashcode.toString());
  }
}

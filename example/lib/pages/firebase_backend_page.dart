import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm_example/common_widgets/simple_button.dart';
import 'package:awesome_notifications_fcm_example/datasources/firebase_datasource.dart';
import 'package:awesome_notifications_fcm_example/main_complete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseBackendPage extends StatefulWidget {

  final String firebaseAppToken;
  final String packageName = 'me.carda.awesome_notifications_example';
  final String sharedLastKeyReference = 'FcmServerKey';
  final FirebaseDataSource firebaseDataSource = FirebaseDataSource();
  late final String prettyExampleMap;

  FirebaseBackendPage(this.firebaseAppToken){
    prettyExampleMap = AwesomeMapUtils.printPrettyMap(firebaseDataSource
      .getFirebaseExampleContent(
        firebaseAppToken: firebaseAppToken)
      );
  }

  @override
  _FirebaseBackendPageState createState() => _FirebaseBackendPageState();
}

class _FirebaseBackendPageState extends State<FirebaseBackendPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  String? serverKeyValidation(value) {
    if (value.isEmpty) {
      return 'The FCM server key is required';
    }

    if (!RegExp(r'^[A-z0-9\:\-\_]{150,}$').hasMatch(value)) {
      return 'Enter Valid FCM server key';
    }

    return null;
  }

  Future<String> getLastServerKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(widget.sharedLastKeyReference) ?? '';
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Firebase backend emulator', style: TextStyle(fontSize: 20)),
          leading: IconButton(
            alignment: Alignment.center,
            icon: Icon(FontAwesomeIcons.chevronLeft),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 10,
        ),
        body: FutureBuilder<String>(
          future: getLastServerKey(),
          builder: (context, AsyncSnapshot<String> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(CompleteApp.mainColor),
              ));
            } else {
              String lastServerKey = snapshot.data ?? '';
              final TextEditingController _serverKeyTextController =
                TextEditingController(text: lastServerKey);

              return GestureDetector(
                onTap: () {
                  // Focus out when tapped outside of form
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    children: <Widget>[
                      Text('Firebase App Token:'),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Text(widget.firebaseAppToken, style: TextStyle(
                            color: CompleteApp.mainColor,
                            fontWeight: FontWeight.bold
                        )),
                      ),
                      SimpleButton(
                        'Copy Firebase app token',
                        onPressed: () async {
                          if (widget.firebaseAppToken.isNotEmpty) {
                            Clipboard.setData(
                                ClipboardData(text: widget.firebaseAppToken));
                            Fluttertoast.showToast(msg: 'Token copied');
                          }
                        },
                      ),
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                minLines: 1, // Normal textInputField will be displayed
                                maxLines: 7, // when user presses enter it will adapt to it
                                keyboardType: TextInputType.multiline,
                                controller: _serverKeyTextController,
                                validator: serverKeyValidation,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.lock, color: CompleteApp.mainColor),
                                    labelText: ' Firebase Server Key ',
                                    hintText:
                                        'Paste here your Firebase server Key'),
                              )
                            ],
                          ),
                        ),
                      ),
                      Text("Push content example:"),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          color: Colors.grey.shade200,
                          child: Text(widget.prettyExampleMap)
                        ),
                      ),
                      SimpleButton(
                        'Copy push content example',
                        onPressed: () async {
                          Clipboard.setData(
                              ClipboardData(text: widget.firebaseAppToken));
                          Fluttertoast.showToast(msg: 'Push data copied');
                        },
                      ),
                      SimpleButton(
                        'Send Firebase request',
                        backgroundColor: CompleteApp.mainColor,
                        labelColor: Colors.white,
                        onPressed: () async {
                            String fcmServerKey =
                                _serverKeyTextController.value.text;
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            prefs.setString(
                                widget.sharedLastKeyReference, fcmServerKey);

                            if (
                              serverKeyValidation(fcmServerKey) == null ||
                              (_formKey.currentState?.validate() ?? false)
                            ) {
                              FocusScopeNode currentFocus = FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }

                              pushFirebaseNotification(
                                  Random().nextInt(AwesomeNotifications.maxID),
                                  fcmServerKey
                              );
                            }
                          },
                      )
                    ]),
              );
              }
            },
          )
        );
  }

  Future<String> pushFirebaseNotification(
      int id, String firebaseServerKey) async {
    return await widget.firebaseDataSource.pushBasicNotification(
        firebaseServerKey: firebaseServerKey,
        firebaseAppToken: widget.firebaseAppToken
    );
  }
}

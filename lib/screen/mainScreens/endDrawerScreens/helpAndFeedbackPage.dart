import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/widgets/bouncingButton.dart';

class FeedBack extends StatefulWidget {
  final UserDataModel user;
  FeedBack({this.user});
  @override
  _FeedBackState createState() => _FeedBackState();
}

class _FeedBackState extends State<FeedBack> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var subject = "";
  var body = "";
  var name = "";
  var mail = "";
  bool isLoaded = false;
  bool isSent = true;
  Size _size;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> sendIt() async {
    setState(() {
      isSent = false;
    });
    final FormState form = _formKey.currentState;
    form.save();
    String platformResponse;
    String username = 'rs@hellobatlabs.com';
    String password = 'Ritikfbd@7985';
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, mail)
      ..recipients.add('teamwowtalent@gmail.com')
      ..subject = 'User Feedback!'
      ..text = body
      ..html = "<h1>Customer FeedBack</h1>\n" +
          "<p>" +
          body +
          "</p>\n<p>The user email is - " +
          mail +
          "</p>";
    try {
      if (body != "") {
        final sendReport = await send(message, smtpServer);
        print('Message sent: ' + sendReport.toString());
        platformResponse = 'Feedback successfully sent';
      } else {
        platformResponse = 'Description can\'t be empty';
      }
    } catch (error) {
      print("Error occured");
      print(error);
      platformResponse = error.toString();
    } finally {
      setState(() {
        isSent = true;
      });
    }
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(platformResponse)));
  }

  getUser() async {
    name = widget.user.displayName;
    mail = widget.user.email;
    setState(() {
      isLoaded = true;
    });
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        toolbarHeight: 50,
        centerTitle: true,
        title: Text("Contact Us"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: isLoaded
          ? SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 15),
                      height: MediaQuery.of(context).size.height - 120,
                      width: MediaQuery.of(context).size.width,
                      child: ListView(children: <Widget>[
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Container(
                                  decoration: new BoxDecoration(
                                    color: Colors.grey[300],
                                    shape: BoxShape.rectangle,
                                    border: new Border.all(
                                      color: Colors.white,
                                      width: 1.0,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15.0)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: new TextFormField(
                                      initialValue: name,
                                      decoration: new InputDecoration(
                                          border: InputBorder.none,
                                          labelText: 'Name',
                                          labelStyle:
                                              TextStyle(color: Colors.black)),
                                      onChanged: (value) {
                                        name = value;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 20),
                          child: Container(
                            decoration: new BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.rectangle,
                              border: new Border.all(
                                color: Colors.white,
                                width: 1.0,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: new TextFormField(
                                onChanged: (value) {
                                  mail = value;
                                },
                                initialValue: mail,
                                decoration: new InputDecoration(
                                    border: InputBorder.none,
                                    labelText: 'Email Address',
                                    labelStyle: TextStyle(color: Colors.black)),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 20),
                          child: Container(
                            decoration: new BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.rectangle,
                              border: new Border.all(
                                color: Colors.white,
                                width: 1.0,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                            ),
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  decoration: new InputDecoration(
                                      border: InputBorder.none,
                                      labelText: 'Description',
                                      labelStyle:
                                          TextStyle(color: Colors.black)),
                                  onChanged: (value) {
                                    body = value;
                                  },
                                )),
                          ),
                        ),
                        SizedBox(
                          height: _size.height * 0.01,
                        ),
                        Container(
                          padding: EdgeInsets.all(30),
                          child: BouncingButton(
                            buttonText: isSent ? "Send" : "Sending",
                            height: _size.width * 0.14,
                            width: _size.width * 1,
                            buttonFunction: () {
                              sendIt();
                            },
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

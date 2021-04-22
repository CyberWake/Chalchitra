import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Chalchitra/imports.dart';

class ChatBubble extends StatelessWidget {
  final bool isMe;
  final String timestamp;
  final String message;
  const ChatBubble({
    Key key,
    this.isMe,
    this.timestamp,
    this.message,
  }) : assert(isMe != null && timestamp != null && message != null);

  @override
  Widget build(BuildContext context) {
    if (isMe) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppTheme.secondaryColor,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(30),
                            topLeft: Radius.circular(30),
                            bottomLeft: Radius.circular(30))),
                    child: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Text(
                        message,
                        style: TextStyle(
                            color: AppTheme.backgroundColor, fontSize: 17),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Text(
              timestamp,
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.grey,
              ),
              textAlign: TextAlign.end,
            )
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xFF454545), Color(0xFF2B2B2B)]),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                          topLeft: Radius.circular(30),
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Text(
                        message,
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Text(
              timestamp,
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.grey,
              ),
              textAlign: TextAlign.end,
            )
          ],
        ),
      );
    }
  }
}

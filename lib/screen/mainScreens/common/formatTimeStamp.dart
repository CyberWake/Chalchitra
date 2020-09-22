String formatDateTime({int millisecondsSinceEpoch}){
  DateTime uploadTimeStamp =
  DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
  String sentAt = uploadTimeStamp.toString();
  Duration difference = DateTime.now().difference(DateTime.parse(sentAt));

  if(difference.inDays > 0){
    if(difference.inDays > 365){
      sentAt = (difference.inDays / 365).floor().toString() + ' years';
    }
    if(difference.inDays > 30 && difference.inDays < 365){
      sentAt = (difference.inDays / 30).floor().toString() + ' months';
    }
    if(difference.inDays >=1 && difference.inDays < 305){
      sentAt = difference.inDays.floor().toString() + ' days';
    }
  }
  else if(difference.inHours > 0){
    sentAt = difference.inHours.toString() + ' hours';
  }
  else if(difference.inMinutes > 0){
    sentAt = difference.inMinutes.toString() + ' mins';
  }
  else{
    sentAt = difference.inSeconds.toString() + ' secs';
  }

  return sentAt;
}

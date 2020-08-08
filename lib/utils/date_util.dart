import 'package:intl/intl.dart';

class DateUtil {
  static String getDateFormat(int value, [String format]) {
    String dateFormat = "dd MMMM y; HH:mm";
    if (format != null) {
      dateFormat = format;
    }
    if (value != null && value > 0) {
      return DateFormat(dateFormat).format(DateTime.fromMicrosecondsSinceEpoch(value * 1000));
    }
    return "";
  }

  // TODO Today, HH:mm or Tomorrow, HH:mm or dd MMMM y, HH:mm
  static String getPresenceDateFormat(int value) {
    String dateFormat = "dd MMMM y, HH:mm";
    if (value != null && value > 0) {
      return DateFormat(dateFormat).format(DateTime.fromMicrosecondsSinceEpoch(value * 1000));
    }
    return "";
  }

  static int parseDateToMilliseconds(String value, [String format]) {
    String dateFormat = "dd MMMM y; HH:mm";
    if (format != null) {
      dateFormat = format;
    }
    if (value != null && value != "") {
      return DateFormat(dateFormat).parse(value).millisecondsSinceEpoch;
    }
    return 0;
  }

  static DateTime parseDateTime(String value, [String format]) {
    String dateFormat = "dd MMMM y; HH:mm";
    if (format != null) {
      dateFormat = format;
    }
    if (value != null && value != "") {
      return DateFormat(dateFormat).parse(value);
    }
    return null;
  }

  static String getTimeDifferent(int value) {
    if (value == null) {
      return "NA";
    }
    DateTime now = DateTime.now();
    int diffSecs = ((now.millisecondsSinceEpoch - value)/1000).floor();

    int seconds = 0;
    int minutes = 0;
    int hours = 0;
    if (diffSecs > 60) {
      seconds = (diffSecs%60);
      int diffMins = (diffSecs/60).floor();
      if (diffMins > 60) {
        minutes = (diffMins%60);
        hours = (diffMins/60).floor();
      } else {
        minutes = diffMins;
      }
    } else {
      seconds = diffSecs;
    }

    String strOfHours = "";
    String strOfMinutes = "";
    String strOfSeconds = "";
    if (hours > 18) {
      return getDateFormat(value);
    } else {
      if (hours > 0) {
        strOfHours = "${hours} hour${(hours>1?"s":"")} ";
      }
      if (minutes > 0) {
        strOfMinutes = "${minutes} minute${(minutes>1?"s":"")} ";
      }
      if (seconds > 0 && !(hours > 0 && minutes > 0)) {
        strOfSeconds = "${seconds} second${(seconds>1?"s":"")} ";
      }
    }

    return "${strOfHours}${strOfMinutes}${strOfSeconds}ago.";
  }
}
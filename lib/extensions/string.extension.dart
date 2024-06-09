extension StringExtension on String {
  String removeExtraAngleBrackets() {
    final regex = RegExp(r"(<)+");
    return replaceAll(regex, ' ');
  }

  DateTime parseDateMrzString() {
    if (length != 8) {
      throw const FormatException(
          "Invalid date string format. Must be YYYYMMDD");
    }
    int year = int.parse(substring(0, 4));
    int month = int.parse(substring(4, 6));
    int day = int.parse(substring(6));
    return DateTime(year, month, day);
  }

  DateTime formatMrzDate({bool isExpired = false}) {
    int year = int.parse(substring(0, 2));
    int currentYear = DateTime.now().year;
    int parsedYear = int.parse(currentYear.toString().substring(2));
    int parsedCentury = int.parse(currentYear.toString().substring(0, 2));
    String newDate = "$parsedCentury$this";
    if (!isExpired) {
      if (parsedYear < year) {
        newDate = "${parsedCentury - 1}$this";
      }
    }

    return newDate.parseDateMrzString();
  }

  Iterable<Match> matches(RegExp regex) => regex.allMatches(this);
}

RegExp standarRegex =
    RegExp(r"([A|C|I][A-Z0-9<]{1})([A-Z]{3})([A-Z0-9<]{9})([0-9]{1})");

RegExp firstLineregex = RegExp(
    r"([A|C|I][A-Z0-9<]{1})([A-Z]{3})([A-Z0-9<]{9})([0-9]{1})([A-Z0-9<]{15})");

RegExp secondLineRegex = RegExp(
    r"([0-9]{6})([0-9]{1})([M|F|X|<]{1})([0-9]{6})([0-9]{1})([A-Z]{3})([A-Z0-9<]{11})([0-9]{1})");

RegExp thirdLineRegex = RegExp(r"([A-Z0-9<]{30})");

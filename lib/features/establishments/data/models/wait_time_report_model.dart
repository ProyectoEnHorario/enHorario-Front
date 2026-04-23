class WaitTimeReportModel {
  WaitTimeReportModel({required this.minutes});

  final int minutes;

  Map<String, dynamic> toMap() {
    return {
      'minutes': minutes,
    };
  }
}

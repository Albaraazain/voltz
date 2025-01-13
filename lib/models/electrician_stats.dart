class ElectricianStats {
  final String id;
  final int todayJobs;
  final int newRequests;
  final double weeklyEarnings;
  final double rating;
  final List<EarningsDataPoint> earningsData;
  final int unreadNotifications;

  const ElectricianStats({
    this.id = '',
    required this.todayJobs,
    required this.newRequests,
    required this.weeklyEarnings,
    required this.rating,
    required this.earningsData,
    required this.unreadNotifications,
  });
}

class EarningsDataPoint {
  final int index;
  final double value;

  const EarningsDataPoint({
    required this.index,
    required this.value,
  });
}

class SessionCostBreakdown {
  const SessionCostBreakdown({
    required this.onlineMinutes,
    required this.offlineMinutes,
    required this.onlineCost,
    required this.offlineCost,
    required this.totalCost,
  });

  final int onlineMinutes;
  final int offlineMinutes;

  final double onlineCost;
  final double offlineCost;

  final double totalCost;
}

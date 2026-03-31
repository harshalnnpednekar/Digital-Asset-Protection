class ThreatTimelineItem {
  final String assetName;
  final String platform;
  final String matchPercent;
  final String timestamp;
  final String status; // 'PIRACY' | 'REVIEWING' | 'DISMISSED'

  const ThreatTimelineItem({
    required this.assetName,
    required this.platform,
    required this.matchPercent,
    required this.timestamp,
    required this.status,
  });
}

class PlatformStat {
  final String platform;
  final double percentage;

  const PlatformStat({
    required this.platform,
    required this.percentage,
  });
}

class PatientZeroDetection {
  final String partnerName;
  final String assetName;
  
  const PatientZeroDetection({
    required this.partnerName,
    required this.assetName,
  });
}

class PatientZeroRecord {
  final String assetName;
  final String leakSource;
  final String platform;
  final String timestamp;
  final String status;

  const PatientZeroRecord({
    required this.assetName,
    required this.leakSource,
    required this.platform,
    required this.timestamp,
    required this.status,
  });
}

// TODO: REPLACE WITH FIRESTORE STREAM
class DashboardMockData {
  DashboardMockData._();

  static const List<ThreatTimelineItem> timelineEvents = [
    ThreatTimelineItem(assetName: "IPL 2025 — MI vs CSK Full Highlights", platform: "YouTube", matchPercent: "94.2", timestamp: "2 min ago", status: "PIRACY"),
    ThreatTimelineItem(assetName: "Champions Trophy Press Conference", platform: "Telegram", matchPercent: "88.7", timestamp: "14 min ago", status: "PIRACY"),
    ThreatTimelineItem(assetName: "Training Session — Mumbai Indians", platform: "X (Twitter)", matchPercent: "67.3", timestamp: "31 min ago", status: "REVIEWING"),
    ThreatTimelineItem(assetName: "Match Preview — RCB vs KKR", platform: "Reddit", matchPercent: "91.8", timestamp: "1h 12m ago", status: "PIRACY"),
    ThreatTimelineItem(assetName: "IPL Opening Ceremony 2025", platform: "YouTube", matchPercent: "52.1", timestamp: "2h 4m ago", status: "DISMISSED"),
    ThreatTimelineItem(assetName: "Post-Match Interview — Rohit Sharma", platform: "Telegram", matchPercent: "83.4", timestamp: "3h 17m ago", status: "REVIEWING"),
    ThreatTimelineItem(assetName: "Promo Reel — Season 18 Launch", platform: "X (Twitter)", matchPercent: "76.9", timestamp: "5h 2m ago", status: "DISMISSED"),
    ThreatTimelineItem(assetName: "Quarter Final Highlights — MI vs DC", platform: "YouTube", matchPercent: "97.1", timestamp: "6h 48m ago", status: "PIRACY"),
  ];

  static const List<PlatformStat> platformStats = [
    PlatformStat(platform: "X (Twitter)", percentage: 38.0),
    PlatformStat(platform: "Telegram", percentage: 29.0),
    PlatformStat(platform: "YouTube", percentage: 18.0),
    PlatformStat(platform: "Reddit", percentage: 9.0),
    PlatformStat(platform: "Other", percentage: 6.0),
  ];

  static const List<PatientZeroDetection> recentDetections = [
    PatientZeroDetection(partnerName: "StreamMax India", assetName: "IPL 2025 MI vs CSK Highlights"),
    PatientZeroDetection(partnerName: "Employee: R. Mehta", assetName: "Champions Trophy Press Conf."),
    PatientZeroDetection(partnerName: "DSport Partner", assetName: "Training Session — Mumbai Indians"),
  ];

  static const List<PatientZeroRecord> patientZeroRecords = [
    PatientZeroRecord(assetName: "IPL 2025 Final Highlights", leakSource: "Partner: StreamMax India", platform: "YouTube", timestamp: "Jan 15, 02:17 UTC", status: "DMCA FILED"),
    PatientZeroRecord(assetName: "Champions Trophy Ceremony", leakSource: "Employee: R. Mehta", platform: "Telegram", timestamp: "Jan 14, 18:43 UTC", status: "INVESTIGATING"),
    PatientZeroRecord(assetName: "MI Training Camp Footage", leakSource: "Partner: DSport", platform: "X (Twitter)", timestamp: "Jan 13, 11:22 UTC", status: "RESOLVED"),
    PatientZeroRecord(assetName: "Season 18 Promo Reel", leakSource: "Partner: Sony LIV", platform: "Reddit", timestamp: "Jan 12, 09:05 UTC", status: "DMCA FILED"),
  ];
}

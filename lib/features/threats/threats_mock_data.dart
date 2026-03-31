class ThreatAlert {
  final String threatId;
  final String matchedAssetName;
  final String platform;
  final double visualSimilarity;  // 0.0 to 1.0
  final double audioSimilarity;   // 0.0 to 1.0
  final String scrapedCaption;
  final String geminiIntent;      // 'PIRACY' | 'FAIR_USE' | 'REVIEWING'
  final double geminiConfidence;  // 0.0 to 1.0
  final String geminiReasoning;
  final String detectionTime;
  final String status;            // 'ACTIVE' | 'DISMISSED' | 'DMCA_FILED'
  final String distributionTarget;
  final String decryptedLeakSource;
  final String patientZeroTimestamp;

  const ThreatAlert({
    required this.threatId,
    required this.matchedAssetName,
    required this.platform,
    required this.visualSimilarity,
    required this.audioSimilarity,
    required this.scrapedCaption,
    required this.geminiIntent,
    required this.geminiConfidence,
    required this.geminiReasoning,
    required this.detectionTime,
    required this.status,
    required this.distributionTarget,
    required this.decryptedLeakSource,
    required this.patientZeroTimestamp,
  });

  ThreatAlert copyWith({
    String? status,
  }) {
    return ThreatAlert(
      threatId: threatId,
      matchedAssetName: matchedAssetName,
      platform: platform,
      visualSimilarity: visualSimilarity,
      audioSimilarity: audioSimilarity,
      scrapedCaption: scrapedCaption,
      geminiIntent: geminiIntent,
      geminiConfidence: geminiConfidence,
      geminiReasoning: geminiReasoning,
      detectionTime: detectionTime,
      status: status ?? this.status,
      distributionTarget: distributionTarget,
      decryptedLeakSource: decryptedLeakSource,
      patientZeroTimestamp: patientZeroTimestamp,
    );
  }
}

// TODO: REPLACE WITH FIRESTORE REALTIME STREAM
class ThreatsMockData {
  ThreatsMockData._();

  static const List<ThreatAlert> alerts = [
    ThreatAlert(
      threatId: "THR-001",
      matchedAssetName: "IPL 2025 — MI vs CSK Highlights",
      platform: "YouTube",
      visualSimilarity: 0.942,
      audioSimilarity: 0.887,
      scrapedCaption: "Full match free HD download — no copyright @ipl_free_streams",
      geminiIntent: "PIRACY",
      geminiConfidence: 0.961,
      geminiReasoning: "Account has no official affiliation. Caption explicitly states 'no copyright' indicating unauthorized distribution intent. Video is 94.2% temporally aligned with vaulted master.",
      detectionTime: "2 min ago",
      status: "ACTIVE",
      distributionTarget: "Partner: StreamMax India",
      decryptedLeakSource: "StreamMax India (Contract ID: STR-MX-7F2A)",
      patientZeroTimestamp: "Jan 15, 09:32 UTC",
    ),
    ThreatAlert(
      threatId: "THR-002",
      matchedAssetName: "Champions Trophy Final Press Conference",
      platform: "Telegram",
      visualSimilarity: 0.887,
      audioSimilarity: 0.812,
      scrapedCaption: "Watch the full press conf here — unofficial mirror link",
      geminiIntent: "PIRACY",
      geminiConfidence: 0.884,
      geminiReasoning: "Telegram channel operates with no official press credentials. 'Unofficial mirror' language confirms deliberate redistribution of protected content.",
      detectionTime: "14 min ago",
      status: "ACTIVE",
      distributionTarget: "Broadcast: Sony LIV",
      decryptedLeakSource: "Sony LIV Partnership (Ref: SL-BC-442)",
      patientZeroTimestamp: "Jan 14, 18:43 UTC",
    ),
    ThreatAlert(
      threatId: "THR-003",
      matchedAssetName: "MI Pre-Season Training Camp",
      platform: "X (Twitter)",
      visualSimilarity: 0.673,
      audioSimilarity: 0.541,
      scrapedCaption: "Amazing training session breakdown — fan analysis thread",
      geminiIntent: "FAIR_USE",
      geminiConfidence: 0.723,
      geminiReasoning: "Account is a verified cricket analyst. Content is clearly commentary and analysis of publicly available information. No full video reproduction detected.",
      detectionTime: "31 min ago",
      status: "DISMISSED",
      distributionTarget: "Employee: R. Mehta",
      decryptedLeakSource: "R. Mehta, Video Lead (UID: EMP-0047)",
      patientZeroTimestamp: "Jan 13, 11:22 UTC",
    ),
    ThreatAlert(
      threatId: "THR-004",
      matchedAssetName: "RCB vs KKR Quarter Final",
      platform: "Reddit",
      visualSimilarity: 0.918,
      audioSimilarity: 0.876,
      scrapedCaption: "Full highlights 1080p free — r/CricketLeaks",
      geminiIntent: "PIRACY",
      geminiConfidence: 0.941,
      geminiReasoning: "Posted to a subreddit dedicated to unauthorized content. Video is complete, unmodified, and clearly the protected asset. High-confidence piracy.",
      detectionTime: "1h 12m ago",
      status: "ACTIVE",
      distributionTarget: "Partner: DSport",
      decryptedLeakSource: "DSport Distribution (Ref: DS-2025-Q1)",
      patientZeroTimestamp: "Jan 13, 08:15 UTC",
    ),
    ThreatAlert(
      threatId: "THR-005",
      matchedAssetName: "IPL Opening Ceremony 2025",
      platform: "YouTube",
      visualSimilarity: 0.521,
      audioSimilarity: 0.489,
      scrapedCaption: "IPL 2025 opening ceremony reaction and highlights discussion",
      geminiIntent: "FAIR_USE",
      geminiConfidence: 0.812,
      geminiReasoning: "Content is clearly a reaction video format with significant commentary overlay. Audio similarity below threshold. Qualifies as fair use under commentary exception.",
      detectionTime: "2h 4m ago",
      status: "DISMISSED",
      distributionTarget: "Broadcast: JioCinema",
      decryptedLeakSource: "JioCinema Broadcast (Contract: JC-2025-IPL)",
      patientZeroTimestamp: "Jan 12, 16:30 UTC",
    ),
    ThreatAlert(
      threatId: "THR-006",
      matchedAssetName: "Post-Match Interview — Rohit Sharma",
      platform: "Telegram",
      visualSimilarity: 0.834,
      audioSimilarity: 0.791,
      scrapedCaption: "Rohit interview full — download link in bio",
      geminiIntent: "PIRACY",
      geminiConfidence: 0.876,
      geminiReasoning: "Download link in bio indicates active piracy distribution beyond platform. 83.4% visual match with explicit download facilitation.",
      detectionTime: "3h 17m ago",
      status: "DMCA_FILED",
      distributionTarget: "Partner: StreamMax India",
      decryptedLeakSource: "StreamMax India (Contract ID: STR-MX-7F2A)",
      patientZeroTimestamp: "Jan 12, 13:47 UTC",
    ),
    ThreatAlert(
      threatId: "THR-007",
      matchedAssetName: "Season 18 Promo Reel",
      platform: "X (Twitter)",
      visualSimilarity: 0.769,
      audioSimilarity: 0.823,
      scrapedCaption: "This promo is incredible — sharing for all fans!",
      geminiIntent: "REVIEWING",
      geminiConfidence: 0.612,
      geminiReasoning: "Content appears to be fan sharing of promotional material. Confidence level insufficient for automatic classification. Manual review recommended.",
      detectionTime: "5h 2m ago",
      status: "ACTIVE",
      distributionTarget: "Partner: DSport",
      decryptedLeakSource: "DSport Distribution (Ref: DS-2025-Q1)",
      patientZeroTimestamp: "Jan 11, 10:20 UTC",
    ),
  ];
}

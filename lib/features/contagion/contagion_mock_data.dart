class ContagionNode {
  final String id;
  final String label;         // display name: platform handle, URL snippet
  final String platform;      // YouTube, Telegram, X, Reddit, Web, Internal
  final String tier;          // ROOT | T1 | T2 | T3
  final String detectedAt;
  final String estimatedReach; // "142K views", "89K members"
  final String ipAddress;      // Forensic detail: 103.21.x.x
  final String sourceUrl;      // Direct link evidence
  final String? parentId;     // null for root

  const ContagionNode({
    required this.id,
    required this.label,
    required this.platform,
    required this.tier,
    required this.detectedAt,
    required this.estimatedReach,
    required this.ipAddress,
    required this.sourceUrl,
    this.parentId,
  });
}

class ContagionMockData {
  ContagionMockData._();

  static const List<ContagionNode> nodes = [
    // ROOT
    ContagionNode(
      id: "N0", 
      label: "StreamMax India (LEAK SOURCE)", 
      platform: "Internal", 
      tier: "ROOT", 
      detectedAt: "Jan 14, 09:32 UTC", 
      estimatedReach: "ORIGIN", 
      ipAddress: "10.0.4.112",
      sourceUrl: "internal://staging-leak.srv",
      parentId: null
    ),

    // T1 (3 nodes)
    ContagionNode(
      id: "N1", 
      label: "@ipl_free_streams_yt", 
      platform: "YouTube", 
      tier: "T1", 
      detectedAt: "Jan 14, 11:17 UTC", 
      estimatedReach: "284K views", 
      ipAddress: "172.217.167.78",
      sourceUrl: "https://youtube.com/watch?v=ipl_leak",
      parentId: "N0"
    ),
    ContagionNode(
      id: "N2", 
      label: "t.me/ipl_leaks_2025", 
      platform: "Telegram", 
      tier: "T1", 
      detectedAt: "Jan 14, 11:43 UTC", 
      estimatedReach: "67K members", 
      ipAddress: "149.154.167.220",
      sourceUrl: "https://t.me/ipl_leaks_2025/12",
      parentId: "N0"
    ),
    ContagionNode(
      id: "N3", 
      label: "r/CricketLeaks post", 
      platform: "Reddit", 
      tier: "T1", 
      detectedAt: "Jan 14, 12:01 UTC", 
      estimatedReach: "38K upvotes", 
      ipAddress: "151.101.129.140",
      sourceUrl: "https://reddit.com/r/CricketLeaks/c12",
      parentId: "N0"
    ),

    // T2 (6 nodes)
    ContagionNode(
      id: "N4", 
      label: "@cricket_hd_free", 
      platform: "YouTube", 
      tier: "T2", 
      detectedAt: "Jan 14, 14:22 UTC", 
      estimatedReach: "91K views", 
      ipAddress: "172.217.167.78",
      sourceUrl: "https://youtube.com/watch?v=hd_mirror",
      parentId: "N1"
    ),
    ContagionNode(
      id: "N5", 
      label: "t.me/sports_mirror1", 
      platform: "Telegram", 
      tier: "T2", 
      detectedAt: "Jan 14, 15:04 UTC", 
      estimatedReach: "22K members", 
      ipAddress: "149.154.167.220",
      sourceUrl: "https://t.me/sports_mirror1/5",
      parentId: "N1"
    ),
    ContagionNode(
      id: "N6", 
      label: "t.me/ipl_backup_ch", 
      platform: "Telegram", 
      tier: "T2", 
      detectedAt: "Jan 14, 16:30 UTC", 
      estimatedReach: "31K members", 
      ipAddress: "149.154.167.221",
      sourceUrl: "https://t.me/ipl_backup_ch/1",
      parentId: "N2"
    ),
    ContagionNode(
      id: "N7", 
      label: "freedownload-ipl.xyz", 
      platform: "Web", 
      tier: "T2", 
      detectedAt: "Jan 14, 17:15 UTC", 
      estimatedReach: "~150K hits", 
      ipAddress: "45.133.122.14",
      sourceUrl: "https://freedownload-ipl.xyz/index",
      parentId: "N2"
    ),
    ContagionNode(
      id: "N8", 
      label: "r/sportspiracy mirror", 
      platform: "Reddit", 
      tier: "T2", 
      detectedAt: "Jan 14, 18:00 UTC", 
      estimatedReach: "12K views", 
      ipAddress: "151.101.129.141",
      sourceUrl: "https://reddit.com/r/sportspiracy/m1",
      parentId: "N3"
    ),
    ContagionNode(
      id: "N9", 
      label: "@ipl_clips_daily", 
      platform: "X (Twitter)", 
      tier: "T2", 
      detectedAt: "Jan 14, 18:44 UTC", 
      estimatedReach: "67K views", 
      ipAddress: "104.244.42.129",
      sourceUrl: "https://x.com/ipl_clips/12",
      parentId: "N3"
    ),

    // T3 (8 nodes)
    ContagionNode(
      id: "N10", 
      label: "t.me/ipl_re1", 
      platform: "Telegram", 
      tier: "T3", 
      detectedAt: "Jan 15, 01:10 UTC", 
      estimatedReach: "8K members", 
      ipAddress: "149.154.167.222",
      sourceUrl: "https://t.me/ipl_re1/8",
      parentId: "N4"
    ),
    ContagionNode(
      id: "N11", 
      label: "mega.nz/ipl-file", 
      platform: "Web", 
      tier: "T3", 
      detectedAt: "Jan 15, 02:33 UTC", 
      estimatedReach: "~40K downloads", 
      ipAddress: "31.216.144.5",
      sourceUrl: "https://mega.nz/ipl-leaked",
      parentId: "N4"
    ),
    ContagionNode(
      id: "N12", 
      label: "streamlare.com/ipl", 
      platform: "Web", 
      tier: "T3", 
      detectedAt: "Jan 15, 03:17 UTC", 
      estimatedReach: "~27K views", 
      ipAddress: "172.67.144.112",
      sourceUrl: "https://streamlare.com/ipl/view",
      parentId: "N5"
    ),
    ContagionNode(
      id: "N13", 
      label: "@cricket_yt_mirror", 
      platform: "YouTube", 
      tier: "T3", 
      detectedAt: "Jan 15, 04:00 UTC", 
      estimatedReach: "18K views", 
      ipAddress: "172.217.167.79",
      sourceUrl: "https://youtube.com/watch?v=ipl_mirror",
      parentId: "N6"
    ),
    ContagionNode(
      id: "N14", 
      label: "t.me/ipl_final_leak", 
      platform: "Telegram", 
      tier: "T3", 
      detectedAt: "Jan 15, 04:45 UTC", 
      estimatedReach: "15K members", 
      ipAddress: "149.154.167.223",
      sourceUrl: "https://t.me/ipl_final_leak/3",
      parentId: "N7"
    ),
    ContagionNode(
      id: "N15", 
      label: "gofile.io/ipl", 
      platform: "Web", 
      tier: "T3", 
      detectedAt: "Jan 15, 05:20 UTC", 
      estimatedReach: "~33K downloads", 
      ipAddress: "188.114.97.2",
      sourceUrl: "https://gofile.io/ipl/files",
      parentId: "N8"
    ),
    ContagionNode(
      id: "N16", 
      label: "@leaked_ipl", 
      platform: "X (Twitter)", 
      tier: "T3", 
      detectedAt: "Jan 15, 06:01 UTC", 
      estimatedReach: "29K views", 
      ipAddress: "104.244.42.130",
      sourceUrl: "https://x.com/leaked_ipl/post1",
      parentId: "N9"
    ),
    ContagionNode(
      id: "N17", 
      label: "t.me/ipl_last_copy", 
      platform: "Telegram", 
      tier: "T3", 
      detectedAt: "Jan 15, 07:14 UTC", 
      estimatedReach: "9K members", 
      ipAddress: "149.154.167.224",
      sourceUrl: "https://t.me/ipl_last_copy/1",
      parentId: "N9"
    ),
  ];
}

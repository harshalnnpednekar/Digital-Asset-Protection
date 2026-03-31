class ContagionNode {
  final String id;
  final String label;         // display name: platform handle, URL snippet
  final String platform;      // YouTube, Telegram, X, Reddit, Web, Internal
  final String tier;          // ROOT | T1 | T2 | T3
  final String detectedAt;
  final String estimatedReach; // "142K views", "89K members"
  final String? parentId;     // null for root

  const ContagionNode({
    required this.id,
    required this.label,
    required this.platform,
    required this.tier,
    required this.detectedAt,
    required this.estimatedReach,
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
      estimatedReach: "—", 
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
      parentId: "N0"
    ),
    ContagionNode(
      id: "N2", 
      label: "t.me/ipl_leaks_2025", 
      platform: "Telegram", 
      tier: "T1", 
      detectedAt: "Jan 14, 11:43 UTC", 
      estimatedReach: "67K members", 
      parentId: "N0"
    ),
    ContagionNode(
      id: "N3", 
      label: "r/CricketLeaks post", 
      platform: "Reddit", 
      tier: "T1", 
      detectedAt: "Jan 14, 12:01 UTC", 
      estimatedReach: "38K upvotes", 
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
      parentId: "N1"
    ),
    ContagionNode(
      id: "N5", 
      label: "t.me/sports_mirror1", 
      platform: "Telegram", 
      tier: "T2", 
      detectedAt: "Jan 14, 15:04 UTC", 
      estimatedReach: "22K members", 
      parentId: "N1"
    ),
    ContagionNode(
      id: "N6", 
      label: "t.me/ipl_backup_ch", 
      platform: "Telegram", 
      tier: "T2", 
      detectedAt: "Jan 14, 16:30 UTC", 
      estimatedReach: "31K members", 
      parentId: "N2"
    ),
    ContagionNode(
      id: "N7", 
      label: "freedownload-ipl.xyz", 
      platform: "Web", 
      tier: "T2", 
      detectedAt: "Jan 14, 17:15 UTC", 
      estimatedReach: "~150K hits", 
      parentId: "N2"
    ),
    ContagionNode(
      id: "N8", 
      label: "r/sportspiracy mirror", 
      platform: "Reddit", 
      tier: "T2", 
      detectedAt: "Jan 14, 18:00 UTC", 
      estimatedReach: "12K views", 
      parentId: "N3"
    ),
    ContagionNode(
      id: "N9", 
      label: "@ipl_clips_daily", 
      platform: "X (Twitter)", 
      tier: "T2", 
      detectedAt: "Jan 14, 18:44 UTC", 
      estimatedReach: "67K views", 
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
      parentId: "N4"
    ),
    ContagionNode(
      id: "N11", 
      label: "mega.nz/ipl-file", 
      platform: "Web", 
      tier: "T3", 
      detectedAt: "Jan 15, 02:33 UTC", 
      estimatedReach: "~40K downloads", 
      parentId: "N4"
    ),
    ContagionNode(
      id: "N12", 
      label: "streamlare.com/ipl", 
      platform: "Web", 
      tier: "T3", 
      detectedAt: "Jan 15, 03:17 UTC", 
      estimatedReach: "~27K views", 
      parentId: "N5"
    ),
    ContagionNode(
      id: "N13", 
      label: "@cricket_yt_mirror", 
      platform: "YouTube", 
      tier: "T3", 
      detectedAt: "Jan 15, 04:00 UTC", 
      estimatedReach: "18K views", 
      parentId: "N6"
    ),
    ContagionNode(
      id: "N14", 
      label: "t.me/ipl_final_leak", 
      platform: "Telegram", 
      tier: "T3", 
      detectedAt: "Jan 15, 04:45 UTC", 
      estimatedReach: "15K members", 
      parentId: "N7"
    ),
    ContagionNode(
      id: "N15", 
      label: "gofile.io/ipl", 
      platform: "Web", 
      tier: "T3", 
      detectedAt: "Jan 15, 05:20 UTC", 
      estimatedReach: "~33K downloads", 
      parentId: "N8"
    ),
    ContagionNode(
      id: "N16", 
      label: "@leaked_ipl", 
      platform: "X (Twitter)", 
      tier: "T3", 
      detectedAt: "Jan 15, 06:01 UTC", 
      estimatedReach: "29K views", 
      parentId: "N9"
    ),
    ContagionNode(
      id: "N17", 
      label: "t.me/ipl_last_copy", 
      platform: "Telegram", 
      tier: "T3", 
      detectedAt: "Jan 15, 07:14 UTC", 
      estimatedReach: "9K members", 
      parentId: "N9"
    ),
  ];
}

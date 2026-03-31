class VaultedAsset {
  final String id;
  final String name;
  final String category; // HIGHLIGHT | PRESS_CONF | TRAINING | PROMO
  final String distributionTarget;
  final String uploadDate;
  final String duration;
  final String fileSize;
  final String status; // VAULTED | PROCESSING | FAILED
  final bool c2paSecured;
  final double vectorizationProgress; // 0.0 to 1.0

  const VaultedAsset({
    required this.id,
    required this.name,
    required this.category,
    required this.distributionTarget,
    required this.uploadDate,
    required this.duration,
    required this.fileSize,
    required this.status,
    required this.c2paSecured,
    required this.vectorizationProgress,
  });
}

class VaultMockData {
  VaultMockData._();

  static const List<VaultedAsset> assets = [
    VaultedAsset(
      id: "1",
      name: "IPL 2025 — MI vs CSK — Full Highlights",
      category: "HIGHLIGHT",
      distributionTarget: "Partner: StreamMax India",
      uploadDate: "Jan 15, 2025",
      duration: "3:47:22",
      fileSize: "18.4 GB",
      status: "VAULTED",
      c2paSecured: true,
      vectorizationProgress: 1.0,
    ),
    VaultedAsset(
      id: "2",
      name: "Champions Trophy 2025 — Final Press Conference",
      category: "PRESS_CONF",
      distributionTarget: "Broadcast: Sony LIV",
      uploadDate: "Jan 14, 2025",
      duration: "0:52:11",
      fileSize: "3.1 GB",
      status: "VAULTED",
      c2paSecured: true,
      vectorizationProgress: 1.0,
    ),
    VaultedAsset(
      id: "3",
      name: "Mumbai Indians — Pre-Season Training Camp",
      category: "TRAINING",
      distributionTarget: "Employee: R. Mehta (Video Lead)",
      uploadDate: "Jan 13, 2025",
      duration: "1:24:05",
      fileSize: "7.8 GB",
      status: "VAULTED",
      c2paSecured: true,
      vectorizationProgress: 1.0,
    ),
    VaultedAsset(
      id: "4",
      name: "IPL Season 18 — Official Launch Promo",
      category: "PROMO",
      distributionTarget: "Partner: DSport",
      uploadDate: "Jan 12, 2025",
      duration: "0:03:30",
      fileSize: "0.9 GB",
      status: "VAULTED",
      c2paSecured: true,
      vectorizationProgress: 1.0,
    ),
    VaultedAsset(
      id: "5",
      name: "RCB vs KKR — Quarter Final Highlights",
      category: "HIGHLIGHT",
      distributionTarget: "Broadcast: JioCinema",
      uploadDate: "Jan 11, 2025",
      duration: "2:58:44",
      fileSize: "14.2 GB",
      status: "PROCESSING",
      c2paSecured: false,
      vectorizationProgress: 0.67,
    ),
    VaultedAsset(
      id: "6",
      name: "Season 18 Opening Ceremony — Full Event",
      category: "PROMO",
      distributionTarget: "Partner: StreamMax India",
      uploadDate: "Jan 10, 2025",
      duration: "4:10:00",
      fileSize: "24.7 GB",
      status: "VAULTED",
      c2paSecured: true,
      vectorizationProgress: 1.0,
    ),
  ];
}

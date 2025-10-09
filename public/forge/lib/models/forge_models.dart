// lib/models/forge_models.dart
// Minimal data models for the card preview.

class ForgeBuild {
  final String id;
  final String name;
  final int? tier; // 1..5
  final int derivedEmberScore; // fire badge
  final String? derivedStatus;  // e.g., "in_progress"
  final double livePrice;       // price number
  final List<String> trio;      // [cpu, gpu, case] labels

  const ForgeBuild({
    required this.id,
    required this.name,
    required this.tier,
    required this.derivedEmberScore,
    required this.derivedStatus,
    required this.livePrice,
    required this.trio,
  });

  ForgeBuild copyWith({String? name}) => ForgeBuild(
    id: id,
    name: name ?? this.name,
    tier: tier,
    derivedEmberScore: derivedEmberScore,
    derivedStatus: derivedStatus,
    livePrice: livePrice,
    trio: trio,
  );
}

class ForgeBuildBackData {
  const ForgeBuildBackData({
    required this.cpu,
    required this.gpu,
    required this.motherboard,
    required this.caseName,
    required this.ram,
    required this.storage1,
    this.storage2,
    required this.psuModel,
    required this.psuWatt,
    this.psuRating,
    required this.coolerType,
    this.coolerSize,
    this.metrics = const {},
    this.tags = const [],
    this.warrantyStatus,
    this.warrantyExpires,
    this.ownerName,
    this.buildAgeLabel,
    this.upgradePotential,
    this.upgradeNote,
  });

  final String cpu,
      gpu,
      motherboard,
      caseName,
      ram,
      storage1,
      psuModel,
      psuWatt,
      coolerType;
  final String? storage2, psuRating, coolerSize;
  final Map<String, String> metrics; // { 'idle_w': '65', 'peak_w': '420', 'timespy': '18,200' }
  final List<String> tags;
  final String? warrantyStatus, warrantyExpires, ownerName, buildAgeLabel, upgradePotential, upgradeNote;
}

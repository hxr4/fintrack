import 'package:budget_engine/budget_engine.dart';

enum GearKind { phone, laptop, bike, audio, power, other }

final class GearItem {
  const GearItem({
    required this.id,
    required this.kind,
    required this.name,
    this.variant = '',
    this.specs = '',
    this.imageAsset,
    this.photoId,
    this.purchaseDate,
    this.price,
    this.seller = '',
    this.warrantyEnd,
    this.notes = '',
    this.billPhotoId,
    this.sortOrder = 0,
  });

  final String id;
  final GearKind kind;
  final String name;
  final String variant;
  final String specs;
  final String? imageAsset;
  final String? photoId;
  final CivilDate? purchaseDate;
  final Money? price;
  final String seller;
  final CivilDate? warrantyEnd;
  final String notes;
  final String? billPhotoId;
  final int sortOrder;

  bool get isBike => kind == GearKind.bike;

  int? daysOwned(CivilDate today) {
    final bought = purchaseDate;
    if (bought == null) {
      return null;
    }
    final days = bought.daysUntil(today) + 1;
    return days < 1 ? 1 : days;
  }

  Money? costPerDay(CivilDate today) {
    final paid = price;
    final days = daysOwned(today);
    if (paid == null || days == null) {
      return null;
    }
    return paid.floorDiv(days);
  }

  int? warrantyDaysLeft(CivilDate today) => warrantyEnd == null ? null : today.daysUntil(warrantyEnd!);

  GearItem copyWith({
    String? name,
    String? variant,
    String? specs,
    String? photoId,
    CivilDate? purchaseDate,
    Money? price,
    String? seller,
    CivilDate? warrantyEnd,
    String? notes,
    String? billPhotoId,
    bool clearPurchaseDate = false,
    bool clearPrice = false,
    bool clearWarranty = false,
  }) =>
      GearItem(
        id: id,
        kind: kind,
        name: name ?? this.name,
        variant: variant ?? this.variant,
        specs: specs ?? this.specs,
        imageAsset: imageAsset,
        photoId: photoId ?? this.photoId,
        purchaseDate: clearPurchaseDate ? null : (purchaseDate ?? this.purchaseDate),
        price: clearPrice ? null : (price ?? this.price),
        seller: seller ?? this.seller,
        warrantyEnd: clearWarranty ? null : (warrantyEnd ?? this.warrantyEnd),
        notes: notes ?? this.notes,
        billPhotoId: billPhotoId ?? this.billPhotoId,
        sortOrder: sortOrder,
      );
}

final class ProfileDetails {
  const ProfileDetails({this.name = '', this.details = '', this.photoId});

  final String name;
  final String details;
  final String? photoId;

  ProfileDetails copyWith({String? name, String? details, String? photoId}) =>
      ProfileDetails(name: name ?? this.name, details: details ?? this.details, photoId: photoId ?? this.photoId);
}

abstract final class GearCatalog {
  static const items = [
    GearItem(
      id: 'gear-phone',
      kind: GearKind.phone,
      name: 'vivo X300 Pro',
      variant: 'Dune Gold',
      imageAsset: 'assets/gear/vivo-x300-pro-dune-gold.jpg',
      specs: 'MediaTek Dimensity 9500\n'
          '6.78" AMOLED, 2800 x 1260, 1-120 Hz LTPO\n'
          '16 GB RAM, 512 GB storage (the variant sold in India)\n'
          'ZEISS cameras: 50 MP main (Sony LYT-828), 50 MP ultra-wide, 200 MP 3.5x periscope; 50 MP front\n'
          '6510 mAh, 90 W FlashCharge\n'
          'IP68 and IP69, 226 g',
      sortOrder: 0,
    ),
    GearItem(
      id: 'gear-macbook',
      kind: GearKind.laptop,
      name: 'MacBook Air (M4)',
      variant: 'Midnight',
      imageAsset: 'assets/gear/macbook-air-m4-midnight.jpg',
      specs: 'Apple M4, 10-core CPU, up to 10-core GPU\n'
          '13.6" or 15.3" Liquid Retina, up to 500 nits\n'
          '16, 24 or 32 GB unified memory; 256 GB to 2 TB SSD\n'
          '12 MP Center Stage camera\n'
          'Up to 18 hours battery\n'
          'Two Thunderbolt ports, MagSafe, 3.5 mm jack; Wi-Fi 6E, Bluetooth 5.3',
      sortOrder: 1,
    ),
    GearItem(
      id: 'gear-loq',
      kind: GearKind.laptop,
      name: 'Lenovo LOQ 15IAX9',
      imageAsset: 'assets/gear/lenovo-loq-15iax9.jpg',
      specs: 'Intel Core i5-12450HX\n'
          'NVIDIA GeForce RTX 2050, 3050, 4050 or 4060 depending on model\n'
          '15.6" FHD IPS, 144 Hz, 300 nits, 100% sRGB, G-Sync\n'
          'DDR5-4800, two SO-DIMM slots, up to 32 GB\n'
          'Up to two M.2 NVMe SSDs\n'
          'USB-C 10 Gbps with 140 W PD and DisplayPort, HDMI, Ethernet, three USB-A',
      sortOrder: 2,
    ),
    GearItem(
      id: 'gear-bike',
      kind: GearKind.bike,
      name: 'Honda CB Hornet 160R',
      variant: '2018 CBS, Striking Green',
      imageAsset: 'assets/gear/cbhornet160rstrikinggreen.webp',
      specs: '162.7 cc air-cooled single, about 15 PS at 8,500 rpm, 14.5 Nm at 6,500 rpm\n'
          '5-speed gearbox\n'
          'Combined Braking System (CBS), 276 mm front disc and 220 mm rear disc\n'
          '12 litre tank, about 140 kg\n'
          'LED headlamp and digital console (2018 update)',
      sortOrder: 3,
    ),
    GearItem(
      id: 'gear-iem',
      kind: GearKind.audio,
      name: 'Headphone Zone x KZ Thunder',
      variant: '1 DD + 1 BA',
      imageAsset: 'assets/gear/kz-thunder.jpg',
      specs: 'Hybrid: one 10 mm dynamic driver and one balanced armature\n'
          '0.78 mm 2-pin (QDC) detachable cable\n'
          '3.5 mm cable with mic, or Type-C cable with built-in DAC and mic\n'
          '1 year warranty through Headphone Zone',
      sortOrder: 4,
    ),
    GearItem(
      id: 'gear-powerbank',
      kind: GearKind.power,
      name: 'Portronics Aqua 65',
      variant: '20,000 mAh, POR-3021',
      imageAsset: 'assets/gear/portronics-aqua-65.jpg',
      specs: '20,000 mAh\n'
          '65 W Type-C PD input and output\n'
          'Built-in braided Type-C cable, charges two devices at once\n'
          'LED percentage display, black\n'
          '12 months warranty',
      sortOrder: 5,
    ),
  ];
}

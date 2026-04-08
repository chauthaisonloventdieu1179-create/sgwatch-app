class JpDetail {
  final String? prefectureId;
  final String prefecture;
  final String wardTown;
  final String banchi;
  final String? buildingName;
  final String? roomNo;

  const JpDetail({
    this.prefectureId,
    required this.prefecture,
    required this.wardTown,
    required this.banchi,
    this.buildingName,
    this.roomNo,
  });

  factory JpDetail.fromJson(Map<String, dynamic> json) {
    // prefecture can be an object {prefecture_id, name} or a string
    String prefectureName = '';
    String? prefectureId;
    final pref = json['prefecture'];
    if (pref is Map<String, dynamic>) {
      prefectureName = pref['name']?.toString() ?? '';
      prefectureId = pref['prefecture_id']?.toString();
    } else if (pref != null) {
      prefectureName = pref.toString();
    }

    return JpDetail(
      prefectureId: prefectureId,
      prefecture: prefectureName,
      wardTown: json['ward_town']?.toString() ?? '',
      banchi: json['banchi']?.toString() ?? '',
      buildingName: json['building_name']?.toString(),
      roomNo: json['room_no']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prefecture': prefecture,
      'ward_town': wardTown,
      'banchi': banchi,
      'building_name': buildingName,
      'room_no': roomNo,
    };
  }

  String get fullAddress {
    final parts = [prefecture, wardTown, banchi]
        .where((s) => s.isNotEmpty)
        .toList();
    if (buildingName != null && buildingName!.isNotEmpty) {
      parts.add(buildingName!);
    }
    if (roomNo != null && roomNo!.isNotEmpty) {
      parts.add(roomNo!);
    }
    return parts.join(' ');
  }
}

class VnDetail {
  final String provinceCity;
  final String district;
  final String wardCommune;
  final String detailAddress;
  final String? buildingName;
  final String? roomNo;

  const VnDetail({
    required this.provinceCity,
    required this.district,
    required this.wardCommune,
    required this.detailAddress,
    this.buildingName,
    this.roomNo,
  });

  factory VnDetail.fromJson(Map<String, dynamic> json) {
    return VnDetail(
      provinceCity: json['province_city']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      wardCommune: json['ward_commune']?.toString() ?? '',
      detailAddress: json['detail_address']?.toString() ?? '',
      buildingName: json['building_name']?.toString(),
      roomNo: json['room_no']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'province_city': provinceCity,
      'district': district,
      'ward_commune': wardCommune,
      'detail_address': detailAddress,
      'building_name': buildingName,
      'room_no': roomNo,
    };
  }

  String get fullAddress {
    final parts = <String>[];
    if (detailAddress.isNotEmpty) parts.add(detailAddress);
    if (buildingName != null && buildingName!.isNotEmpty) {
      parts.add(buildingName!);
    }
    if (roomNo != null && roomNo!.isNotEmpty) {
      parts.add('P.$roomNo');
    }
    if (wardCommune.isNotEmpty) parts.add(wardCommune);
    if (district.isNotEmpty) parts.add(district);
    if (provinceCity.isNotEmpty) parts.add(provinceCity);
    return parts.join(', ');
  }
}

class AddressModel {
  final int? id;
  final String label;
  final String countryCode;
  final String inputMode;
  final String? postalCode;
  final String? phone;
  final String? imageUrl;
  final bool isDefault;
  final String? createdAt;
  final JpDetail? jpDetail;
  final VnDetail? vnDetail;

  const AddressModel({
    this.id,
    required this.label,
    required this.countryCode,
    this.inputMode = 'manual',
    this.postalCode,
    this.phone,
    this.imageUrl,
    this.isDefault = false,
    this.createdAt,
    this.jpDetail,
    this.vnDetail,
  });

  bool get isJp => countryCode == 'JP';
  bool get isVn => countryCode == 'VN';
  bool get isImageOnly => inputMode == 'image_only';

  String get fullAddress {
    if (jpDetail != null) return jpDetail!.fullAddress;
    if (vnDetail != null) return vnDetail!.fullAddress;
    return '';
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int?,
      label: json['label']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? 'JP',
      inputMode: json['input_mode']?.toString() ?? 'manual',
      postalCode: json['postal_code']?.toString(),
      phone: json['phone']?.toString(),
      imageUrl: json['image_url']?.toString(),
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: json['created_at']?.toString(),
      jpDetail: json['jp_detail'] != null
          ? JpDetail.fromJson(json['jp_detail'] as Map<String, dynamic>)
          : null,
      vnDetail: json['vn_detail'] != null
          ? VnDetail.fromJson(json['vn_detail'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'label': label,
      'country_code': countryCode,
      'input_mode': inputMode,
    };
    if (postalCode != null) map['postal_code'] = postalCode;
    if (phone != null) map['phone'] = phone;
    if (imageUrl != null) map['image_url'] = imageUrl;
    map['is_default'] = isDefault;
    if (jpDetail != null) map['jp_detail'] = jpDetail!.toJson();
    if (vnDetail != null) map['vn_detail'] = vnDetail!.toJson();
    return map;
  }
}

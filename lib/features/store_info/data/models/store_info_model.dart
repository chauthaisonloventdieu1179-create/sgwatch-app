import 'package:flutter/material.dart';

class StoreInfoItem {
  final IconData icon;
  final String text;

  const StoreInfoItem({required this.icon, required this.text});

  factory StoreInfoItem.fromJson(Map<String, dynamic> json) {
    return StoreInfoItem(
      icon: Icons.info_outline,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text};
  }
}

class StoreInfoModel {
  final String name;
  final String? imageUrl;
  final List<StoreInfoItem> infoItems;
  final String? mapUrl;

  const StoreInfoModel({
    required this.name,
    this.imageUrl,
    required this.infoItems,
    this.mapUrl,
  });

  factory StoreInfoModel.fromJson(Map<String, dynamic> json) {
    return StoreInfoModel(
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
      infoItems: (json['info_items'] as List<dynamic>?)
              ?.map((e) => StoreInfoItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      mapUrl: json['map_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image_url': imageUrl,
      'info_items': infoItems.map((e) => e.toJson()).toList(),
      'map_url': mapUrl,
    };
  }
}

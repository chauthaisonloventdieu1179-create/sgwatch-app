import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sgwatch_app/app/config/constants.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/features/address/data/models/address_model.dart';

class AddressRemoteDatasource {
  final ApiClient _apiClient;

  AddressRemoteDatasource(this._apiClient);

  /// GET /prefectures
  Future<List<Map<String, dynamic>>> getPrefectures() async {
    final response = await _apiClient.get(Endpoints.prefectures);
    final list = response.data['data']['prefectures'] as List;
    return list.cast<Map<String, dynamic>>();
  }

  /// GET /addresses
  Future<List<AddressModel>> getAddresses() async {
    final response = await _apiClient.get(Endpoints.addresses);
    final list = response.data['data']['addresses'] as List;
    return list
        .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /addresses/{id}
  Future<AddressModel> getAddress(int id) async {
    final response = await _apiClient.get('${Endpoints.addresses}/$id');
    final data = response.data['data']['address'] as Map<String, dynamic>;
    return AddressModel.fromJson(data);
  }

  /// POST /addresses (multipart/form-data)
  Future<AddressModel> createAddress(
    AddressModel address, {
    File? imageFile,
  }) async {
    final formData = await _buildFormData(address, imageFile: imageFile);
    final response = await _apiClient.post(Endpoints.addresses, data: formData);
    final data = response.data['data']['address'] as Map<String, dynamic>;
    return AddressModel.fromJson(data);
  }

  /// POST /addresses/{id} (multipart/form-data)
  Future<AddressModel> updateAddress(
    int id,
    AddressModel address, {
    File? imageFile,
  }) async {
    final formData = await _buildFormData(address, imageFile: imageFile);
    final response = await _apiClient.post(
      '${Endpoints.addresses}/$id',
      data: formData,
    );
    final data = response.data['data']['address'] as Map<String, dynamic>;
    return AddressModel.fromJson(data);
  }

  /// DELETE /addresses/{id}
  Future<void> deleteAddress(int id) async {
    await _apiClient.delete('${Endpoints.addresses}/$id');
  }

  /// Build multipart FormData from AddressModel
  Future<FormData> _buildFormData(
    AddressModel address, {
    File? imageFile,
  }) async {
    final map = <String, dynamic>{
      'label': address.label,
      'country_code': address.countryCode,
      'input_mode': address.inputMode,
      'is_default': address.isDefault ? 1 : 0,
    };

    if (address.postalCode != null && address.postalCode!.isNotEmpty) {
      map['postal_code'] = address.postalCode;
    }
    if (address.phone != null && address.phone!.isNotEmpty) {
      map['phone'] = address.phone;
    }

    // JP detail — nested keys: jp_detail[prefecture_id], etc.
    if (address.jpDetail != null) {
      final jp = address.jpDetail!;
      if (jp.prefectureId != null) {
        map['jp_detail[prefecture_id]'] = jp.prefectureId;
      }
      map['jp_detail[ward_town]'] = jp.wardTown;
      map['jp_detail[banchi]'] = jp.banchi;
      if (jp.buildingName != null && jp.buildingName!.isNotEmpty) {
        map['jp_detail[building_name]'] = jp.buildingName;
      }
      if (jp.roomNo != null && jp.roomNo!.isNotEmpty) {
        map['jp_detail[room_no]'] = jp.roomNo;
      }
    }

    // VN detail — nested keys: vn_detail[province_city], etc.
    if (address.vnDetail != null) {
      final vn = address.vnDetail!;
      map['vn_detail[province_city]'] = vn.provinceCity;
      map['vn_detail[district]'] = vn.district;
      if (vn.wardCommune.isNotEmpty) {
        map['vn_detail[ward_commune]'] = vn.wardCommune;
      }
      if (vn.detailAddress.isNotEmpty) {
        map['vn_detail[detail_address]'] = vn.detailAddress;
      }
      if (vn.buildingName != null && vn.buildingName!.isNotEmpty) {
        map['vn_detail[building_name]'] = vn.buildingName;
      }
      if (vn.roomNo != null && vn.roomNo!.isNotEmpty) {
        map['vn_detail[room_no]'] = vn.roomNo;
      }
    }

    // Image file upload
    if (imageFile != null) {
      map['image'] = await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      );
    }

    return FormData.fromMap(map);
  }
}

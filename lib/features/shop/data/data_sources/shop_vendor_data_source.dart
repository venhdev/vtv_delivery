// import 'package:dio/dio.dart';
// import 'package:vendor/core/constants/vendor_api.dart';
// import 'package:vtv_common/core.dart';
// import 'package:vtv_common/shop.dart';

// abstract class ShopVendorDataSource {
//   Future<SuccessResponse<ShopEntity>> getShopProfile();
// }

// class ShopVendorDataSourceImpl implements ShopVendorDataSource {
//   final Dio _dio;

//   ShopVendorDataSourceImpl(this._dio);

//   @override
//   Future<SuccessResponse<ShopEntity>> getShopProfile() async {
//     final url = baseUri(path: kAPIVendorShopProfileURL);

//     final response = await _dio.getUri(url);

//     return handleDioResponse<ShopEntity, Map<String, dynamic>>(
//       response,
//       url,
//       parse: (jsonMap) => ShopEntity.fromMap(jsonMap['shopDTO']),
//     );
//   }
// }

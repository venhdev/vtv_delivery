import 'package:vtv_common/core.dart';
import 'package:vtv_common/shop.dart';

abstract class ShopVendorRepository {
  FRespData<ShopEntity> getShopProfile();
}

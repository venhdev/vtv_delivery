import 'package:flutter/material.dart';
import 'package:vtv_common/guest.dart';
import 'package:vtv_common/shop.dart';

import '../../../../service_locator.dart';
import '../../domain/repository/shop_vendor_repository.dart';

class ShopInfoDetailView extends StatelessWidget {
  /// This View is used in the VendorPage:
  /// - 1: after the user has logged in
  /// - 2: load the shop profile to get the shopId
  /// - 3: load the shop detail >> display the shop info
  const ShopInfoDetailView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: sl<ShopVendorRepository>().getShopProfile(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final resultEither = snapshot.data!;

          return resultEither.fold(
            (error) => Center(child: Text(error.message ?? 'Lỗi khi tải dữ liệu Shop')),
            (ok) {
              return FutureBuilder(
                future: sl<GuestRepository>().getShopDetailById(ok.data!.shopId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data!.fold(
                      (error) => Center(child: Text(error.message ?? 'Lỗi khi tải dữ liệu chi tiết Shop')),
                      (ok) {
                        return ShopInfo(
                          shopId: ok.data!.shop.shopId,
                          shopDetail: ok.data!,
                          shopName: ok.data!.shop.name,
                          shopAvatar: ok.data!.shop.avatar,
                          showFollowedCount: true,
                          showShopDetail: true,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          )
                        );
                      },
                    );
                  }
                  return const Center(
                    child: Text(
                      'Đang tải...',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                },
              );
            },
          );
        }
        return const Center(
          child: Text(
            'Đang tải...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        );
      },
    );
  }
}

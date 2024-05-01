import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vtv_common/core.dart';

import '../../../../service_locator.dart';
import '../../domain/entities/deliver_entity.dart';
import '../../domain/repository/deliver_repository.dart';
import '../components/near_by_orders.dart';

class OrderPickUpPage extends StatefulWidget {
  const OrderPickUpPage({
    super.key,
  });

  @override
  State<OrderPickUpPage> createState() => _OrderPickUpPageState();
}

class _OrderPickUpPageState extends State<OrderPickUpPage> {
  void _handleScanned(BuildContext context, String transportOrderId) {
    showDialogToConfirm(
      context: context,
      title: 'Đã lấy kiện hàng ở Shop?',
      content: 'Mã đơn hàng: $transportOrderId',
      confirmText: 'Xác nhận',
      dismissText: 'Thoát',
      onConfirm: () async {
        final respEither = await sl<DeliverRepository>().updateStatusTransportByDeliver(
          transportOrderId,
          OrderStatus.PICKED_UP,
          true,
          '11500', //TODO: implement real location
        );

        respEither.fold(
          (error) => Fluttertoast.showToast(msg: error.message ?? 'Có lỗi xảy ra khi cập nhật trạng thái đơn hàng!'),
          (ok) {
            Fluttertoast.showToast(msg: 'Đã nhận đơn hàng thành công!');
            setState(() {});
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // button scan qr code to get order from vendor
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var transportOrderId = await Navigator.of(context).pushNamed('/scan') as String?;
          // log('transportOrderId: $transportOrderId');
          if (transportOrderId != null && context.mounted) _handleScanned(context, transportOrderId);
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
      body: FutureBuilder(
          future: sl<DeliverRepository>().getDeliverInfo(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data!.fold(
                (error) => MessageScreen.error(error.message),
                (ok) => RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: _buildCustomScrollViewBody(context, ok),
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }

  // ListView _buildBodyViaListViewBuilder(SuccessResponse<DeliverEntity> ok) {
  //   return ListView.builder(
  //     itemCount: ok.data!.wardWorks.length,
  //     itemBuilder: (context, index) => NearbyOrders(
  //       wardWork: ok.data!.wardWorks[index],
  //     ),
  //   );
  // }

  CustomScrollView _buildCustomScrollViewBody(BuildContext context, SuccessResponse<DeliverEntity> ok) {
    return CustomScrollView(
      slivers: [
        // app bar
        sliverAppBar(context, ok.data!),
        // body
        // REVIEW: this got issue with the future builder >> need data to be loaded first
        //! [ADD] full address for TransportItem:FullAddressByWardCode
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => NearbyOrders(
              wardWork: ok.data!.wardWorks[index],
            ),
            childCount: ok.data!.wardWorks.length,
          ),
        ),

        // use other method to render list
        // SliverToBoxAdapter(
        //   child: Column(
        //     children: [
        //       for (final wardWork in ok.data!.wardWorks)
        //         NearbyOrders(
        //           wardWork: wardWork,
        //         ),
        //     ],
        //   ),
        // ),

        // another other method
        // SliverFillRemaining(
        //   hasScrollBody: true,
        //   child: Column(
        //     children: [
        //       for (final wardWork in ok.data!.wardWorks)
        //         NearbyOrders(
        //           wardWork: wardWork,
        //         ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  SliverAppBar sliverAppBar(BuildContext context, DeliverEntity deliver) {
    return SliverAppBar(
      title: const Text('Đơn hàng chờ giao'),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(
              '/profile',
              arguments: deliver,
            );
          },
          icon: const Icon(Icons.account_circle_outlined),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app_state.dart';
import '../../domain/entities/deliver_entity.dart';
import '../../domain/entities/ward_work_entity.dart';
import '../components/pickup_pending_orders_by_ward.dart';

class PickUpPendingOrdersPage extends StatefulWidget {
  const PickUpPendingOrdersPage({
    super.key,
  });

  @override
  State<PickUpPendingOrdersPage> createState() => _PickUpPendingOrdersPageState();
}

class _PickUpPendingOrdersPageState extends State<PickUpPendingOrdersPage> {
  WardWorkEntity? selectedWard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppState>(builder: (context, state, _) {
        if (state.deliveryInfo != null) {
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: _buildCustomScrollViewBody(context, state.deliveryInfo!),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      }),
    );
  }

  // REVIEW: this got issue with the future builder >> need data to be loaded first
  //! [ADD] full address for TransportItem:FullAddressByWardCode
  CustomScrollView _buildCustomScrollViewBody(BuildContext context, DeliverEntity deliver) {
    // final selectableList = <String>[
    //   'Tất cả (Chọn phường/xã)',
    //   ...[for (final ward in deliver.wardWorks) ward.fullName],
    // ];

    return CustomScrollView(
      slivers: [
        //# app bar
        SliverAppBar(
          title: const Text('Đơn hàng chờ giao'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),

        //# select ward
        SliverToBoxAdapter(
          child: PopupMenuButton(
            itemBuilder: (context) {
              final wardList = deliver.wardWorks.map((ward) {
                return PopupMenuItem(value: ward, child: Text(ward.fullName));
              }).toList();
              return wardList;
            },
            onSelected: (ward) {
              setState(() {
                selectedWard = ward;
              });
            },
            child: ListTile(
              title: Text(selectedWard?.fullName ?? 'Tất cả (Chọn phường/xã)'),
              trailing: selectedWard == null
                  ? const Icon(Icons.arrow_drop_down)
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => selectedWard = null),
                    ),
            ),
          ),
        ),

        //# list of orders at selected ward
        SliverFillRemaining(child: PickupPendingOrdersByWard(wardWork: selectedWard))
      ],
    );
  }
}

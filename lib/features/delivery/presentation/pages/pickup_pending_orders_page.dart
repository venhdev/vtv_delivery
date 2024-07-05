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
              return deliver.wardWorks.map((ward) {
                return PopupMenuItem(
                  value: ward,
                  child: Text(ward.fullName),
                );
              }).toList();
            },
            onSelected: (ward) {
              setState(() {
                selectedWard = ward;
              });
            },
            child: ListTile(
              title: Text(selectedWard?.fullName ?? 'Chọn phường/xã'),
              trailing: const Icon(Icons.arrow_drop_down),
            ),
          ),
        ),

        //# list of orders at selected ward
        if (selectedWard != null) SliverFillRemaining(child: PickupPendingOrdersByWard(wardWork: selectedWard!))
        //? change log: old ver. without selected ward feature so it shows all wards
        // SliverList(
        //   delegate: SliverChildBuilderDelegate(
        //     (context, index) => PickupPendingOrdersByWard(wardWork: deliver.wardWorks[index]),
        //     childCount: deliver.wardWorks.length,
        //   ),
        // ),
      ],
    );
  }
}

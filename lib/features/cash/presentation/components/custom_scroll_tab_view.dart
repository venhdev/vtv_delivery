import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:vtv_common/core.dart';

import '../../domain/entities/cash_order_by_date_entity.dart';
import 'cash_item.dart';
import 'filter_cash_transfer_dialog.dart';
import 'summary_cash_on_date.dart';

class CustomScrollTabView extends StatefulWidget {
  const CustomScrollTabView({
    super.key,
    required this.listController,
    required this.typeWork,
    required this.isSlidable,
    this.onScanPressed,
    this.onInsertPressed,
    this.onConfirmPressed,
  });

  factory CustomScrollTabView.shipper({
    Key? key,
    required FutureListController<CashOrderByDateEntity, RespData<List<CashOrderByDateEntity>>> futureListController,
    bool isSlidable = false,
    ValueSelected<DateTime>? onScanPressed,
    ValueSelected<DateTime>? onInsertPressed,
    VoidCallback? onRefresh,
  }) {
    assert((onScanPressed != null && onInsertPressed != null) || !isSlidable);
    return CustomScrollTabView(
      key: key,
      listController: futureListController,
      typeWork: TypeWork.SHIPPER,
      isSlidable: isSlidable,
      onScanPressed: onScanPressed,
      onInsertPressed: onInsertPressed,
    );
  }
  factory CustomScrollTabView.warehouse({
    Key? key,
    required FutureListController<CashOrderByDateEntity, RespData<List<CashOrderByDateEntity>>> futureListController,
    bool isSlidable = false,
    ValueSelected<List<String>>? onConfirmPressed,
    VoidCallback? onRefresh,
  }) {
    return CustomScrollTabView(
      key: key,
      listController: futureListController,
      typeWork: TypeWork.WAREHOUSE,
      isSlidable: isSlidable,
      onConfirmPressed: onConfirmPressed,
    );
  }
  final FutureListController<CashOrderByDateEntity, RespData<List<CashOrderByDateEntity>>> listController;

  final TypeWork typeWork;
  final bool isSlidable;

  final ValueSelected<DateTime>? onScanPressed;
  final ValueSelected<DateTime>? onInsertPressed;
  final ValueSelected<List<String>>? onConfirmPressed;

  @override
  State<CustomScrollTabView> createState() => _CustomScrollTabViewState();
}

class _CustomScrollTabViewState extends State<CustomScrollTabView> with SingleTickerProviderStateMixin {
  final FocusNode _dateFocusNode = FocusNode(debugLabel: 'Menu Date Picker');
  final FocusNode _shipperFocusNode = FocusNode(debugLabel: 'Menu Shipper Picker');
  late final AnimationController _animationController;
  late final Animation<Offset> _offsetAnimation;

  //# warehouse
  DateTime? _filterDate;
  String? _filterShipper;

  List<String> getCashOrderIdsByDate(DateTime date, List<CashOrderByDateEntity> items) {
    return items
        .where((element) => element.date == date)
        .expand((element) => element.cashOrders)
        .map((e) => e.cashOrderId)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    // if (widget.typeWork == TypeWork.WAREHOUSE)
    // _filteredItems.addAll(widget.listController.items);

    if (widget.isSlidable) {
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      )..repeat(reverse: true);

      _offsetAnimation = Tween<Offset>(
        begin: const Offset(0.1, 0),
        end: const Offset(0, 0),
      ).animate(_animationController);
    }

    //> check if not set filter callback > add
    if (!widget.listController.filterable) {
      widget.listController.setFilterCallback((currentItems, _) {
        List<CashOrderByDateEntity> rs = currentItems;

        if (_filterDate != null) {
          _filterDate = DateTime(_filterDate!.year, _filterDate!.month, _filterDate!.day);
          rs.removeWhere((e) => e.date != _filterDate);
        }

        if (_filterShipper?.isNotEmpty == true) {
          for (int i = 0; i < rs.length; i++) {
            final filterCashOrders = rs[i].cashOrders.where((cash) => cash.shipperUsername == _filterShipper).toList();
            rs[i] = rs[i].copyWith(cashOrders: filterCashOrders);
          }
          rs.removeWhere((e) => e.cashOrders.isEmpty); // after filter, maybe some date has no cash order
        }
        return rs;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.listController.addListener(() {
        if (mounted) setState(() {});
      });
      widget.listController.performFilter();
    });
  }

  @override
  void dispose() {
    if (widget.isSlidable) _animationController.dispose();
    widget.listController.removeListener(() {
      if (mounted) setState(() {});
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.listController.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (widget.listController.items.isEmpty) {
      return MessageScreen(
        message: 'Không có dữ liệu',
        onPressed: widget.listController.refresh,
      );
    }
    if (widget.typeWork == TypeWork.SHIPPER) {
      return _shipperView();
    } else {
      return _warehouseView();
    }
  }

  Widget _shipperView() {
    return RefreshIndicator(
      onRefresh: () async => widget.listController.refresh(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _totalCashTransferCountAndEditClearFilter(canChangeShipper: false)),
            SliverToBoxAdapter(child: _filterInput(canChangeShipper: false)),
            if (widget.listController.filteredItems?.isEmpty == true)
              const SliverFillRemaining(
                  child: Center(
                      child: Text('Danh sách trống...',
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)))),
            for (final cashOnDate in widget.listController.filteredItems!) ...[
              SliverToBoxAdapter(
                child: Slidable(
                  key: ValueKey(cashOnDate.date),
                  endActionPane: widget.isSlidable ? _shipperSlideEnd(cashOnDate.date) : null,
                  child: SummaryCashOnDate(
                    cashOnDate: cashOnDate,
                    endBuilder: widget.isSlidable
                        ? (_) => SlideTransition(
                            position: _offsetAnimation,
                            child: const Icon(Icons.keyboard_double_arrow_left_rounded, color: Colors.blue))
                        : null,
                  ),
                ),
              ),
              _sliverList(cashOnDate),
            ],
          ],
        ),
      ),
    );
  }

  Widget _warehouseView() {
    return RefreshIndicator(
      onRefresh: () async {
        widget.listController.refresh();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _totalCashTransferCountAndEditClearFilter()),
            SliverToBoxAdapter(child: _filterInput()),
            if (widget.listController.filteredItems?.isEmpty == true)
              const SliverFillRemaining(
                  child: Center(
                      child: Text('Danh sách trống...',
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)))),
            for (final cashOnDate in widget.listController.filteredItems!) ...[
              SliverToBoxAdapter(
                child: Slidable(
                  key: ValueKey(cashOnDate.date),
                  endActionPane: widget.isSlidable ? _warehouseSlideEnd(cashOnDate.date) : null,
                  child: SummaryCashOnDate(
                    cashOnDate: cashOnDate,
                    endBuilder: widget.isSlidable
                        ? (_) => SlideTransition(
                            position: _offsetAnimation,
                            child: const Icon(Icons.keyboard_double_arrow_left_rounded, color: Colors.blue))
                        : null,
                  ),
                ),
              ),
              _sliverList(cashOnDate),
            ],
          ],
        ),
      ),
    );
  }

  Widget _totalCashTransferCountAndEditClearFilter({bool canChangeShipper = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //# total cash orders
        Text('Tổng số đơn: ${widget.listController.filteredItems!.expand((e) => e.cashOrders).length}'),

        //# icon search/ clear filter
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              style: VTVTheme.shrinkButton,
              icon: const Icon(Icons.search),
              onPressed: () async {
                final rs = await showDialog<({DateTime? selectedDate, String? shipperUsername})>(
                    context: context,
                    builder: (context) => FilterCashTransferDialog(
                          initDate: _filterDate,
                          initShipperUsername: _filterShipper,
                          canChangeShipper: canChangeShipper,
                        ));
                if (rs == null) return;

                if (rs.selectedDate != _filterDate || rs.shipperUsername != _filterShipper) {
                  setState(() {
                    _filterDate = rs.selectedDate;
                    _filterShipper = rs.shipperUsername;
                    widget.listController.performFilter();
                  });
                }
              },
            ),
            if (_filterDate != null || _filterShipper != null)
              IconButton(
                style: VTVTheme.shrinkButton,
                icon: const Icon(Icons.filter_alt_off),
                onPressed: () {
                  setState(() {
                    _filterDate = null;
                    _filterShipper = null;
                    widget.listController.performFilter();
                  });
                },
              ),
          ],
        )
      ],
    );
  }

  ActionPane _shipperSlideEnd(DateTime date) {
    return ActionPane(
      // A motion is a widget used to control how the pane animates.
      motion: const ScrollMotion(),
      extentRatio: 0.45,

      // All actions are defined in the children parameter.
      children: [
        SlidableAction(
          borderRadius: BorderRadius.circular(8),
          backgroundColor: Colors.cyan,
          foregroundColor: Colors.white,
          icon: Icons.qr_code_scanner_sharp,
          label: 'Quét',
          onPressed: widget.onScanPressed != null ? (_) => widget.onScanPressed!(date) : null,
        ),
        const SizedBox(width: 2),
        SlidableAction(
          borderRadius: BorderRadius.circular(8),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          icon: Icons.type_specimen_outlined,
          label: 'Nhập',
          onPressed: widget.onInsertPressed != null ? (_) => widget.onInsertPressed!(date) : null,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  ActionPane _warehouseSlideEnd(DateTime date) {
    return ActionPane(
      motion: const ScrollMotion(),
      extentRatio: 0.3,
      children: [
        SlidableAction(
          borderRadius: BorderRadius.circular(8),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          icon: Icons.check,
          label: 'Xác nhận',
          onPressed: widget.onConfirmPressed != null
              ? (_) => widget.onConfirmPressed!(getCashOrderIdsByDate(date, widget.listController.filteredItems!))
              : null,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  SliverList _sliverList(CashOrderByDateEntity cashOnDate) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: cashOnDate.cashOrders.length,
        (context, index) => CashItem(cash: cashOnDate.cashOrders[index]),
      ),
    );
  }

  Widget _filterInput({bool canChangeShipper = true}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                'Ngày: ${_filterDate != null ? ConversionUtils.convertDateTimeToString(_filterDate!) : '(chưa chọn)'}'),
            MenuAnchor(
              childFocusNode: _dateFocusNode,
              builder: (BuildContext context, MenuController controller, Widget? child) {
                return TextButton(
                  focusNode: _dateFocusNode,
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  child: const Text('Đổi ngày'),
                );
              },
              menuChildren: widget.listController.items
                  .map((e) => MenuItemButton(
                        child: Text(ConversionUtils.convertDateTimeToString(e.date)),
                        onPressed: () {
                          if (_filterDate == e.date) return;
                          setState(() {
                            _filterDate = e.date;
                            widget.listController.performFilter();
                          });
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
        if (canChangeShipper)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shipper: ${_filterShipper ?? '(chưa chọn)'}'),
              MenuAnchor(
                childFocusNode: _shipperFocusNode,
                builder: (BuildContext context, MenuController controller, Widget? child) {
                  return TextButton(
                    focusNode: _shipperFocusNode,
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    child: const Text('Đổi shipper'),
                  );
                },
                menuChildren: widget.listController.items
                    .expand((e) => e.cashOrders.map((cash) => cash.shipperUsername))
                    .toSet()
                    .map((e) => MenuItemButton(
                          child: Text(e),
                          onPressed: () {
                            if (_filterShipper == e) return;
                            setState(() {
                              _filterShipper = e;
                              widget.listController.performFilter();
                            });
                          },
                        ))
                    .toList(),
              ),
            ],
          ),
      ],
    );
  }
}

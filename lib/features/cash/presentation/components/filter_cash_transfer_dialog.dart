import 'package:flutter/material.dart';
import 'package:vtv_common/core.dart';

class FilterCashTransferDialog extends StatefulWidget {
  const FilterCashTransferDialog({
    super.key,
    required this.initDate,
    required this.initShipperUsername,
    this.canChangeShipper = true,
  });

  final DateTime? initDate;
  final String? initShipperUsername;

  // style
  final bool canChangeShipper;

  @override
  State<FilterCashTransferDialog> createState() => _FilterCashTransferDialogState();
}

class _FilterCashTransferDialogState extends State<FilterCashTransferDialog> {
  late DateTime? dateSelected;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    dateSelected = widget.initDate;
    _textController = TextEditingController(text: widget.initShipperUsername ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tìm kiếm'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //# row with textfield + icon button to choose date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'Ngày: ${dateSelected != null ? ConversionUtils.convertDateTimeToString(dateSelected!) : '(chưa chọn)'}'),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final newSelected = await showDatePicker(
                    context: context,
                    initialDate: widget.initDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2100),
                  );
                  if (newSelected != null) {
                    setState(() {
                      dateSelected = newSelected;
                    });
                  }
                },
              ),
            ],
          ),

          // textfield to insert shipper username
          if (widget.canChangeShipper)
            TextField(
              controller: _textController,
              decoration: const InputDecoration(hintText: 'Nhập tên tài khoản shipper'),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop<({DateTime? selectedDate, String? shipperUsername})>(
              (selectedDate: dateSelected, shipperUsername: _textController.text.isEmpty ? null : _textController.text),
            );
          },
          child: const Text('Lọc'),
        ),
      ],
    );
  }
}

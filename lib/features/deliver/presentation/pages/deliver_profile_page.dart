import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vtv_common/auth.dart';

import '../../domain/entities/deliver_entity.dart';
import '../../domain/entities/ward_work_entity.dart';

class DeliverProfilePage extends StatelessWidget {
  const DeliverProfilePage({
    super.key,
  });

  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    var deliver = ModalRoute.of(context)!.settings.arguments as DeliverEntity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ người vận chuyển'),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // deliver info
                    DeliverInfo(deliver: deliver),
                    // FutureBuilder(
                    //   future: sl<DeliverRepository>().getDeliverInfo(),
                    //   builder: (context, snapshot) {
                    //     if (snapshot.hasData) {
                    //       return snapshot.data!.fold(
                    //         (error) => Text('Deliver error: ${error.message}'),
                    //         (ok) => DeliverInfo(deliver: ok.data!),
                    //       );
                    //     }
                    //     return const Center(
                    //       child: CircularProgressIndicator(),
                    //     );
                    //   },
                    // ),

                    const Divider(),
                    SelectableText(state.auth!.refreshToken),
                    ElevatedButton(
                      onPressed: () {
                        var refreshToken = context.read<AuthCubit>().state.auth!.refreshToken;
                        context.read<AuthCubit>().logout(refreshToken);
                      },
                      child: const Text('Đăng xuất'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class DeliverInfo extends StatelessWidget {
  const DeliverInfo({
    super.key,
    required this.deliver,
  });

  final DeliverEntity deliver;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // deliver contact
        Text('Tên: ${deliver.usernameAdded}'),
        Text('Số điện thoại: ${deliver.phone}'),
        Text('Địa chỉ: ${deliver.fullAddress}'),
        Text('Tỉnh: ${deliver.provinceName}'),
        Text('Quận: ${deliver.districtName}'),
        Text('Phường: ${deliver.wardName}'),

        const Divider(),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Công việc: ${deliver.typeWork}'),
            Text('Trạng thái: ${deliver.status}'),
          ],
        ),
        // Text('Mã phường: ${deliver.wardCode}'),
        // Text('Mã khách hàng: ${deliver.customerId}'),
        // Text('Mã nhà vận chuyển: ${deliver.transportProviderId}'),
        Text('Tên nhà vận chuyển: ${deliver.transportProviderShortName}'),
        // Text('Số lượng phường làm việc: ${deliver.countWardWork}'),
        // Text('Phường làm việc: ${deliver.wardsWork.map((e) => e.name).join(', ')}'),
        const Text('Nơi làm việc:'),
        for (var wardWork in deliver.wardWorks) WardWorkItem(wardWork: wardWork),
      ],
    );
  }
}

class WardWorkItem extends StatelessWidget {
  const WardWorkItem({super.key, required this.wardWork});

  final WardWorkEntity wardWork;

  @override
  Widget build(BuildContext context) {
    return Text('- ${wardWork.fullName}');
  }
}

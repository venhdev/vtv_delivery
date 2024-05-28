import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vtv_common/auth.dart';

import '../../domain/entities/deliver_entity.dart';

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
        actions: [
          //# dev page
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/dev');
            },
            icon: const Icon(Icons.developer_mode),
          ),
        ],
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
                    //# deliver info
                    _DeliverInfo(deliver: deliver),

                    const Divider(),
                    BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                      return ElevatedButton(
                        onPressed: () {
                          var refreshToken = context.read<AuthCubit>().state.auth!.refreshToken;
                          context.read<AuthCubit>().logout(refreshToken);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        child: state.status == AuthStatus.authenticating
                            ? const Text(
                                'Đang đăng xuất...',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black54),
                              )
                            : const Text('Đăng xuất'),
                      );
                    }),
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

class _DeliverInfo extends StatelessWidget {
  const _DeliverInfo({
    required this.deliver,
  });

  final DeliverEntity deliver;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //# deliver contact
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
            // Text('Trạng thái: ${deliver.status}'),
          ],
        ),
        // Text('Mã phường: ${deliver.wardCode}'),
        // Text('Mã khách hàng: ${deliver.customerId}'),
        // Text('Mã nhà vận chuyển: ${deliver.transportProviderId}'),
        Text('Tên nhà vận chuyển: ${deliver.transportProviderShortName}'),
        // Text('Số lượng phường làm việc: ${deliver.countWardWork}'),
        const Text('Nơi làm việc:'),
        for (var wardWork in deliver.wardWorks) Text('- ${wardWork.fullName}'),
      ],
    );
  }
}

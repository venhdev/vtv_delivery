import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vtv_common/auth.dart';
import 'package:vtv_common/core.dart';

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
          //# app info
          IconButton(
            onPressed: () {
              showCrossPlatformAboutDialog(context: context);
            },
            icon: const Icon(Icons.info),
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
                    _DeliverInfo(deliver: deliver, userInfo: state.auth!.userInfo),

                    const SizedBox(height: 8),

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
    required this.userInfo,
  });

  final DeliverEntity deliver;
  final UserInfoEntity userInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //# user info + deliver info
        Wrapper(
          crossAxisAlignment: CrossAxisAlignment.start,
          label: const WrapperLabel(labelText: 'Hồ sơ người vận chuyển'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Họ và tên: ${userInfo.fullName}'),
              Text('Username: ${userInfo.username}'),
              Text('Email: ${userInfo.email}'),
              Text('Số điện thoại: ${deliver.phone}'),
              const Divider(),
              Text('Địa chỉ: ${deliver.fullAddress}'),
              Text('Tỉnh: ${deliver.provinceName}'),
              Text('Quận: ${deliver.districtName}'),
              Text('Phường: ${deliver.wardName}'),
            ],
          ),
        ),

        const Divider(),
        //# deliver info
        Wrapper(
          crossAxisAlignment: CrossAxisAlignment.start,
          label: const WrapperLabel(labelText: 'Thông tin công việc'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Công việc: ${deliver.typeWork}'),
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
          ),
        ),
      ],
    );
  }
}

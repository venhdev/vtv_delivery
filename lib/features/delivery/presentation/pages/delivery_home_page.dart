import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vtv_common/auth.dart';
import 'package:vtv_common/core.dart';

import '../../../../dependency_container.dart';
import '../../domain/repository/deliver_repository.dart';
import '../components/home_page_content.dart';

class DeliveryHomePage extends StatelessWidget {
  const DeliveryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.message ?? 'Có lỗi xảy ra! Vui lòng thử lại!')),
            );
        }
      },
      builder: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          if (!state.auth!.userInfo.roles!.contains(Role.DELIVER)) {
            return NoPermissionPage(
              message: 'Bạn không có quyền truy cập vào ứng dụng này!',
              onPressed: () => context.read<AuthCubit>().logout(state.auth!.refreshToken),
            );
          }
          // return page base on type work
          return _HomePageWithBottomNavigation('Xin chào, ${state.auth!.userInfo.username!}');
        } else {
          return _noAuth(context);
        }
      },
    );
  }

  Widget _noAuth(BuildContext context) {
    return GestureDetector(
      onLongPress: () => Navigator.of(context).pushNamed('/dev'),
      child: LoginPage(
        showTitle: false,
        formTitle: 'VTV Delivery',
        onLoginPressed: (username, password) async {
          context.read<AuthCubit>().loginWithUsernameAndPassword(username: username, password: password);
        },
      ),
    );
  }
}

class _HomePageWithBottomNavigation extends StatefulWidget {
  const _HomePageWithBottomNavigation(this.title);

  final String title;

  @override
  State<_HomePageWithBottomNavigation> createState() => _HomePageWithBottomNavigationState();
}

class _HomePageWithBottomNavigationState extends State<_HomePageWithBottomNavigation> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget? _bottomNavigationBar() {
    return BottomNavigationBar(
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.article_rounded),
          label: 'Đơn hàng',
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const HomePageContent(),
      const Center(child: Text('Đơn hàng')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true, actions: _actions(context)),
      bottomNavigationBar: _bottomNavigationBar(),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }

  List<Widget> _actions(BuildContext context) {
    return [
      //# Profile
      IconButton(
        onPressed: () async {
          var deliver = await sl<DeliverRepository>().getDeliverInfo();
          deliver.fold(
            (error) => null,
            (ok) => Navigator.of(context).pushNamed(
              '/profile',
              arguments: ok.data!,
            ),
          );
        },
        icon: const Icon(Icons.account_circle_outlined),
      ),
    ];
  }
}

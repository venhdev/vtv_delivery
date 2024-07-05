import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:vtv_common/auth.dart';
import 'package:vtv_common/core.dart';

import 'app_state.dart';
import 'dependency_container.dart';
import 'features/cash/presentation/pages/cash_order_by_shipper_page.dart';
import 'features/cash/presentation/pages/cash_order_by_warehouse_page.dart';
import 'features/delivery/domain/repository/delivery_repository.dart';
import 'features/delivery/presentation/pages/deliver_profile_page.dart';
import 'features/delivery/presentation/pages/delivery_home_page.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key});

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
          if (!state.isDeliver) {
            return NoPermissionPage(
              message: 'Bạn không có quyền truy cập vào ứng dụng này!',
              onPressed: () => context.read<AuthCubit>().logout(state.auth!.refreshToken),
            );
          }
          // HomePage base on role
          return _AppScaffoldWithBottomNavigation('Xin chào, ${state.auth!.userInfo.username!}');
        } else {
          return _noAuth(context);
        }
      },
    );
  }

  Widget _noAuth(BuildContext context) {
    return GestureDetector(
      onLongPress: () => Navigator.of(context).pushNamed('/dev'), //NOTE: dev
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

class _AppScaffoldWithBottomNavigation extends StatefulWidget {
  const _AppScaffoldWithBottomNavigation(this.title);

  final String title;

  @override
  State<_AppScaffoldWithBottomNavigation> createState() => _AppScaffoldWithBottomNavigationState();
}

class _AppScaffoldWithBottomNavigationState extends State<_AppScaffoldWithBottomNavigation> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  bool get appBarVisible {
    return _selectedIndex == 0;
  }

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const DeliveryHomePage(),
      Consumer<AppState>(
        builder: (context, state, _) {
          switch (state.typeWork) {
            case TypeWork.SHIPPER:
              return const CashOrderByShipperPage();
            case TypeWork.WAREHOUSE:
              return const CashOrderByWarehousePage();
            default:
              return const MessageScreen(message: 'TypeWork không hợp lệ!');
            // return Center(
            //   child: Text('deliveryInfo: ${Provider.of<AppState>(context, listen: false).deliveryInfo.toString()}'),
            // );
          }
        },
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      final authStatus = context.read<AuthCubit>().state.status;
      if (authStatus == AuthStatus.authenticated && appState.deliveryInfo == null) {
        appState.fetchDeliveryInfo();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        if (state.deliveryInfo == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          return child!;
        }
      },
      child: Scaffold(
        appBar: appBarVisible
            ? AppBar(
                title: Text(widget.title),
                // centerTitle: true,
                actions: _actions(context),
              )
            : null,
        bottomNavigationBar: _bottomNavigationBar(),
        body: _widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }

  List<Widget> _actions(BuildContext context) {
    return [
      //# Profile
      IconButton(
        onPressed: () async {
          var deliver = await sl<DeliveryRepository>().getDeliverInfo();
          deliver.fold(
            (error) => null,
            (ok) => Navigator.of(context).pushNamed(
              DeliverProfilePage.routeName,
              arguments: ok.data!,
            ),
          );
        },
        icon: const Icon(Icons.account_circle_outlined),
      ),
    ];
  }

  Widget? _bottomNavigationBar() {
    return BottomNavigationBar(
      onTap: _onItemTapped,
      currentIndex: _selectedIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.article_rounded), label: 'Đơn hàng'),
      ],
    );
  }
}

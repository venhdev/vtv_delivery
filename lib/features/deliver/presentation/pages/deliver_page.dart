import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vtv_common/auth.dart';

import 'menu_page.dart';

class DeliverPage extends StatelessWidget {
  const DeliverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          return _unAuth(context);
        }
        if (state.status == AuthStatus.authenticated) {
          // return const OrderPickUpPage();
          return const MenuPage();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Column _unAuth(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LoginPage(
            showTitle: false,
            onLoginPressed: (username, password) async {
              context.read<AuthCubit>().loginWithUsernameAndPassword(username: username, password: password);
            },
          ),
        ),

        // NOTE: dev
        ElevatedButton(
          onPressed: () {
            context.read<AuthCubit>().loginWithUsernameAndPassword(username: 'evtv01', password: '123');
          },
          child: const Text('login as vtv driver (evtv01)'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/dev');
          },
          child: const Text('dev page'),
        ),
      ],
    );
  }
}

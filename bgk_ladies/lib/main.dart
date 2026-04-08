import 'package:bgk_ladies/bloc/bloc_event.dart';
import 'package:bgk_ladies/bloc/bloc_func.dart';
import 'package:bgk_ladies/bloc/bloc_states.dart';
import 'package:bgk_ladies/firebase_options.dart';
import 'package:bgk_ladies/repo/auth_repo.dart';
import 'package:bgk_ladies/utilites/loading/loading_dialog.dart';
import 'package:bgk_ladies/views/auth/login_view.dart';
import 'package:bgk_ladies/views/auth/register_view.dart';
import 'package:bgk_ladies/views/dashboard_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    BlocProvider(
      create: (context) =>
          BlocFunc(AuthRepository())..add(const BlocEventInitialize()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "BGK Ladies",
        theme: ThemeData(primarySwatch: Colors.purple),
        routes: {
          "/login": (context) => LoginView(),
          "/register": (context) => RegisterView(),
          "/dash": (context) => DashboardView(),
        },
        home: MainPg(),
      ),
    ),
  );
}

class MainPg extends StatelessWidget {
  const MainPg({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlocFunc, BlocState>(
      builder: (context, state) {
        if (state.isLoading) {
          return LoadingDialog();
        } else if (state is BlocStateLoggedOut) {
          return LoginView();
        } else if (state is BlocStateNavigatingToRegister) {
          return RegisterView();
        } else if (state is BlocStateNavigatingToLogin) {
          return LoginView();
        } else if (state is BlocStateLoggedIn) {
          return DashboardView();
        }
        return Center(child: Text("An Unexpected Error Occurred"));
      },
    );
  }
}

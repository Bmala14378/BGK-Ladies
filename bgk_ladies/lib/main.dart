import 'package:bgk_ladies/bloc/auth/auth_bloc_event.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_func.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_states.dart';
import 'package:bgk_ladies/bloc/event/event_bloc_events.dart';
import 'package:bgk_ladies/bloc/event/event_bloc_func.dart';
import 'package:bgk_ladies/firebase_options.dart';
import 'package:bgk_ladies/repo/auth_repo.dart';
import 'package:bgk_ladies/services/event_service.dart';
import 'package:bgk_ladies/utilites/dialog/loading_dialog.dart';
import 'package:bgk_ladies/views/attend/event_management_view.dart';
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
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthBlocFunc(AuthRepository())
                ..add(const AuthBlocEventInitialize()),
        ),
        BlocProvider(
          create: (context) =>
              EventBloc(EventService())..add(const EventBlocEventInitialize()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "BGK Ladies",
        theme: ThemeData(primarySwatch: Colors.purple),
        routes: {
          "/login": (context) => LoginView(),
          "/register": (context) => RegisterView(),
          "/dash": (context) => DashboardView(),
          "/eventmgmt": (context) => EventManagementView(),
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
    return BlocBuilder<AuthBlocFunc, AuthBlocState>(
      builder: (context, state) {
        if (state.isLoading) {
          return LoadingDialog();
        } else if (state is AuthBlocStateLoggedOut) {
          return LoginView();
        } else if (state is AuthBlocStateNavigatingToRegister) {
          return RegisterView();
        } else if (state is AuthBlocStateNavigatingToLogin) {
          return LoginView();
        } else if (state is AuthBlocRegistered) {
          return RegisterView();
        } else if (state is AuthBlocStateLoggedIn) {
          return DashboardView();
        } else if (state is AuthBlocStateNavigatingToRegister) {
          return DashboardView();
        }
        return Center(child: Text("An Unexpected Error Occurred"));
      },
    );
  }
}

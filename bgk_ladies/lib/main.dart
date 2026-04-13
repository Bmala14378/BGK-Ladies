import 'package:bgk_ladies/bloc/appoint/appoint_bloc_event.dart';
import 'package:bgk_ladies/bloc/appoint/appoint_bloc_func.dart';
import 'package:bgk_ladies/bloc/attend/attend_bloc_events.dart';
import 'package:bgk_ladies/bloc/attend/attend_bloc_func.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_event.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_func.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_states.dart';
import 'package:bgk_ladies/bloc/event/event_bloc_events.dart';
import 'package:bgk_ladies/bloc/event/event_bloc_func.dart';
import 'package:bgk_ladies/bloc/member/member_bloc_events.dart';
import 'package:bgk_ladies/bloc/member/member_bloc_func.dart';
import 'package:bgk_ladies/firebase_options.dart';
import 'package:bgk_ladies/repo/auth/auth_repo.dart';
import 'package:bgk_ladies/services/appoint/appoint_service.dart';
import 'package:bgk_ladies/services/attend/attend_service.dart';
import 'package:bgk_ladies/services/event/event_service.dart';
import 'package:bgk_ladies/services/member/member_service.dart';
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
        BlocProvider(create: (context) => MemberBloc(MemberService())),
        BlocProvider(
          create: (context) =>
              AppointBloc(AppointService(), EventService())
                ..add(const AppointBlocEventFetchActiveEvents()),
        ),
        BlocProvider(
          create: (context) =>
              AttendBloc(AttendService(), EventService())
                ..add(const AttendBlocEventFetchActiveEvents()),
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
    return BlocConsumer<AuthBlocFunc, AuthBlocState>(
      listener: (context, state) {
        if (state is AuthBlocStateLoggedIn) {
          context.read<MemberBloc>().add(
            MemberBlocEventInitialize(user: state.user),
          );
          context.read<EventBloc>().add(const EventBlocEventInitialize());
          context.read<AttendBloc>().add(
            const AttendBlocEventFetchActiveEvents(),
          );
          context.read<AppointBloc>().add(
            const AppointBlocEventFetchActiveEvents(),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return Scaffold(body: Center(child: buildLoadingDialog(context)));
        } else if (state is AuthBlocStateLoggedOut ||
            state is AuthBlocStateNavigatingToLogin) {
          return LoginView();
        } else if (state is AuthBlocStateNavigatingToRegister ||
            state is AuthBlocRegistered) {
          return RegisterView();
        } else if (state is AuthBlocStateLoggedIn ||
            state is AuthBlocStatesNavigatingToDash) {
          return DashboardView();
        }
        return Center(child: Text("An Unexpected Error Occurred"));
      },
    );
  }
}

import 'dart:developer' as devtools;

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
import 'package:bgk_ladies/repo/auth/auth_exception.dart';
import 'package:bgk_ladies/repo/auth/auth_repo.dart';
import 'package:bgk_ladies/services/appoint/appoint_service.dart';
import 'package:bgk_ladies/services/attend/attend_service.dart';
import 'package:bgk_ladies/services/event/event_service.dart';
import 'package:bgk_ladies/services/member/member_service.dart';
import 'package:bgk_ladies/themes.dart';
import 'package:bgk_ladies/utilites/dialog/loading_dialog.dart';
import 'package:bgk_ladies/views/attend/event_management_view.dart';
import 'package:bgk_ladies/views/auth/login_view.dart';
import 'package:bgk_ladies/views/auth/register_view.dart';
import 'package:bgk_ladies/views/dashboard_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//Optional TODOs:
//TODO: Add user profile page with edit functionality with password change option
//TODO: Add loading indicators for all async operations in the UI (Recheck)
//TODO: Add Sorting & filter For Appoint And Attend

// Pre-Production Checklist:

// TODO: Rate Limiting

// TODO: Error Logging: Integrate Firebase Crashlytics and Sentry. You need to know if the app crashes on a client's device before they call you to complain.

//  Firebase Security Rules: This is the most common mistake. Ensure your Firestore rules aren't set to "allow read, write: if true;". They must be locked down so users can only see their own group's data.

//  Production Keys: Swap all your test API keys (Google Maps, Gemini, etc.) for production keys with proper usage restrictions (e.g., restricted to your app's Bundle ID).

//  Assets Optimization: Ensure all images/icons are compressed. Huge assets will make the app feel sluggish on older Android devices.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthBlocFunc(AuthRepository(), MemberService())
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
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        title: "BGK Ladies",
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
        if (state.isLoading) {
          buildLoadingDialog(context);
        }

        if (state is AuthBlocStateLoggedOut) {
          if (state.exception != null) {
            String errorMessage = "An Unexpected Error Occurred";
            if (state.exception is InvalidCredentialException) {
              errorMessage = "Invalid Credentials";
            } else {
              errorMessage = "$errorMessage: ${state.exception}";
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        } else if (state is AuthBlocStateLoggedIn) {
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
        if (state is AuthBlocStateError) {
          if (state.exception == "Member Not Found") {
            devtools.log("${state.exception} register view");
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Member Not Found")));
          } else if (state.exception != "") {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.exception.toString())));
          }
        }
        if (state is AuthBlocRegistered) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Registeration Successful")));
        }
      },
      builder: (context, state) {
        if (state is AuthBlocStateLoggedOut ||
            state is AuthBlocStateNavigatingToLogin) {
          return LoginView();
        } else if (state is AuthBlocStateNavigatingToRegister ||
            state is AuthBlocRegistered ||
            state is AuthBlocStateError) {
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

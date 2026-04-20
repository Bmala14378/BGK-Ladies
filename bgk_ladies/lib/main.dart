import 'dart:developer' as devtools;
import 'dart:ui';

//Bloc
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
import 'package:bgk_ladies/bloc/network/network_bloc.dart';

//Services & Repos
import 'package:bgk_ladies/repo/auth/auth_exception.dart';
import 'package:bgk_ladies/repo/auth/auth_repo.dart';
import 'package:bgk_ladies/services/appoint/appoint_service.dart';
import 'package:bgk_ladies/services/attend/attend_service.dart';
import 'package:bgk_ladies/services/event/event_service.dart';
import 'package:bgk_ladies/services/member/member_service.dart';

//Utilities
import 'package:bgk_ladies/themes.dart';
import 'package:bgk_ladies/utilites/dialog/loading_dialog.dart';
import 'package:bgk_ladies/utilites/dialog/network_dialog.dart';
import 'package:bgk_ladies/firebase_options.dart';

//Views
import 'package:bgk_ladies/views/attend/event_management_view.dart';
import 'package:bgk_ladies/views/auth/login_view.dart';
import 'package:bgk_ladies/views/auth/register_view.dart';
import 'package:bgk_ladies/views/dashboard_view.dart';

//Packages
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upgrader/upgrader.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://c2b22ea24e44e017805149d8a2c109dd@o4511251023790080.ingest.us.sentry.io/4511251023986688';
      // Adds request headers and IP for users, for more info visit:
      // https://docs.sentry.io/platforms/dart/guides/flutter/data-management/data-collected/
      options.sendDefaultPii = true;
      options.enableLogs = true;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:

      // ignore: experimental_member_use
      options.profilesSampleRate = 0.5;
      // Configure Session Replay
      options.replay.sessionSampleRate = 0.1;
      options.replay.onErrorSampleRate = 1.0;
    },
    appRunner: () => runApp(SentryWidget(child: 
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NetworkBloc()),
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
      child: const MyApp(),
    ),
  )),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BGK Ladies',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      routes: {
        "/login": (context) => LoginView(),
        "/register": (context) => RegisterView(),
        "/dash": (context) => DashboardView(),
        "/eventmgmt": (context) => EventManagementView(),
      },
      // The Builder here allows us to get a context under the BlocProviders
      home: UpgradeAlert(
        showIgnore: false,
        showLater: false,
        upgrader: Upgrader(
          storeController: UpgraderStoreController(
            onAndroid: () => UpgraderPlayStore(),
            oniOS: () => UpgraderAppStore(),
          ),
        ),
        child: BlocListener<NetworkBloc, NetworkState>(
          listener: (context, state) {
            if (state.status == NetworkStatus.disconnected) {
              showNoInternetDialog(context);
            } else {
              // Automatically close the dialog when internet returns
              if (Navigator.canPop(context)) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            }
          },
          child: const MainPg(),
        ),
      ),
    );
  }
}

class MainPg extends StatelessWidget {
  const MainPg({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBlocFunc, AuthBlocState>(
      listenWhen: (previous, current) =>
          previous.isLoading != current.isLoading,
      listener: (context, state) {
        if (state.isLoading) {
          Center(child: buildLoadingDialog(context));
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

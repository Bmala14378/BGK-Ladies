import 'package:bgk_ladies/bloc/bloc_event.dart';
import 'package:bgk_ladies/bloc/bloc_func.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bgk Ladies"),
        actions: [
          IconButton(
            onPressed: () {
              context.read<BlocFunc>().add(BlocEventLogOut());
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(child: Column(children: [Text("Dashboard")])),
    );
  }
}

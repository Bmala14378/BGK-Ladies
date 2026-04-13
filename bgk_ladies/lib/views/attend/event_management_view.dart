import 'package:bgk_ladies/bloc/event/event_bloc_func.dart';
import 'package:bgk_ladies/bloc/event/event_bloc_state.dart';
import 'package:bgk_ladies/models/event_model.dart';
import 'package:bgk_ladies/services/event/event_service.dart';
import 'package:bgk_ladies/utilites/dialog/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventManagementView extends StatefulWidget {
  const EventManagementView({super.key});

  @override
  State<EventManagementView> createState() => _EventManagementViewState();
}

class _EventManagementViewState extends State<EventManagementView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Event Management")),
      body: BlocBuilder<EventBloc, EventBlocState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(child: buildLoadingDialog(context));
          }
          if (state is EventStateLoaded) {
            final events = state.allEvents;

            if (events.isEmpty) {
              return const Center(child: Text("No events found. Add one!"));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final event = events[index];
                return Dismissible(
                  key: Key(event.eventId),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    EventService().deleteEvent(eventId: event.eventId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${event.eventName} deleted")),
                    );
                  },
                  child: ListTile(
                    title: Text(
                      event.eventName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      event.isactive ? "Status: Active" : "Status: Inactive",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueGrey),
                          onPressed: () => _showEditDialog(context, event),
                        ),
                        Switch(
                          activeThumbColor: Colors.purple,
                          value: event.isactive,
                          onChanged: (newValue) {
                            EventService().toggleEventActiveStatus(
                              eventId: event.eventId,
                              isActive: newValue,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text("Something went wrong."));
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Event"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter event name"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                EventService().createEvent(eventName: controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, EventModel event) {
    final controller = TextEditingController(text: event.eventName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rename Event"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter new name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty &&
                  controller.text != event.eventName) {
                EventService().updateEvent(
                  eventId: event.eventId,
                  eventName: controller.text,
                );
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}

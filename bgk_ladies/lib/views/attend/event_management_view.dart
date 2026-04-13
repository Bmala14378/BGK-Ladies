// import 'package:bgk_ladies/bloc/event/event_bloc_func.dart';
// import 'package:bgk_ladies/bloc/event/event_bloc_state.dart';
// import 'package:bgk_ladies/models/event_model.dart';
// import 'package:bgk_ladies/services/event/event_service.dart';
// import 'package:bgk_ladies/utilites/dialog/loading_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class EventManagementView extends StatefulWidget {
//   const EventManagementView({super.key});

//   @override
//   State<EventManagementView> createState() => _EventManagementViewState();
// }

// class _EventManagementViewState extends State<EventManagementView> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Event Management")),
//       body: BlocBuilder<EventBloc, EventBlocState>(
//         builder: (context, state) {
//           if (state.isLoading) {
//             return Center(child: buildLoadingDialog(context));
//           }
//           if (state is EventStateLoaded) {
//             final events = state.allEvents;

//             if (events.isEmpty) {
//               return const Center(child: Text("No events found. Add one!"));
//             }

//             return ListView.separated(
//               padding: const EdgeInsets.all(16),
//               itemCount: events.length,
//               separatorBuilder: (context, index) => const Divider(),
//               itemBuilder: (context, index) {
//                 final event = events[index];
//                 return Dismissible(
//                   key: Key(event.eventId),
//                   direction: DismissDirection.endToStart,
//                   background: Container(
//                     color: Colors.red,
//                     alignment: Alignment.centerRight,
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: const Icon(Icons.delete, color: Colors.white),
//                   ),
//                   onDismissed: (direction) {
//                     EventService().deleteEvent(eventId: event.eventId);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text("${event.eventName} deleted")),
//                     );
//                   },
//                   child: ListTile(
//                     title: Text(
//                       event.eventName,
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Text(
//                       event.isactive ? "Status: Active" : "Status: Inactive",
//                     ),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.edit, color: Colors.blueGrey),
//                           onPressed: () => _showEditDialog(context, event),
//                         ),
//                         Switch(
//                           activeThumbColor: Colors.purple,
//                           value: event.isactive,
//                           onChanged: (newValue) {
//                             EventService().toggleEventActiveStatus(
//                               eventId: event.eventId,
//                               isActive: newValue,
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           }
//           return const Center(child: Text("Something went wrong."));
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.purple,
//         onPressed: () => _showCreateDialog(context),
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }

//   void _showCreateDialog(BuildContext context) {
//     final controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("New Event"),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(hintText: "Enter event name"),
//           autofocus: true,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             style: TextButton.styleFrom(foregroundColor: Colors.grey),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (controller.text.isNotEmpty) {
//                 EventService().createEvent(eventName: controller.text);
//                 Navigator.pop(context);
//               }
//             },
//             child: const Text("Create"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showEditDialog(BuildContext context, EventModel event) {
//     final controller = TextEditingController(text: event.eventName);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Rename Event"),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(hintText: "Enter new name"),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (controller.text.isNotEmpty &&
//                   controller.text != event.eventName) {
//                 EventService().updateEvent(
//                   eventId: event.eventId,
//                   eventName: controller.text,
//                 );
//               }
//               Navigator.pop(context);
//             },
//             child: const Text("Save"),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:bgk_ladies/bloc/event/event_bloc_events.dart';
import 'package:bgk_ladies/bloc/event/event_bloc_func.dart';
import 'package:bgk_ladies/bloc/event/event_bloc_state.dart';
import 'package:bgk_ladies/models/event_model.dart';
import 'package:bgk_ladies/services/event/event_service.dart';
import 'package:bgk_ladies/utilites/dialog/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum EventFilter { all, active, archived }

class EventManagementView extends StatefulWidget {
  const EventManagementView({super.key});

  @override
  State<EventManagementView> createState() => _EventManagementViewState();
}

class _EventManagementViewState extends State<EventManagementView> {
  String _searchQuery = "";
  EventFilter _selectedFilter = EventFilter.all;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Manage Events",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple[800],
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: Colors.purple[800],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Event", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildSearchAndFilterSection(),
          Expanded(
            child: BlocBuilder<EventBloc, EventBlocState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return Center(child: buildLoadingDialog(context));
                }
                if (state is EventStateLoaded) {
                  // Apply Search and Filter logic
                  final filteredEvents = state.allEvents.where((event) {
                    final matchesSearch = event.eventName
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase());
                    final matchesFilter =
                        _selectedFilter == EventFilter.all ||
                        (_selectedFilter == EventFilter.active &&
                            event.isactive) ||
                        (_selectedFilter == EventFilter.archived &&
                            !event.isactive);
                    return matchesSearch && matchesFilter;
                  }).toList();

                  if (filteredEvents.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80), // Space for FAB
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      return _buildDismissibleTile(
                        context,
                        filteredEvents[index],
                      );
                    },
                  );
                }
                return const Center(child: Text("Unable to load events"));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          // 1. Search Bar
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: "Search events...",
              prefixIcon: const Icon(Icons.search, color: Colors.purple),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = "");
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 12),

          // 2. Filter Chips
          Row(
            children: [
              _buildFilterChip("All", EventFilter.all),
              const SizedBox(width: 8),
              _buildFilterChip("Active", EventFilter.active),
              const SizedBox(width: 8),
              _buildFilterChip("Archived", EventFilter.archived),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, EventFilter filter) {
    final isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedFilter = filter);
      },
      selectedColor: Colors.purple[100],
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.purple[900] : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? Colors.purple : Colors.grey[300]!),
      ),
      showCheckmark: false,
    );
  }

  // --- REUSED DISMISSIBLE LOGIC FROM PREVIOUS STEP ---
  Widget _buildDismissibleTile(BuildContext context, EventModel event) {
    return Dismissible(
      key: ValueKey(event.eventId),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _showEditDialog(context, event);
          return false;
        } else {
          return await _showDeleteConfirmation(context);
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          EventService().deleteEvent(eventId: event.eventId);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("${event.eventName} deleted")));
        }
      },
      background: _buildSwipeBackground(
        color: Colors.blue,
        icon: Icons.edit,
        alignment: Alignment.centerLeft,
        label: "Edit",
      ),
      secondaryBackground: _buildSwipeBackground(
        color: Colors.red,
        icon: Icons.delete_forever,
        alignment: Alignment.centerRight,
        label: "Delete",
      ),
      child: _buildEventCard(event),
    );
  }

  Widget _buildEventCard(EventModel event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: event.isactive
              ? Colors.purple[50]
              : Colors.grey[100],
          child: Icon(
            event.isactive ? Icons.event_available : Icons.event_busy,
            color: event.isactive ? Colors.purple : Colors.grey,
          ),
        ),
        title: Text(
          event.eventName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          event.isactive ? "Active" : "Archived",
          style: TextStyle(
            color: event.isactive ? Colors.green[700] : Colors.grey,
          ),
        ),
        trailing: Switch(
          value: event.isactive,
          activeThumbColor: Colors.purple,
          onChanged: (val) {
            EventService().toggleEventActiveStatus(
              eventId: event.eventId,
              isActive: val,
            );
          },
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerLeft)
            Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          if (alignment == Alignment.centerRight)
            Icon(icon, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "No events found",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Event?"),
        content: const Text(
          "This will permanently remove the event and all associated attendance data.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
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
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Event Name (e.g. Mawaid)",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
          autofocus: true,
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
                context.read<EventBloc>().add(
                  EventBlocEventUpdateTitle(
                    eventId: event.eventId,
                    newName: controller.text,
                  ),
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

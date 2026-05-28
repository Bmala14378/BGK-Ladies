// ignore_for_file: use_build_context_synchronously

import 'package:bgk_ladies/bloc/auth/auth_bloc_func.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_states.dart';
import 'package:bgk_ladies/bloc/user_mgmt/user_mgmt_bloc_events.dart';
import 'package:bgk_ladies/bloc/user_mgmt/user_mgmt_bloc_func.dart';
import 'package:bgk_ladies/bloc/user_mgmt/user_mgmt_bloc_states.dart';
import 'package:bgk_ladies/enums/markaz_enum.dart';
import 'package:bgk_ladies/enums/user_role_enum.dart';
import 'package:bgk_ladies/models/member_model.dart';
import 'package:bgk_ladies/models/user_model.dart';
import 'package:bgk_ladies/services/member/member_service.dart';
import 'package:bgk_ladies/themes.dart';
import 'package:bgk_ladies/utilites/dialog/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get logged-in user's ITS so we can guard against self-delete
    final authState = context.read<AuthBlocFunc>().state;
    final int? currentUserIts = authState is AuthBlocStateLoggedIn
        ? authState.user.itsNumber
        : null;

    return BlocConsumer<UserMgmtBloc, UserMgmtBlocState>(
      listener: (context, state) {
        if (state is UserMgmtBlocStateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is UserMgmtBlocStateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text("User Management")),
          body: Column(
            children: [
              // ── Search Bar ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    context.read<UserMgmtBloc>().add(
                      UserMgmtBlocEventSearch(query: value),
                    );
                  },
                  decoration: InputDecoration(
                    hintText: "Search by ITS, role, or markaz...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<UserMgmtBloc>().add(
                                const UserMgmtBlocEventSearch(query: ""),
                              );
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
              ),

              // ── List / Loading / Empty ─────────────────────────────────────
              Expanded(
                child: _buildBody(context, state, currentUserIts),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    UserMgmtBlocState state,
    int? currentUserIts,
  ) {
    if (state is UserMgmtBlocStateLoading ||
        state is UserMgmtBlocStateInitial) {
      return Center(child: buildLoadingDialog(context));
    }
    if (state is UserMgmtBlocStateLoaded) {
      if (state.filteredUsers.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 64, color: Colors.grey),
              SizedBox(height: 12),
              Text("No users found", style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }
      return ListView.builder(
        itemCount: state.filteredUsers.length,
        itemBuilder: (context, index) {
          return _buildUserTile(
            context,
            state.filteredUsers[index],
            currentUserIts,
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildUserTile(
    BuildContext context,
    UserModel user,
    int? currentUserIts,
  ) {
    final isSelf = user.itsNumber == currentUserIts;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryLight,
          child: Text(
            user.role.name[0].toUpperCase(),
            style: TextStyle(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.itsNumber.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.role.displayName),
            if (user.markaz != null)
              Text(
                user.markaz!.displayName,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        isThreeLine: user.markaz != null,
        trailing: isSelf
            ? Tooltip(
                message: "Cannot modify your own account",
                child: Icon(Icons.lock_outline, color: Colors.grey.shade400),
              )
            : PopupMenuButton<String>(
                onSelected: (action) =>
                    _handleAction(context, action, user),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: "reset",
                    child: ListTile(
                      leading: Icon(Icons.lock_reset, color: Colors.orange),
                      title: Text("Reset Password"),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: "delete",
                    child: ListTile(
                      leading: Icon(Icons.delete_forever, color: Colors.red),
                      title: Text(
                        "Delete User",
                        style: TextStyle(color: Colors.red),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
        onTap: () => _showMemberDetailSheet(context, user),
      ),
    );
  }

  void _handleAction(
    BuildContext context,
    String action,
    UserModel user,
  ) async {
    if (action == "reset") {
      final confirmed = await _showConfirmDialog(
        context,
        title: "Reset Password?",
        content:
            "This will reset the password for ITS ${user.itsNumber} to their ITS number. They can change it after logging in.",
        confirmLabel: "Reset",
        confirmColor: Colors.orange,
      );
      if (confirmed) {
        context.read<UserMgmtBloc>().add(
          UserMgmtBlocEventResetPassword(itsNumber: user.itsNumber),
        );
      }
    } else if (action == "delete") {
      final confirmed = await _showConfirmDialog(
        context,
        title: "Delete User?",
        content:
            "This permanently removes the account for ITS ${user.itsNumber}. This cannot be undone.",
        confirmLabel: "Delete",
        confirmColor: Colors.red,
      );
      if (confirmed) {
        context.read<UserMgmtBloc>().add(
          UserMgmtBlocEventDeleteUser(itsNumber: user.itsNumber),
        );
      }
    }
  }

  Future<bool> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
    required Color confirmColor,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmColor,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showMemberDetailSheet(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return FutureBuilder<MemberModel?>(
          future: () async {
            try {
              return await MemberService().getCurrentMemberInfo(
                itsNo: user.itsNumber,
              );
            } catch (_) {
              return null;
            }
          }(),
          builder: (ctx, snapshot) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.primaryLight,
                          radius: 24,
                          child: Icon(
                            Icons.person,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snapshot.data?.name ?? "ITS ${user.itsNumber}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user.role.displayName,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    // Details
                    _sheetRow(Icons.badge, "ITS", user.itsNumber.toString()),
                    if (user.markaz != null)
                      _sheetRow(
                        Icons.location_on,
                        "Markaz",
                        user.markaz!.displayName,
                      ),
                    if (snapshot.hasData && snapshot.data != null) ...[
                      _sheetRow(
                        Icons.group,
                        "Group Leader",
                        snapshot.data!.glName.isNotEmpty
                            ? snapshot.data!.glName
                            : "N/A",
                      ),
                      _sheetRow(
                        Icons.home,
                        "Mohalla",
                        snapshot.data!.mohalla.isNotEmpty
                            ? snapshot.data!.mohalla
                            : "N/A",
                      ),
                      if (snapshot.data!.remarks.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.notes,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Remarks",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    snapshot.data!.remarks,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: LinearProgressIndicator(),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

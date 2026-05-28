import 'package:bgk_ladies/bloc/member/member_bloc_events.dart';
import 'package:bgk_ladies/bloc/member/member_bloc_func.dart';
import 'package:bgk_ladies/bloc/member/member_bloc_states.dart';
import 'package:bgk_ladies/enums/markaz_enum.dart';
import 'package:bgk_ladies/models/member_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEditMemberView extends StatefulWidget {
  /// Pass an existing member to enter Edit mode; leave null for Add mode.
  final MemberModel? existingMember;

  const AddEditMemberView({super.key, this.existingMember});

  @override
  State<AddEditMemberView> createState() => _AddEditMemberViewState();
}

class _AddEditMemberViewState extends State<AddEditMemberView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _itsController;
  late final TextEditingController _nameController;
  late final TextEditingController _glNameController;
  late final TextEditingController _mohallaController;
  late final TextEditingController _remarksController;

  MarkazEnum? _selectedMarkaz;
  bool _isSubmitting = false;

  bool get _isEditMode => widget.existingMember != null;

  @override
  void initState() {
    super.initState();
    final m = widget.existingMember;
    _itsController = TextEditingController(text: m?.itsNumber ?? "");
    _nameController = TextEditingController(text: m?.name ?? "");
    _glNameController = TextEditingController(text: m?.glName ?? "");
    _mohallaController = TextEditingController(text: m?.mohalla ?? "");
    _remarksController = TextEditingController(text: m?.remarks ?? "");
    _selectedMarkaz = m?.markaz;
  }

  @override
  void dispose() {
    _itsController.dispose();
    _nameController.dispose();
    _glNameController.dispose();
    _mohallaController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MemberBloc, MemberBlocState>(
      listener: (context, state) {
        if (state is MemberStateOperationSuccess) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is MemberStateError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode ? "Edit Member" : "Add Member"),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── ITS Number ─────────────────────────────────────────────
                TextFormField(
                  controller: _itsController,
                  enabled: !_isEditMode, // ITS is immutable in edit mode
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  decoration: const InputDecoration(
                    labelText: "ITS Number",
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Required";
                    if (val.length != 8) return "ITS number must be 8 digits";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Name ───────────────────────────────────────────────────
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),

                // ── GL Name ────────────────────────────────────────────────
                TextFormField(
                  controller: _glNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: "Group Leader Name",
                    prefixIcon: Icon(Icons.group_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Mohalla ────────────────────────────────────────────────
                TextFormField(
                  controller: _mohallaController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: "Mohalla",
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Markaz ─────────────────────────────────────────────────
                DropdownButtonFormField<MarkazEnum>(
                  initialValue: _selectedMarkaz,
                  decoration: const InputDecoration(
                    labelText: "Markaz",
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  items: MarkazEnum.values.map((m) {
                    return DropdownMenuItem(
                      value: m,
                      child: Text(m.displayName),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedMarkaz = val),
                  validator: (val) => val == null ? "Please select a markaz" : null,
                ),
                const SizedBox(height: 16),

                // ── Remarks ────────────────────────────────────────────────
                TextFormField(
                  controller: _remarksController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Remarks (optional)",
                    prefixIcon: Icon(Icons.notes_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Submit ─────────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(_isEditMode ? "Save Changes" : "Add Member"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final member = MemberModel(
      itsNumber: _itsController.text.trim(),
      name: _nameController.text.trim(),
      glName: _glNameController.text.trim(),
      mohalla: _mohallaController.text.trim(),
      markaz: _selectedMarkaz!,
      remarks: _remarksController.text.trim(),
    );

    if (_isEditMode) {
      context.read<MemberBloc>().add(MemberBlocEventUpdateMember(member: member));
    } else {
      context.read<MemberBloc>().add(MemberBlocEventAddMember(member: member));
    }
  }
}

import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../l10n/app_localizations.dart';
import 'business_controller.dart';
import 'business_profile.dart';

// ============================================================================
// BUSINESS SETTINGS
// Business profile, optional modules and branches, shared by every business type.
// ============================================================================

const _textDark = Color(0xFF1D2338);
const _textGrey = Color(0xFF8E99AF);
const _borderColor = Color(0xFFF1F3F6);

class BusinessSettingsPage extends StatelessWidget {
  const BusinessSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([AppLanguage.instance, BusinessController.instance]),
      builder: (context, _) {
        final profile = BusinessController.instance.profile;
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              context.tr('business_settings_title'),
              style: const TextStyle(color: _textDark, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          body: profile == null
              ? const SizedBox.shrink()
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(context, profile),
                      const SizedBox(height: 20),
                      _buildSectionTitle(context.tr('business_modules')),
                      _buildModulesCard(context, profile),
                      const SizedBox(height: 20),
                      _buildSectionTitle(context.tr('business_branches')),
                      _buildBranchesCard(context, profile),
                      const SizedBox(height: 20),
                      _buildSectionTitle(context.tr('settings_language')),
                      _buildLanguageCard(context, profile),
                      const SizedBox(height: 20),
                      _buildResetCard(context),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textDark)),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _borderColor),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildProfileCard(BuildContext context, BusinessProfile profile) {
    final spec = profile.type.spec;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: spec.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(spec.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  '${context.tr(spec.labelKey)} · ${profile.activeBranch.name}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.tr('business_rename'),
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () async {
              final name = await _promptText(
                context,
                title: context.tr('business_rename'),
                label: context.tr('setup_name_label'),
                initial: profile.name,
              );
              if (name != null) BusinessController.instance.rename(name);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModulesCard(BuildContext context, BusinessProfile profile) {
    final spec = profile.type.spec;
    return _buildCard([
      for (final module in spec.modules)
        if (spec.optionalModules.contains(module))
          SwitchListTile(
            activeThumbColor: spec.color,
            title: Text(context.tr(businessModuleLabelKeys[module]!),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text(context.tr(businessModuleDescKeys[module]!),
                style: const TextStyle(fontSize: 12, color: _textGrey)),
            value: profile.isModuleEnabled(module),
            onChanged: (on) => BusinessController.instance.setModuleEnabled(module, on),
          )
        else
          ListTile(
            leading: Icon(Icons.check_circle, color: spec.color),
            title: Text(context.tr(businessModuleLabelKeys[module]!),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            trailing: Text(context.tr('setup_always_on'), style: const TextStyle(fontSize: 11, color: _textGrey)),
          ),
    ]);
  }

  Widget _buildBranchesCard(BuildContext context, BusinessProfile profile) {
    final color = profile.type.spec.color;
    final canDelete = profile.branches.length > 1;
    return _buildCard([
      RadioGroup<String>(
        groupValue: profile.activeBranchId,
        onChanged: (id) {
          if (id != null) BusinessController.instance.setActiveBranch(id);
        },
        child: Column(
          children: [
            for (final branch in profile.branches)
              ListTile(
                leading: Radio<String>(value: branch.id, activeColor: color),
                title: Text(branch.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(
                  branch.id == profile.activeBranchId
                      ? context.tr('branch_active')
                      : (branch.location.isEmpty ? context.tr('branch_tap_to_switch') : branch.location),
                  style: const TextStyle(fontSize: 12, color: _textGrey),
                ),
                onTap: () => BusinessController.instance.setActiveBranch(branch.id),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: _textGrey),
                  onSelected: (action) async {
                    if (action == 'edit') {
                      final updated = await _promptBranch(context, branch: branch);
                      if (updated != null) BusinessController.instance.updateBranch(updated);
                    } else if (action == 'delete') {
                      BusinessController.instance.removeBranch(branch.id);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text(context.tr('edit'))),
                    PopupMenuItem(value: 'delete', enabled: canDelete, child: Text(context.tr('delete'))),
                  ],
                ),
              ),
          ],
        ),
      ),
      const Divider(height: 1, color: _borderColor),
      ListTile(
        leading: Icon(Icons.add_business_outlined, color: color),
        title: Text(
          context.tr('branch_add'),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
        ),
        onTap: () async {
          final branch = await _promptBranch(context);
          if (branch != null) {
            BusinessController.instance.addBranch(name: branch.name, location: branch.location);
          }
        },
      ),
    ]);
  }

  Widget _buildLanguageCard(BuildContext context, BusinessProfile profile) {
    return _buildCard([
      SwitchListTile(
        activeThumbColor: profile.type.spec.color,
        secondary: const Icon(Icons.language),
        title: const Text('English', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(context.tr('settings_language_desc'), style: const TextStyle(fontSize: 12, color: _textGrey)),
        value: AppLanguage.instance.isEnglish,
        onChanged: (english) => english ? AppLanguage.instance.setEnglish() : AppLanguage.instance.setSomali(),
      ),
    ]);
  }

  Widget _buildResetCard(BuildContext context) {
    return _buildCard([
      ListTile(
        leading: const Icon(Icons.restart_alt, color: Color(0xFFEF4444)),
        title: Text(
          context.tr('business_reset'),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFFEF4444)),
        ),
        subtitle: Text(context.tr('business_reset_desc'), style: const TextStyle(fontSize: 12, color: _textGrey)),
        onTap: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(context.tr('business_reset')),
              content: Text(context.tr('business_reset_confirm')),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(context.tr('cancel'))),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(context.tr('confirm'), style: const TextStyle(color: Color(0xFFEF4444))),
                ),
              ],
            ),
          );
          if (confirmed != true || !context.mounted) return;
          Navigator.of(context).popUntil((route) => route.isFirst);
          await BusinessController.instance.reset();
        },
      ),
    ]);
  }

  Future<String?> _promptText(
    BuildContext context, {
    required String title,
    required String label,
    String initial = '',
  }) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(context.tr('cancel'))),
          TextButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
  }

  /// Asks for a branch name and location. Returns an unsaved [Branch] when
  /// adding, or [branch] with the new values when editing.
  Future<Branch?> _promptBranch(BuildContext context, {Branch? branch}) {
    final nameController = TextEditingController(text: branch?.name ?? '');
    final locationController = TextEditingController(text: branch?.location ?? '');
    return showDialog<Branch>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr(branch == null ? 'branch_add' : 'branch_edit')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: context.tr('branch_name')),
            ),
            TextField(
              controller: locationController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: context.tr('branch_location')),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(context.tr('cancel'))),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final location = locationController.text.trim();
              Navigator.pop(
                dialogContext,
                branch?.copyWith(name: name, location: location) ?? Branch(id: '', name: name, location: location),
              );
            },
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
  }
}

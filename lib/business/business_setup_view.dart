import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../l10n/app_localizations.dart';
import 'business_controller.dart';
import 'business_profile.dart';

// ============================================================================
// BUSINESS SETUP (ONBOARDING)
// Step 1: business name. Step 2: business type. Step 3: default pages,
// optional modules and the main branch.
// ============================================================================

const _brandColor = Color(0xFFFF5200);
const _textDark = Color(0xFF1D2338);
const _textGrey = Color(0xFF8E99AF);
const _borderColor = Color(0xFFF1F3F6);

class BusinessSetupView extends StatefulWidget {
  const BusinessSetupView({super.key});

  @override
  State<BusinessSetupView> createState() => _BusinessSetupViewState();
}

class _BusinessSetupViewState extends State<BusinessSetupView> {
  static const _stepCount = 3;

  final _nameController = TextEditingController();
  final _branchController = TextEditingController();
  int _step = 0;
  BusinessType? _type;
  final Set<BusinessModule> _optionalModules = {};
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  Color get _accent => _type?.spec.color ?? _brandColor;

  bool get _canContinue {
    switch (_step) {
      case 0:
        return _nameController.text.trim().isNotEmpty;
      case 1:
        return _type != null;
      default:
        return !_saving;
    }
  }

  void _selectType(BusinessType type) {
    setState(() {
      if (_type != type) _optionalModules.clear();
      _type = type;
    });
  }

  Future<void> _next() async {
    if (_step < _stepCount - 1) {
      FocusScope.of(context).unfocus();
      setState(() => _step++);
      return;
    }
    setState(() => _saving = true);
    final branchName = _branchController.text.trim();
    await BusinessController.instance.createBusiness(
      name: _nameController.text,
      type: _type!,
      optionalModules: _optionalModules,
      mainBranchName: branchName.isEmpty ? context.tr('setup_main_branch_default') : branchName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppLanguage.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: _step > 0
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: _textDark),
                    onPressed: () => setState(() => _step--),
                  )
                : null,
            title: Text(
              context.tr('setup_title'),
              style: const TextStyle(fontWeight: FontWeight.bold, color: _textDark),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: ActionChip(
                  avatar: Icon(Icons.language, size: 18, color: _accent),
                  label: Text(
                    AppLanguage.instance.isSomali ? 'SO' : 'EN',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  onPressed: AppLanguage.instance.toggleLanguage,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                _buildProgress(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: switch (_step) {
                      0 => _buildNameStep(),
                      1 => _buildTypeStep(),
                      _ => _buildModulesStep(),
                    },
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('setup_step').replaceFirst('{current}', '${_step + 1}').replaceFirst('{total}', '$_stepCount'),
            style: const TextStyle(fontSize: 12, color: _textGrey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_step + 1) / _stepCount,
              minHeight: 6,
              backgroundColor: _borderColor,
              color: _accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeading(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textDark)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(fontSize: 14, color: _textGrey)),
        ],
      ),
    );
  }

  Widget _buildNameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeading(context.tr('setup_name_title'), context.tr('setup_name_subtitle')),
        TextField(
          controller: _nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) {
            if (_canContinue) _next();
          },
          decoration: _inputDecoration(
            label: context.tr('setup_name_label'),
            hint: context.tr('setup_name_hint'),
            icon: Icons.business,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeading(context.tr('setup_type_title'), context.tr('setup_type_subtitle')),
        for (final type in BusinessType.values) _buildTypeCard(type),
      ],
    );
  }

  Widget _buildTypeCard(BusinessType type) {
    final spec = type.spec;
    final selected = _type == type;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: selected ? spec.color.withValues(alpha: 0.06) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? spec.color : _borderColor, width: selected ? 2 : 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: spec.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(spec.icon, color: spec.color, size: 26),
        ),
        title: Text(
          context.tr(spec.labelKey),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textDark),
        ),
        subtitle: Text(context.tr(spec.subtitleKey), style: const TextStyle(fontSize: 12, color: _textGrey)),
        trailing: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? spec.color : _textGrey,
        ),
        onTap: () => _selectType(type),
      ),
    );
  }

  Widget _buildModulesStep() {
    final spec = _type!.spec;
    final defaults = spec.modules.where((m) => !spec.optionalModules.contains(m));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeading(context.tr('setup_modules_title'), context.tr('setup_modules_subtitle')),
        _buildSectionTitle(context.tr('setup_default_pages')),
        _buildCard([
          for (final module in defaults)
            ListTile(
              leading: Icon(Icons.check_circle, color: spec.color),
              title: Text(context.tr(businessModuleLabelKeys[module]!),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(context.tr(businessModuleDescKeys[module]!),
                  style: const TextStyle(fontSize: 12, color: _textGrey)),
              trailing: Text(context.tr('setup_always_on'), style: const TextStyle(fontSize: 11, color: _textGrey)),
            ),
        ]),
        const SizedBox(height: 20),
        _buildSectionTitle(context.tr('setup_optional_modules')),
        _buildCard([
          for (final module in spec.optionalModules)
            SwitchListTile(
              activeThumbColor: spec.color,
              title: Text(context.tr(businessModuleLabelKeys[module]!),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(context.tr(businessModuleDescKeys[module]!),
                  style: const TextStyle(fontSize: 12, color: _textGrey)),
              value: _optionalModules.contains(module),
              onChanged: (on) => setState(() => on ? _optionalModules.add(module) : _optionalModules.remove(module)),
            ),
        ]),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: Text(context.tr('setup_modules_later'), style: const TextStyle(fontSize: 12, color: _textGrey)),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle(context.tr('setup_main_branch')),
        TextField(
          controller: _branchController,
          textCapitalization: TextCapitalization.words,
          decoration: _inputDecoration(
            label: context.tr('branch_name'),
            hint: context.tr('setup_main_branch_default'),
            icon: Icons.location_on_outlined,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: Text(context.tr('setup_branches_later'), style: const TextStyle(fontSize: 12, color: _textGrey)),
        ),
      ],
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

  InputDecoration _inputDecoration({required String label, required String hint, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _accent, width: 2),
      ),
    );
  }

  Widget _buildFooter() {
    final isLast = _step == _stepCount - 1;
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _accent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _canContinue ? _next : null,
          child: Text(
            context.tr(isLast ? 'setup_create' : 'setup_continue'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

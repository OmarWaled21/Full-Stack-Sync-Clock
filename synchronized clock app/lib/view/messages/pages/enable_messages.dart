import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized_clock/core/colors.dart';
import 'package:synchronized_clock/core/helper/lang_extention.dart';
import 'package:synchronized_clock/core/helper/navigator_extention.dart';
import 'package:synchronized_clock/view/auth/widgets/custom_button.dart';
import 'package:synchronized_clock/view/messages/widgets/build_toggle_section.dart';
import 'package:synchronized_clock/view_model/messages_cubit/messages_cubit.dart';

class EnableMessages extends StatefulWidget {
  const EnableMessages({super.key});

  @override
  State<EnableMessages> createState() => _EnableMessagesState();
}

class _EnableMessagesState extends State<EnableMessages> {
  final _formKey = GlobalKey<FormState>();
  final _prefsFuture = SharedPreferences.getInstance();

  final _controllers = {
    'whatsapp': TextEditingController(),
    'gmail': TextEditingController(),
    'sms': TextEditingController(),
  };

  final _isEnabled = {'whatsapp': false, 'gmail': false, 'sms': false};

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await _prefsFuture;
    setState(() {
      _isEnabled['whatsapp'] = prefs.getBool('isEnabled') ?? false;
      _isEnabled['gmail'] = prefs.getBool('gmailIsEnabled') ?? false;
      _isEnabled['sms'] = prefs.getBool('smsIsEnabled') ?? false;

      _controllers['whatsapp']!.text = prefs.getString('groupUrl') ?? '';
      _controllers['gmail']!.text = prefs.getString('email') ?? '';
      _controllers['sms']!.text = prefs.getString('phone') ?? '';
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await _prefsFuture;
    await prefs.setBool('isEnabled', _isEnabled['whatsapp']!);
    await prefs.setBool('gmailIsEnabled', _isEnabled['gmail']!);
    await prefs.setBool('smsIsEnabled', _isEnabled['sms']!);

    await prefs.setString('groupUrl', _controllers['whatsapp']!.text.trim());
    await prefs.setString('email', _controllers['gmail']!.text.trim());
    await prefs.setString('phone', _controllers['sms']!.text.trim());
  }

  void _handleSwitchChange(String type, bool value, void Function() onDisable) {
    setState(() => _isEnabled[type] = value);
    if (!value) onDisable();
  }

  void _saveChanges(MessagesCubit cubit) async {
    if (!_formKey.currentState!.validate()) return;
    await _savePrefs();

    final groupUrl = _controllers['whatsapp']!.text.trim().replaceFirst(
      'https://chat.whatsapp.com/',
      '',
    );

    final email = _controllers['gmail']!.text.trim();
    final phone = _controllers['sms']!.text.trim();

    cubit.switchActiveSettings(
      whatsappIsActive: _isEnabled['whatsapp']!,
      gmailIsActive: _isEnabled['gmail']!,
      smsIsActive: _isEnabled['sms']!,
      groupUrl: groupUrl,
      email: email,
      phone: phone,
    );
  }

  String? _validateWhatsAppUrl(String value) {
    if (value.isEmpty) return 'يرجى إدخال رابط المجموعة';
    if (!value.startsWith('https://chat.whatsapp.com/')) {
      return 'يرجى إدخال رابط صحيح يبدأ بـ https://chat.whatsapp.com/';
    }
    return null;
  }

  Widget _buildSection({
    required BuildContext context,
    required String type,
    required String title,
    required String description,
    required String label,
    required void Function() onDisable,
    String? Function(String)? validator,
  }) {
    return buildToggleSection(
      title: title,
      description: description,
      isEnabled: _isEnabled[type]!,
      onToggle: (val) => _handleSwitchChange(type, val, onDisable),
      controller: _controllers[type]!,
      validator: validator,
      label: label,
    );
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;

    return BlocConsumer<MessagesCubit, MessagesState>(
      listener: (context, state) {
        if (state is MessagesSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم تحديث الإعدادات بنجاح')));
        } else if (state is MessagesFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('خطأ: ${state.message}')));
        }
      },
      builder: (context, state) {
        final cubit = context.read<MessagesCubit>();
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.whiteColor),
              onPressed: () => context.pop(),
            ),
            title: Text(
              lang.messages,
              style: const TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: AppColors.backgroundColor,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildSection(
                    context: context,
                    type: 'whatsapp',
                    title: lang.enableSendMessagesToWhatsApp,
                    description: lang.messageWhatsappDectionary,
                    label: lang.groupUrl,
                    onDisable: () {},
                    validator: _validateWhatsAppUrl,
                  ),
                  _buildSection(
                    context: context,
                    type: 'gmail',
                    title: lang.enableSendMessagesToGmail,
                    description: lang.messagegmailDectionary,
                    label: lang.email,
                    onDisable: () {},
                  ),
                  _buildSection(
                    context: context,
                    type: 'sms',
                    title: lang.enableSendMessagesSms,
                    description: lang.messageSmsDectionary,
                    label: lang.phone,
                    onDisable: () {},
                  ),
                  CustomButton(
                    color: AppColors.blueColor,
                    borderColor: AppColors.whiteColor,
                    text: lang.save,
                    onPressed: () => _saveChanges(cubit),
                  ),
                  if (state is MessagesLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

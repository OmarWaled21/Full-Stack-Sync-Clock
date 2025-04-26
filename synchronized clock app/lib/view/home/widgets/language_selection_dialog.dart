import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synchronized_clock/core/helper/lang_extention.dart';
import 'package:synchronized_clock/view_model/localization_cubit/localization_cubit.dart';

class LanguageSelectionDialog extends StatelessWidget {
  const LanguageSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.lang.language), // "Select Language"
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageOption(label: 'English', locale: const Locale('en')),
          _LanguageOption(label: 'العربية', locale: const Locale('ar')),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final Locale locale;

  const _LanguageOption({required this.label, required this.locale});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      onTap: () {
        context.read<LocalizationCubit>().setLocale(locale);
        Navigator.pop(context); // نغلق الـ dialog
      },
    );
  }
}

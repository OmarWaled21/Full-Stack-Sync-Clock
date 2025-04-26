import 'package:flutter/material.dart';
import 'package:synchronized_clock/generated/l10n.dart';

extension LangExtention on BuildContext {
  S get lang => S.of(this);
}

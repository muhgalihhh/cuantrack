import 'package:flutter/material.dart';

class CTBottomSheetTheme {
  CTBottomSheetTheme._();

  static const lightBottomSheetTheme = BottomSheetThemeData(
    showDragHandle: true,
    backgroundColor: Color(0xFFE3F2FD),
    modalBackgroundColor: Color(0xFFE3F2FD),
    elevation: 0,
    constraints: const BoxConstraints(minWidth: double.infinity),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
    ),
  );

  static const darkBottomSheetTheme = BottomSheetThemeData(
    showDragHandle: true,
    backgroundColor: Color(0xFF1976D2),
    modalBackgroundColor: Color(0xFF1976D2),
    elevation: 0,
    constraints: const BoxConstraints(minWidth: double.infinity),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
    ),
  );
}

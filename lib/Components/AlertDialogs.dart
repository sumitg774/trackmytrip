import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Buttons.dart';
import 'TextFields.dart';

class SimpleAlertDialog extends StatefulWidget {
  String title;
  Widget content;
  final VoidCallback onConfirmButtonPressed;
  String confirmBtnText;
  bool confirmBtnState;
  bool wantOneButton;

  SimpleAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirmButtonPressed,
    required this.confirmBtnText,
    this.confirmBtnState = false,
    this.wantOneButton = false,
  });

  @override
  State<SimpleAlertDialog> createState() => _SimpleAlertDialogState();
}

class _SimpleAlertDialogState extends State<SimpleAlertDialog> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CupertinoColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: CupertinoColors.systemBlue,
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      actionsAlignment: MainAxisAlignment.center,

      title: Text(widget.title),

      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        child: widget.content
      ),

      actions: [
        Row(
          children: [
            !widget.wantOneButton ?
            Expanded(
              flex: 1,
              child: SimpleButton(
                onPressed: () => Navigator.of(context).pop(),
                buttonText: "Cancel",
                isCancelButton: true,
              ),
            ): SizedBox(),
            SizedBox(width: widget.wantOneButton ? 0:12),
            Expanded(
              flex: 1,
              child: SimpleButton(
                onPressed: widget.onConfirmButtonPressed,
                buttonText: widget.confirmBtnText,
                isDisabled: widget.confirmBtnState,
              ),
            ),
          ],
        ),
      ],
    );
  }
}




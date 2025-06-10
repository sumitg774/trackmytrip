import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Buttons.dart';
import 'TextFields.dart';

class SimpleAlertDialog extends StatefulWidget {
  String title;
  String? selectedLocation;
  final VoidCallback onPressed;
  bool endDialog;

  SimpleAlertDialog({super.key, required this.title, required this.selectedLocation, required this.onPressed, this.endDialog = false});

  @override
  State<SimpleAlertDialog> createState() => _SimpleAlertDialogState();
}

class _SimpleAlertDialogState extends State<SimpleAlertDialog> {

  late TextEditingController OtherLocationText;
  TextEditingController DestinationLocation = TextEditingController();
  TextEditingController DescriptionText = TextEditingController();

  @override
  void initState() {
    super.initState();
    OtherLocationText = TextEditingController();
  }

  @override
  void dispose() {
    OtherLocationText.dispose();
    super.dispose();
  }

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
        child:
            widget.endDialog
                ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      hintText: "Enter Destination",
                      controller: DestinationLocation,
                    ),
                    const SizedBox(height: 18),
                    DescriptionTextField(
                      hintText: "Description",
                      controller: DescriptionText,
                    ),
                  ],
                )
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomDropdown<String>(
                      hint: "Select Start Location",
                      value: widget.selectedLocation,
                      items: ["Home", "Kibbcom Office", "Other"],
                      onChanged: (val) {
                        setState(() {
                          widget.selectedLocation = val;
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    widget.selectedLocation == "Other"
                        ? CustomTextField(
                          hintText: "Enter Other Location",
                          controller: OtherLocationText,
                        )
                        : const SizedBox(height: 0),
                  ],
                ),
      ),

      actions: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: SimpleButton(
                onPressed: () => Navigator.of(context).pop(),
                buttonText: "Cancel",
                isCancelButton: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: SimpleButton(
                onPressed: widget.onPressed,
                buttonText: widget.endDialog ? "End" : "Start",
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../Utils/AppColorTheme.dart';

class SquareIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color color;
  final bool isEnabled;

  const SquareIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.color = const Color(0xFF2979FF),
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isEnabled ? color : Colors.grey.shade300;
    final Color contentColor = isEnabled ? Colors.white : Colors.grey.shade600;

    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow:
              isEnabled
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(4, 4),
                      blurRadius: 10,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      offset: const Offset(-4, -4),
                      blurRadius: 10,
                    ),
                  ]
                  : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: contentColor, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: contentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransparentFab extends StatelessWidget {
  final String expenditure;
  final String kms;
  final String text1;
  final String text2;

  const TransparentFab({
    super.key,
    required this.expenditure,
    required this.kms,
    required this.text1,
    required this.text2
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 10,
                    bottom: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            text1,
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "₹ $expenditure",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.activeBlue,
                            ),
                          ),
                        ],
                      ),
                      // Vertical Divider
                      Container(
                        height: 30,
                        width: 1.5,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        color: CupertinoColors.activeBlue,
                      ),
                      Column(
                        children: [
                          Text(
                            text2,
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "${kms} km",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.activeBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .slideY(begin: 1.0, end: 0.0, duration: 600.ms, curve: Curves.easeOut)
        .fadeIn(duration: 900.ms, curve: Curves.easeOut);
  }
}

class SimpleButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  bool isCancelButton;
  bool isDisabled;

  SimpleButton({
    Key? key,
    required this.buttonText,
    required this.onPressed,
    this.isCancelButton = false,
    this.isDisabled = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isDisabled ? (){} : onPressed,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color:
                isDisabled ?
                CupertinoColors.systemGrey2.withOpacity(0.4)
                :
                isCancelButton
                    ? CupertinoColors.systemRed.withOpacity(0.4)
                    : CupertinoColors.systemBlue.withOpacity(0.4),
            border: Border.all(
              color:
              isDisabled ?
              CupertinoColors.systemGrey.withOpacity(0.4)
                  :
                  isCancelButton
                      ? CupertinoColors.systemRed.withOpacity(0.5)
                      : CupertinoColors.systemBlue.withOpacity(0.5),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              buttonText,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color:
                isDisabled ?
                CupertinoColors.systemGrey.withOpacity(0.8)
                    :
                    isCancelButton
                        ? CupertinoColors.destructiveRed
                        : CupertinoColors.activeBlue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class SimpleButton2 extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final bool isCancelButton;

  const SimpleButton2({
    Key? key,
    required this.buttonText,
    required this.onPressed,
    this.isCancelButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical:5 ,horizontal: 20),
        decoration: BoxDecoration(
          color:isCancelButton
            ?
          CupertinoColors.systemGrey6
            :CupertinoColors.activeBlue.withOpacity(0.4),

          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color:
            isCancelButton
                ? CupertinoColors.systemGrey6
                : CupertinoColors.systemBlue.withOpacity(0.4),
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: TextStyle(
              color: isCancelButton ? CupertinoColors.systemGrey : CupertinoColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500
            ),
          ),
        ),
      ),
    );
  }
}


class CustomSwitchContentButtons extends StatefulWidget {
  late String firstBtnName;
  late String secondBtnName;
  late Widget firstWidget;
  late Widget secondWidget;
  final ValueChanged<bool>? onToggle;

  CustomSwitchContentButtons({
    super.key,
    required this.firstWidget,
    required this.secondWidget,
    this.firstBtnName = "Single",
    this.secondBtnName = "Range",
    this.onToggle,
  });

  @override
  State<CustomSwitchContentButtons> createState() =>
      _CustomSwitchContentButtonsState();
}

class _CustomSwitchContentButtonsState
    extends State<CustomSwitchContentButtons> {
  bool aorb = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(25)

          ),
          child: Row(
            children: [
              Expanded(
                child: SimpleButton2(
                  buttonText: widget.firstBtnName,
                  isCancelButton: !aorb,
                  onPressed: () {
                    setState(() {
                      aorb = true;
                    });
                    widget.onToggle?.call(true);
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SimpleButton2(
                  buttonText: widget.secondBtnName,
                  isCancelButton: aorb,
                  onPressed: () {
                    setState(() {
                      aorb = false;
                    });
                    widget.onToggle?.call(false); // Notify parent
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        aorb ? widget.firstWidget : widget.secondWidget,
      ],
    );
  }
}








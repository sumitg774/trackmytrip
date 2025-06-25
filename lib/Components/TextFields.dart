import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Utils/AppColorTheme.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final void Function(T?) onChanged;
  bool checked;

   CustomDropdown({
    Key? key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.checked = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 15,
          color: Colors.grey[500],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: CupertinoColors.activeBlue, width: 1.2),
        ),
      ),
      icon: checked ? Icon(Icons.check_rounded, color: CupertinoColors.systemGreen,):Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[600]),
      dropdownColor: Colors.white,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      items: items
          .map((item) => DropdownMenuItem<T>(
        value: item,
        child: Text(item.toString()),
      ))
          .toList(),
    );
  }
}


class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool suffixIcon;

  CustomTextField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        // suffixIcon: suffixIcon ? Icon(Icons.share_location) : SizedBox(),
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 15,
          color: Colors.grey[500],
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.blueAccent, width: 1.2),
        ),
      ),
      cursorColor: CupertinoColors.activeBlue,
    );
  }
}

class CustomTextField2 extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool suffixIcon;

  CustomTextField2({
    Key? key,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        // suffixIcon: suffixIcon ? Icon(Icons.share_location) : SizedBox(),
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 12,
          color: Colors.grey[500],
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blueAccent, width: 1.2),
        ),
      ),
      cursorColor: CupertinoColors.activeBlue,
    );
  }
}

class CustomInputTextField extends StatefulWidget {
  late TextEditingController controller;
  late String label;
  late TextInputType keyboard;
  late Widget? leadingIcon;
  late Widget? trialingIcon;
  late bool isobscure;
  late String? Function(String?)? ValidateTextField;
  late TextInputAction textInputAction;

  CustomInputTextField(
      {super.key,
        required this.controller,
        required this.label,
        this.keyboard = TextInputType.text,
        this.leadingIcon,
        this.trialingIcon,
        this.isobscure = false,
        this.textInputAction = TextInputAction.next,
        this.ValidateTextField});

  @override
  State<CustomInputTextField> createState() => _CustomInputTextFieldState();
}

class _CustomInputTextFieldState extends State<CustomInputTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      cursorColor: AppColors.customBlue,
      keyboardAppearance: Brightness.light,
      textInputAction: widget.textInputAction,
      keyboardType: widget.keyboard,
      style: TextStyle(
          color: AppColors.customBlue
      ),
      decoration: InputDecoration(
        prefixIcon: widget.leadingIcon,
        suffixIcon: widget.trialingIcon,
        filled: true,
        fillColor: AppColors.customGrey,
        label: Text(widget.label),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.redAccent)),
        errorStyle: TextStyle(color: Colors.redAccent),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 2)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.customBlue, width: 2)
        ),
        labelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          color: AppColors.customBlue,
          fontSize: 16,
        ),
      ),
      validator: widget.ValidateTextField,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}

class CardTitleText extends StatelessWidget {

  late String text;
  late Color? color ;
  late TextAlign textalign ;
  late double fontsize;
  late FontWeight fontweight;
  late FontStyle fontStyle;
  late int maxlines;

  CardTitleText({
    super.key,
    required this.text,
    this.color = Colors.white,
    this.textalign = TextAlign.center,
    this.fontsize = 16,
    this.fontweight = FontWeight.normal,
    this.fontStyle = FontStyle.normal,
    this.maxlines = 1
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontsize,
        fontWeight: fontweight,
        color: color,
        fontStyle: fontStyle,
      ),
      textAlign: textalign,
      // maxLines: maxlines,
      softWrap: true,
    );
  }
}


class DescriptionTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;

  DescriptionTextField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: 3,
      obscureText: obscureText,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 15,
          color: Colors.grey[500],
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.blueAccent, width: 1.2),
        ),
      ),
      cursorColor: CupertinoColors.activeBlue,
    );
  }
}

class CustomPasswordTextField extends StatefulWidget {
  late TextEditingController controller;
  late String label;
  String? Function(String?)? ValidateTextfield;
  TextInputAction textInputAction;

  CustomPasswordTextField({
    super.key,
    required this.controller,
    required this.label,
    this.ValidateTextfield,
    this.textInputAction = TextInputAction.next
  });

  @override
  State<CustomPasswordTextField> createState() =>
      _CustomPasswordTextFieldState();
}

class _CustomPasswordTextFieldState extends State<CustomPasswordTextField> {
  var isobscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      cursorColor: AppColors.customBlue,
      keyboardAppearance: Brightness.light,
      textInputAction: widget.textInputAction,
      obscureText: isobscure,
      keyboardType: TextInputType.text,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(
          color: AppColors.customBlue
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.vpn_key_rounded,
          color: AppColors.customBlue,
        ),
        filled: true,
        fillColor: AppColors.customGrey,
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              isobscure = !isobscure;
            });
          },
          child: Icon(
            isobscure ? (Icons.visibility) : (Icons.visibility_off),
            color: AppColors.customBlue,
          ),
        ),
        label: Text(widget.label),
        errorMaxLines: 2,
        errorStyle: TextStyle(color: Colors.redAccent),
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent, width: 2),
            borderRadius: BorderRadius.circular(12)),
        focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(12)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.customBlue, width: 2),
        ),
        labelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          color: AppColors.customBlue,
          fontSize: 16,
        ),
      ),
      validator: widget.ValidateTextfield,
    );
  }
}
class DatePickerTextField extends StatefulWidget {

  late TextEditingController controller;
  late String label;
  late Widget? leadingIcon;
  late Widget? trialingIcon;
  final bool prefillToday;
  late String? Function(String?)? ValidateTextField;
  late bool customBool;

  DatePickerTextField(
      {super.key,
        required this.controller,
        required this.label,
        this.leadingIcon,
        this.trialingIcon,
        this.ValidateTextField,
        required this.prefillToday,
        this.customBool = false
      });

  @override
  State<DatePickerTextField> createState() => _DatePickerTextFieldState();
}

class _DatePickerTextFieldState extends State<DatePickerTextField> {


  @override
  void initState() {
    super.initState();
    if (widget.prefillToday) {
      // Set today's date if prefillToday is true
      // widget.controller.text = DateTime.now().toString().split(" ")[0];
      widget.controller.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    }
  }

  Future<DateTime?> openDatePicker() {
    return showDatePicker(
      // initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        context: context,
        builder: (context, child){
          return Theme(data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                  primary: AppColors.customBlue,
                  onPrimary: AppColors.customGrey,
                  onSurface: AppColors.customWhite
              ),
              datePickerTheme: DatePickerThemeData(
                backgroundColor: AppColors.customGrey,
                headerBackgroundColor: AppColors.customGrey50,
                headerForegroundColor: AppColors.customWhite,
                weekdayStyle: TextStyle(color: AppColors.customBlue),
                /*  todayBackgroundColor: WidgetStatePropertyAll(AppColors.customCircularBarGrey),
            todayForegroundColor: WidgetStatePropertyAll(Colors.black),*/
                confirmButtonStyle: ButtonStyle(
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor:
                  WidgetStateProperty.all(AppColors.customBlue),
                  foregroundColor:
                  WidgetStateProperty.all(Colors.white),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                cancelButtonStyle: ButtonStyle(
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor:
                  WidgetStateProperty.all(AppColors.customRed),
                  foregroundColor:
                  WidgetStateProperty.all(Colors.white),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)
                      ),
                      backgroundColor: AppColors.customBlue,
                      foregroundColor: AppColors.customWhite
                  )
              )
          ),
              child: child!);
        }
    ).then((value) {
      setState(() {
        widget.controller.text = DateFormat('dd-MM-yyyy').format(value!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: openDatePicker,
      controller: widget.controller,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      readOnly: true,
      cursorColor: AppColors.customBlue,
      keyboardAppearance: Brightness.light,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: widget.leadingIcon,
        hintText: widget.label,
        suffixIcon:
        GestureDetector(onTap: openDatePicker, child: widget.trialingIcon),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.customRed, width: 2)),
        errorStyle: TextStyle(color: AppColors.customRed,),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.customRed, width: 2)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.blueAccent, width: 1.2),
        ),
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      validator: widget.ValidateTextField,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}


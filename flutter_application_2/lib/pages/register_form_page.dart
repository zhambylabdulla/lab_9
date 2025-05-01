import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user.dart';
import 'user_info_page.dart';

class RegisterFormPage extends StatefulWidget {
  const RegisterFormPage({super.key});

  @override
  State<RegisterFormPage> createState() => _RegisterFormPageState();
}

class _RegisterFormPageState extends State<RegisterFormPage> {
  bool _hidePass = true;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _storyController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  final List<String> _countries = ['Kazakhstan', 'Russia', 'Ukraine', 'Germany', 'France'];
  String _selectedCountry = 'Kazakhstan';

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passFocus = FocusNode();

  User newUser = User();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _storyController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _fieldFocusChange(BuildContext context, FocusNode current, FocusNode next) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  InputDecoration buildInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    VoidCallback? onClear,
    bool isPassword = false,
    VoidCallback? onTogglePassword,
    bool? hidePassword,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.black),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(hidePassword! ? Icons.visibility : Icons.visibility_off, color: Colors.black),
              onPressed: onTogglePassword,
            )
          : onClear != null
              ? IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onClear,
                )
              : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.r)),
        borderSide: const BorderSide(color: Colors.black, width: 2.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.r)),
        borderSide: const BorderSide(color: Color.fromARGB(255, 10, 45, 73), width: 2.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text('title'.tr(), style: TextStyle(fontSize: 20.sp)),
  centerTitle: true,
  actions: [
    PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      onSelected: (Locale locale) {
        context.setLocale(locale);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
        PopupMenuItem<Locale>(
          value: const Locale('en'),
          child: Text('English'),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('kk'),
          child: Text('Қазақша'),
        ),
      ],
    ),
  ],
),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            TextFormField(
              focusNode: _nameFocus,
              controller: _nameController,
              autofocus: true,
              onFieldSubmitted: (_) => _fieldFocusChange(context, _nameFocus, _phoneFocus),
              decoration: buildInputDecoration(
                label: '${'full_name'.tr()} *',
                hint: 'name_required'.tr(),
                icon: Icons.person,
                onClear: () => _nameController.clear(),
              ),
              validator: validateName,
              onSaved: (value) => newUser.name = value!,
            ),
            SizedBox(height: 10.h),
            TextFormField(
              focusNode: _phoneFocus,
              controller: _phoneController,
              onFieldSubmitted: (_) => _fieldFocusChange(context, _phoneFocus, _passFocus),
              decoration: buildInputDecoration(
                label: '${'phone_number'.tr()} *',
                hint: '(###)###-####',
                icon: Icons.call,
                onClear: () => _phoneController.clear(),
              ).copyWith(helperText: 'phone_format_error'.tr()),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter(RegExp(r'^[()\d -]{1,15}\$'), allow: true),
              ],
              validator: (value) => validatePhoneNumber(value!) ? null : 'phone_format_error'.tr(),
              onSaved: (value) => newUser.phone = value!,
            ),
            SizedBox(height: 10.h),
            TextFormField(
              controller: _emailController,
              decoration: buildInputDecoration(
                label: 'email_address'.tr(),
                hint: '',
                icon: Icons.mail,
                onClear: () => _emailController.clear(),
              ),
              keyboardType: TextInputType.emailAddress,
              onSaved: (value) => newUser.email = value!,
            ),
            SizedBox(height: 10.h),
            DropdownButtonFormField(
              decoration: buildInputDecoration(
                label: 'country'.tr(),
                hint: '',
                icon: Icons.map,
              ),
              items: _countries.map((country) => DropdownMenuItem(value: country, child: Text(country))).toList(),
              onChanged: (country) {
                setState(() {
                  _selectedCountry = country as String;
                  newUser.country = country;
                });
              },
              value: _selectedCountry,
            ),
            SizedBox(height: 10.h),
            TextFormField(
              controller: _storyController,
              maxLines: 3,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
              decoration: buildInputDecoration(
                label: 'life_story'.tr(),
                hint: '',
                icon: Icons.book,
                onClear: () => _storyController.clear(),
              ),
              onSaved: (value) => newUser.story = value!,
            ),
            SizedBox(height: 10.h),
            TextFormField(
              focusNode: _passFocus,
              controller: _passController,
              obscureText: _hidePass,
              maxLength: 8,
              decoration: buildInputDecoration(
                label: '${'password'.tr()} *',
                hint: '',
                icon: Icons.security,
                isPassword: true,
                hidePassword: _hidePass,
                onTogglePassword: () => setState(() => _hidePass = !_hidePass),
              ),
              validator: _validatePassword,
            ),
            SizedBox(height: 10.h),
            TextFormField(
              controller: _confirmPassController,
              obscureText: _hidePass,
              maxLength: 8,
              decoration: buildInputDecoration(
                label: '${'confirm_password'.tr()} *',
                hint: '',
                icon: Icons.border_color,
                isPassword: true,
                hidePassword: _hidePass,
                onTogglePassword: () => setState(() => _hidePass = !_hidePass),
              ),
              validator: _validatePassword,
            ),
            SizedBox(height: 15.h),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('register_button'.tr(), style: TextStyle(fontSize: 16.sp)),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullName', newUser.name);
    await prefs.setString('email', newUser.email);
    await prefs.setString('phone', newUser.phone);
    await prefs.setString('country', newUser.country);
    await prefs.setString('story', newUser.story);
    await prefs.setBool('isAuthenticated', true);

    _showDialog(name: _nameController.text);
  } else {
    _showMessage(message: 'Form is not valid! Please review and correct');
  }
}


  String? validateName(String? value) {
    final nameExp = RegExp(r'^[A-Za-z ]+\$');
    if (value == null || value.isEmpty) {
      return 'name_required'.tr();
    } else if (!nameExp.hasMatch(value)) {
      return 'alphabetical_characters'.tr();
    }
    return null;
  }

  bool validatePhoneNumber(String input) {
    final phoneExp = RegExp(r'^\(\d{3}\)\d{3}-\d{4}\$');
    return phoneExp.hasMatch(input);
  }

  String? _validatePassword(String? value) {
    if (_passController.text.length != 8) {
      return 'password_length_error'.tr();
    } else if (_confirmPassController.text != _passController.text) {
      return 'passwords_mismatch_error'.tr();
    }
    return null;
  }

  void _showMessage({required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.red,
        content: Text(
          message.tr(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }

  void _showDialog({required String name}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('registration_successful'.tr(), style: TextStyle(color: Colors.green, fontSize: 18.sp)),
        content: Text(
          'verified_register_form'.tr(namedArgs: {'name': name}),
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserInfoPage(userInfo: newUser)),
              );
            },
            child: Text('verified_button'.tr(), style: TextStyle(color: Colors.green, fontSize: 16.sp)),
          ),
        ],
      ),
    );
  }
}
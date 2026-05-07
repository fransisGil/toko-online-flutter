import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:latihan5/app_config.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nama = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isHidden = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register User'),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Form(
            key: _formKey,
            child: Column(
              spacing: 16,
              children: [
                Icon(
                  Icons.person_add,
                  size: 80,
                  color: Colors.blue,
                ),
                TextFormField(
                  controller: _nama,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Nama Lengkap wajib diisi.";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _email,
                  decoration: InputDecoration(
                    labelText: 'Alamat Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Alamat Email wajib diisi.";
                    }
                    if (!value.contains('@')) {
                      return "Invalid email address";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _password,
                  obscureText: _isHidden,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () {
                              setState(() {
                                _isHidden = !_isHidden;
                              });
                            },
                      icon: Icon(
                        _isHidden ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Password wajib diisi.";
                    }
                    if (value.length < 8) {
                      return "Password minimal 8 karakter.";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              try {
                                final user = await AppConfig().account.create(
                                    userId: ID.unique(),
                                    email: _email.text,
                                    password: _password.text,
                                    name: _nama.text);
                                if (user.email.isNotEmpty && context.mounted) {
                                  showSnackBar(
                                      context, 'Registration Successful');
                                  Navigator.pushReplacementNamed(
                                      context, '/login');
                                }
                              } on AppwriteException catch (errorProvider) {
                                setState(() {
                                  _isLoading = false;
                                });
                                // ignore: use_build_context_synchronously
                                showSnackBar(context,
                                    'Registration failed: $errorProvider');
                              }
                            }
                          },
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text('Register'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text('Kembali ke Login'),
                ),
              ],
            )),
      ),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
      BuildContext context, String text) {
    return ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }
}

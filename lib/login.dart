import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:latihan5/app_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isHidden = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Form(
            key: _formKey,
            child: Column(
              spacing: 16,
              children: [
                Icon(
                  Icons.store,
                  size: 80,
                  color: Colors.blue,
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
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        final login = await AppConfig().account.createEmailPasswordSession(
                                email: _email.text, password: _password.text);
                        
                        if (login.userId.isNotEmpty && context.mounted) {
                          showSnackBar(context, 'Login successful');
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      } on AppwriteException catch (errorProvider) {
                        showSnackBar(context, 'Login failed: $errorProvider');
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text('Login'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  child: Text('Belum punya akun? Register di sini.'),
                ),
              ],
            )),
      ),
    );
  }

  void showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      text,
    )));
  }
}

import 'package:flutter/material.dart';
import 'package:latihan5/app_config.dart';
import 'package:latihan5/kategori.dart';
import 'package:latihan5/produk.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _menuIndex = 0;

  Widget _switchPage() {
    switch (_menuIndex) {
      case 0:
        return Center(
          child: Text('Home'),
        );
      case 1:
        return KategoriPage();
      case 2:
        return ProdukPage();
      case 3:
        return Center(
          child: Text('Transaksi'),
        );
      default:
        return Center(
          child: Text('Home'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          PopupMenuButton(
            position: PopupMenuPosition.under,
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {},
                child: Text('Ganti Password'),
              ),
              PopupMenuItem(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Log Out'),
                        content: Text('Yakin melakukan log out?'),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              await AppConfig()
                                  .account
                                  .deleteSession(sessionId: 'current');
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/',
                                (route) => false,
                              );
                            },
                            child: Text('Log Out'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Batal'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Log Out'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: _switchPage(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _menuIndex,
        onTap: (value) {
          setState(() {
            _menuIndex = value;
          });
        },
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.blue,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmarks),
            label: 'Kategori',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Transaksi',
          ),
        ],
      ),
    );
  }
}

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:latihan5/app_config.dart';
import 'package:latihan5/produk.dart';

class TokoScreen extends StatefulWidget {
  const TokoScreen({super.key});

  @override
  State<TokoScreen> createState() => _TokoScreenState();
}

class _TokoScreenState extends State<TokoScreen> {
  int _indexMenu = 0;
  List<Produk> _dataProduk = [];
  List<Keranjang> _dataKeranjang = [];

  @override
  void initState() {
    _getDataProduk();
    super.initState();
  }

  void _getDataProduk() async {
    try {
      final data = await AppConfig().database.listDocuments(
            databaseId: AppConfig().databaseID,
            collectionId: 'produk',
          );

      List<Produk> dataProduk = [];
      for (var element in data.documents) {
        dataProduk.add(Produk(
          id: element.$id,
          nama: element.data['nama'],
          kategoriId: element.data['kategori_id'],
          harga: double.parse(element.data['harga'].toString()),
          stok: int.parse(element.data['stok'].toString()),
          deskripsi: element.data['deskripsi'] ?? '',
          fotoId: element.data['foto_id'],
          fotoUrl: element.data['foto_url'],
        ));
      }
      setState(() {
        _dataProduk = dataProduk;
      });
    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error Get Data Produk : $e')),
      );
    }
  }

  Widget daftarProduk() {
    return Text('Daftar Produk');
  }

  Widget daftarKeranjang() {
    return Text('Daftar Keranjang');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Toko Online'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            label: Text('Login'),
            icon: Icon(
              Icons.login,
              color: Colors.white,
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: _indexMenu == 0 ? daftarProduk() : daftarKeranjang(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexMenu,
        onTap: (value) {
          setState(() {
            _indexMenu = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Keranjang Belanja (${_dataKeranjang.length})',
          ),
        ],
      ),
    );
  }
}

class Keranjang {
  final Produk produk;
  int jumlah = 1;

  Keranjang({
    required this.produk,
  });

  void tambahQty() => jumlah++;
  void kurangQty() => jumlah > 1 ? jumlah-- : jumlah = 1;
  get subTotal => produk.harga * jumlah;
}

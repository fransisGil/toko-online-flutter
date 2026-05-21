import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:latihan5/app_config.dart';
import 'package:latihan5/kategori.dart';
import 'package:latihan5/produk.dart';

class TokoScreen extends StatefulWidget {
  const TokoScreen({super.key});

  @override
  State<TokoScreen> createState() => _TokoScreenState();
}

class _TokoScreenState extends State<TokoScreen> {
  int _indexMenu = 0;
  List<Produk> _dataProduk = [];
  List<Kategori> _dataKategori = [];
  List<Keranjang> _dataKeranjang = [];

  @override
  void initState() {
    _getDataKategori();
    _getDataProduk();
    super.initState();
  }

  void _getDataProduk() async {
    try {
      final data = await AppConfig().database.listDocuments(
            databaseId: AppConfig().databaseID,
            collectionId: 'Product',
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

  void _getDataKategori() async {
    try {
      final data = await AppConfig().database.listDocuments(
            databaseId: AppConfig().databaseID,
            collectionId: 'category',
          );

      List<Kategori> dataKategori = [];
      for (var element in data.documents) {
        dataKategori.add(Kategori(
          id: element.$id,
          nama: element.data['nama'],
        ));
      }
      dataKategori.add(Kategori(id: '', nama: "Semua kategori"));
      setState(() {
        _dataKategori = dataKategori;
      });
    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Get Data Kategori : $e')));
    }
  }

  Widget daftarProduk() {
    return Column(
      spacing: 12,
      children: [
        DropdownMenu(
          width: MediaQuery.sizeOf(context).width,
            dropdownMenuEntries: _dataKategori
                .map(
                  (e) => DropdownMenuEntry(value: e.id, label: e.nama.replaceRange(0, 1, e.nama[0].toUpperCase())),
                )
                .toList()),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
            ),
            itemCount: _dataProduk.length,
            itemBuilder: (context, index) {
              var produk = _dataProduk[index];
          
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridTile(
                    header: Image.network(produk.fotoUrl),
                    footer: Column(
                      children: [
                        Text(produk.nama),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Harga'),
                            Text('Stok'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(produk.harga.toString()),
                            Text(produk.stok.toString()),
                          ],
                        ),
                        ElevatedButton(onPressed: (){
                          setState(() {
                            if (_dataKeranjang.any((element) => element.produk.id == produk.id,)) {
                              int index = _dataKeranjang.indexWhere((element) => element.produk.id == produk.id,);
                              _dataKeranjang[index].tambahQty();
                            } else {
                              _dataKeranjang.add(Keranjang(produk: produk));
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Produk ditambah'))
                          );
                        }, child: Icon(Icons.add_shopping_cart))
                      ],
                    ),
                    child: Text(''),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
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

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
    _getDataProduk();
    _getDataKategori();
    super.initState();
  }

  void _getDataKategori() async {
    try {
      final data = await AppConfig().database.listDocuments(
            databaseId: AppConfig().databaseID,
            collectionId: 'kategori',
          );

      List<Kategori> dataKategori = [];
      for (var element in data.documents) {
        dataKategori.add(Kategori(
          id: element.$id,
          nama: element.data['nama'],
        ));
      }
      dataKategori.add(Kategori(id: '', nama: 'Semua Kategori'));
      setState(() {
        _dataKategori = dataKategori;
      });
    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Get Data Kategori : $e')));
    }
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
    return Column(
      spacing: 12,
      children: [
        DropdownMenu(
          label: Text('Filter Kategori'),
          width: double.infinity,
          dropdownMenuEntries: _dataKategori
              .map(
                (e) => DropdownMenuEntry(value: e.id, label: e.nama),
              )
              .toList(),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.55,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(produk.nama),
                        Text(produk.harga.toString()),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (_dataKeranjang.any(
                                (element) => element.produk.id == produk.id,
                              )) {
                                int index = _dataKeranjang.indexWhere(
                                  (element) => element.produk.id == produk.id,
                                );
                                _dataKeranjang[index].tambahQty();
                              } else {
                                _dataKeranjang.add(Keranjang(produk: produk));
                              }
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Produk ditambahkan')),
                            );
                          },
                          child: Text('Add to Cart'),
                        ),
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
    return Column(
      spacing: 12,
      children: [
        Text(
          'Keranjang Belanja',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              //koding hapus semua produk
              setState(() {});
              _dataKeranjang.clear();
              _indexMenu = 0;
            },
            child: Text('Hapus Semua'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _dataKeranjang.length,
            itemBuilder: (context, index) {
              var itemCart = _dataKeranjang[index];

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                color: Colors.white,
                child: ListTile(
                  leading: Image.network(itemCart.produk.fotoUrl),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      Text(itemCart.produk.nama),
                      Text('${itemCart.jumlah} x ${itemCart.produk.harga}'),
                      Text(itemCart.subTotal.toString()),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          //koding kurang qty produk
                          setState(() {
                            _dataKeranjang[index].kurangQty();
                          });
                        },
                        icon: Icon(Icons.remove_circle_outline),
                      ),
                      IconButton(
                        onPressed: () {
                          //koding tambah qty produk
                          setState(() {
                            _dataKeranjang[index].tambahQty();
                          });
                        },
                        icon: Icon(Icons.add_circle_outline),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          //koding hapus produk
                          _dataKeranjang.removeAt(index);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Produk berhasil dihapus.')));
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: Text('Hapus Produk'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text('Total Keranjang'),
                Text(
                  getTotalKeranjang(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                //koding check out
              },
              label: Text('Check Out'),
              icon: Icon(
                Icons.arrow_forward,
              ),
            )
          ],
        ),
      ],
    );
  }

  String getTotalKeranjang() {
    //koding get total keranjang
    double sum = 0;
    for (Keranjang keranjang in _dataKeranjang) {
      sum += keranjang.subTotal;
    }
    return '$sum';
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
  double get subTotal => produk.harga * jumlah;
}

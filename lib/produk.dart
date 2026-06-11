import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:latihan5/app_config.dart';
import 'package:latihan5/kategori.dart';
import 'package:image_picker/image_picker.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  List<Kategori> _dataKategori = [];
  List<Produk> _dataProduk = [];

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
      setState(() {
        _dataKategori = dataKategori;
      });
    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error Get Data Kategori : $e')),
      );
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

  @override
  void initState() {
    _getDataKategori();
    _getDataProduk();
    super.initState();
  }

  void _tampilFormProduk(String tipeAksi, {Produk? produk}) {
    final nama = TextEditingController();
    final harga = TextEditingController();
    final stok = TextEditingController();
    final deskripsi = TextEditingController();
    final formKey = GlobalKey<FormState>();
    XFile? fotoProduk;
    var kategori = _dataKategori.first.id;
    var judulForm = '';
    var namaTombol = '';
    var kunciIsian = false;

    if (tipeAksi == 'tambah') {
      judulForm = 'Form Tambah Produk';
      namaTombol = 'Simpan';
      kunciIsian = false;
    } else if (tipeAksi == 'edit') {
      judulForm = 'Form Edit Produk';
      namaTombol = 'Update';
      nama.text = produk!.nama;
      kategori = produk.kategoriId;
      harga.text = produk.harga.toString();
      stok.text = produk.stok.toString();
      deskripsi.text = produk.deskripsi;
      kunciIsian = false;
    } else if (tipeAksi == 'hapus') {
      judulForm = 'Form Hapus Produk';
      namaTombol = 'Hapus';
      nama.text = produk!.nama;
      kategori = produk.kategoriId;
      harga.text = produk.harga.toString();
      stok.text = produk.stok.toString();
      deskripsi.text = produk.deskripsi;
      kunciIsian = true;
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
                    children: [
                      Text(
                        judulForm,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextFormField(
                        controller: nama,
                        readOnly: kunciIsian,
                        decoration: InputDecoration(
                          labelText: 'Nama Produk',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Nama Produk wajib diisi.";
                          }
                          return null;
                        },
                      ),
                      DropdownMenu(
                        enabled: !kunciIsian,
                        label: Text('Kategori'),
                        initialSelection: kategori,
                        width: double.infinity,
                        onSelected: (value) {
                          setState(() {
                            kategori = value!;
                          });
                        },
                        dropdownMenuEntries: _dataKategori
                            .map(
                              (e) =>
                                  DropdownMenuEntry(value: e.id, label: e.nama),
                            )
                            .toList(),
                      ),
                      TextFormField(
                        controller: harga,
                        readOnly: kunciIsian,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Harga',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Harga wajib diisi.";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: stok,
                        readOnly: kunciIsian,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Stok',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Stok wajib diisi.";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: deskripsi,
                        readOnly: kunciIsian,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi',
                        ),
                        minLines: 3,
                        maxLines: 5,
                      ),
                      (tipeAksi == 'edit' || tipeAksi == 'hapus')
                          ? Column(
                              spacing: 12,
                              children: [
                                Text('Foto Terupload'),
                                Image.network(produk!.fotoUrl),
                                fotoProduk != null
                                    ? Column(
                                        spacing: 12,
                                        children: [
                                          Text('Foto Baru'),
                                          Image.file(File(fotoProduk!.path)),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                fotoProduk = null;
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: Text('Hapus Foto'),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        spacing: 8,
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: kunciIsian
                                                  ? null
                                                  : () async {
                                                      final foto =
                                                          await ImagePicker()
                                                              .pickImage(
                                                        source:
                                                            ImageSource.camera,
                                                        imageQuality: 100,
                                                        maxHeight: 300,
                                                        maxWidth: 300,
                                                      );

                                                      setState(() {
                                                        fotoProduk = foto;
                                                      });
                                                    },
                                              label: Text('Foto Kamera'),
                                              icon: Icon(
                                                Icons.camera_alt,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: kunciIsian
                                                  ? null
                                                  : () async {
                                                      final foto =
                                                          await ImagePicker()
                                                              .pickImage(
                                                        source:
                                                            ImageSource.gallery,
                                                        imageQuality: 100,
                                                        maxHeight: 300,
                                                        maxWidth: 300,
                                                      );

                                                      setState(() {
                                                        fotoProduk = foto;
                                                      });
                                                    },
                                              label: Text('Foto Galeri'),
                                              icon: Icon(
                                                Icons.photo_album,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            )
                          : fotoProduk != null
                              ? Column(
                                  spacing: 12,
                                  children: [
                                    Image.file(File(fotoProduk!.path)),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          fotoProduk = null;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: Text('Hapus Foto'),
                                    ),
                                  ],
                                )
                              : Row(
                                  spacing: 8,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: kunciIsian
                                            ? null
                                            : () async {
                                                final foto = await ImagePicker()
                                                    .pickImage(
                                                  source: ImageSource.camera,
                                                  imageQuality: 100,
                                                  maxHeight: 300,
                                                  maxWidth: 300,
                                                );

                                                setState(() {
                                                  fotoProduk = foto;
                                                });
                                              },
                                        label: Text('Foto Kamera'),
                                        icon: Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: kunciIsian
                                            ? null
                                            : () async {
                                                final foto = await ImagePicker()
                                                    .pickImage(
                                                  source: ImageSource.gallery,
                                                  imageQuality: 100,
                                                  maxHeight: 300,
                                                  maxWidth: 300,
                                                );

                                                setState(() {
                                                  fotoProduk = foto;
                                                });
                                              },
                                        label: Text('Foto Galeri'),
                                        icon: Icon(
                                          Icons.photo_album,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                      Row(
                        spacing: 8,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  if (tipeAksi == 'tambah') {
                                    final fotoID = ID.unique();
                                    await AppConfig().storage.createFile(
                                          bucketId: AppConfig().storageID,
                                          fileId: fotoID,
                                          file: InputFile.fromPath(
                                              path: fotoProduk!.path),
                                        );
                                    await AppConfig().database.createDocument(
                                      databaseId: AppConfig().databaseID,
                                      collectionId: 'produk',
                                      documentId: ID.unique(),
                                      data: {
                                        'nama': nama.text,
                                        'kategori_id': kategori,
                                        'harga': double.parse(harga.text),
                                        'stok': int.parse(stok.text),
                                        'deskripsi': deskripsi.text,
                                        'foto_id': fotoID,
                                        'foto_url':
                                            '${AppConfig().endpoint}/storage/buckets/${AppConfig().storageID}/files/$fotoID/view?project=${AppConfig().projectID}',
                                      },
                                    ).whenComplete(
                                      () {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Produk berhasil disimpan')),
                                          );
                                          _getDataProduk();
                                          Navigator.pop(context);
                                        }
                                      },
                                    );
                                  } else if (tipeAksi == 'edit') {
                                    if (fotoProduk != null) {
                                      print(fotoProduk!.path);
                                      await AppConfig().storage.deleteFile(
                                        bucketId: AppConfig().storageID, 
                                        fileId: produk!.fotoId,
                                      );
                                      final fotoID = ID.unique();
                                      await AppConfig().storage.createFile(
                                        bucketId: AppConfig().storageID, 
                                        fileId: fotoID, 
                                        file: InputFile.fromPath(path: fotoProduk!.path),
                                      );
                                      await AppConfig().database.updateDocument(
                                        databaseId: AppConfig().databaseID,
                                        collectionId: 'produk',
                                        documentId: produk.id,
                                        data: {
                                          'foto_id': fotoID,
                                          'foto_url': '${AppConfig().endpoint}/storage/buckets/${AppConfig().storageID}/files/$fotoID/view?project=${AppConfig().projectID}',
                                        },
                                      );
                                    }
                                    await AppConfig().database.updateDocument(
                                      databaseId: AppConfig().databaseID,
                                      collectionId: 'produk',
                                      documentId: produk!.id,
                                      data: {
                                        'nama': nama.text,
                                        'kategori_id': kategori,
                                        'harga': double.parse(harga.text),
                                        'stok': int.parse(stok.text),
                                        'deskripsi': deskripsi.text,
                                      },
                                    ).whenComplete(
                                      () {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Produk berhasil diedit'),
                                            ),
                                          );
                                          _getDataProduk();
                                          Navigator.pop(context);
                                        }
                                      },
                                    );
                                  } else if (tipeAksi == 'hapus') {
                                    await AppConfig().storage.deleteFile(
                                      bucketId: AppConfig().storageID, 
                                      fileId: produk!.fotoId,
                                    );
                                    await AppConfig()
                                        .database
                                        .deleteDocument(
                                          databaseId: AppConfig().databaseID,
                                          collectionId: 'produk',
                                          documentId: produk.id,
                                        )
                                        .whenComplete(
                                      () {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Produk berhasil dihapus'),
                                            ),
                                          );
                                          _getDataProduk();
                                          Navigator.pop(context);
                                        }
                                      },
                                    );
                                  }
                                } on AppwriteException catch (e) {
                                  print(e);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error CRUD Produk : $e'),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: tipeAksi == 'tambah'
                                    ? Colors.blue
                                    : tipeAksi == 'edit'
                                        ? Colors.green
                                        : Colors.red,
                              ),
                              child: Text(namaTombol),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Batal'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        spacing: 12,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _tampilFormProduk('tambah'),
              child: Text('Tambah Produk Baru'),
            ),
          ),
          _dataProduk.isEmpty
              ? Center(
                  child: Text('Data masih kosong.'),
                )
              : Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.5,
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Harga'),
                                    Text('Stok'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(produk.harga.toString()),
                                    Text(produk.stok.toString()),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: () => _tampilFormProduk('edit',
                                          produk: produk),
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.green,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _tampilFormProduk(
                                          'hapus',
                                          produk: produk),
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
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
      ),
    );
  }
}

class Produk {
  final String id;
  final String nama;
  final String kategoriId;
  final double harga;
  final int stok;
  final String deskripsi;
  final String fotoId;
  final String fotoUrl;

  Produk({
    required this.id,
    required this.nama,
    required this.kategoriId,
    required this.harga,
    required this.stok,
    required this.deskripsi,
    required this.fotoId,
    required this.fotoUrl,
  });
}

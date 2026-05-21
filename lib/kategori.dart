import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:latihan5/app_config.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  List<Kategori> _dataKategori = [];

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
      setState(() {
        _dataKategori = dataKategori;
      });
    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Get Data Kategori : $e')));
    }
  }

  @override
  void initState() {
    _getDataKategori();
    super.initState();
  }

  void _tampilFormKategori(String tipeAksi, {Kategori? kategori}) {
    final nama = TextEditingController();
    final formKey = GlobalKey<FormState>();

    var judulForm = '';
    var namaTombol = '';

    if (tipeAksi == 'tambah') {
      judulForm = 'Form Tambah Kategori';
      namaTombol = 'Simpan';
    } else if (tipeAksi == 'edit') {
      judulForm = 'Form Edit Kategori';
      namaTombol = 'Update';
      nama.text = kategori!.nama;
    } else if (tipeAksi == 'hapus') {
      judulForm = 'Form Hapus Kategori';
      namaTombol = 'Hapus';
      nama.text = kategori!.nama;
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                    decoration: InputDecoration(
                      labelText: 'Nama Kategori',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Nama Kategori wajib diisi.";
                      }
                      return null;
                    },
                  ),
                  Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              if (tipeAksi == 'tambah') {
                                await AppConfig().database.createDocument(
                                  databaseId: AppConfig().databaseID,
                                  collectionId: 'kategori',
                                  documentId: ID.unique(),
                                  data: {
                                    'nama': nama.text,
                                  },
                                ).whenComplete(
                                  () {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Kategori berhasil disimpan'),
                                        ),
                                      );
                                      _getDataKategori();
                                      Navigator.pop(context);
                                    }
                                  },
                                );
                              } else if (tipeAksi == 'edit') {
                                await AppConfig().database.updateDocument(
                                  databaseId: AppConfig().databaseID,
                                  collectionId: 'kategori',
                                  documentId: kategori!.id,
                                  data: {
                                    'nama': nama.text,
                                  },
                                ).whenComplete(
                                  () {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Kategori berhasil diedit'),
                                        ),
                                      );
                                      _getDataKategori();
                                      Navigator.pop(context);
                                    }
                                  },
                                );
                              } else if (tipeAksi == 'hapus') {
                                await AppConfig()
                                    .database
                                    .deleteDocument(
                                      databaseId: AppConfig().databaseID,
                                      collectionId: 'kategori',
                                      documentId: kategori!.id,
                                    )
                                    .whenComplete(
                                  () {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Kategori berhasil dihapus'),
                                        ),
                                      );
                                      _getDataKategori();
                                      Navigator.pop(context);
                                    }
                                  },
                                );
                              }
                            } on AppwriteException catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error CRUD Kategori : $e'),
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
              onPressed: () => _tampilFormKategori('tambah'),
              child: Text('Tambah Kategori Baru'),
            ),
          ),
          _dataKategori.isEmpty
              ? Center(
                  child: Text('Data masih kosong.'),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: _dataKategori.length,
                    itemBuilder: (context, index) {
                      var kategori = _dataKategori[index];

                      return Card(
                        child: ListTile(
                          title: Text(kategori.nama),
                          trailing: Wrap(
                            children: [
                              IconButton(
                                onPressed: () => _tampilFormKategori('edit',
                                    kategori: kategori),
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.green,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _tampilFormKategori('hapus',
                                    kategori: kategori),
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
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

class Kategori {
  final String id;
  final String nama;

  Kategori({
    required this.id,
    required this.nama,
  });
}

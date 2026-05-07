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
          databaseId: AppConfig().databaseID, collectionId: "category");
      // forEach((element) => Kategori(id: element.$id, nama: element.data['nama']))
      // List<Kategori> dataCategory = data.documents.cast<Kategori>();
      List<Kategori> dataCategory = [];
      for (var element in data.documents) {
        dataCategory.add(Kategori(id: element.$id, nama: element.data['nama']));
      }
      setState(() {
        _dataKategori = dataCategory;
      });
    } on AppwriteException catch (e) {
      // ignore: use_build_context_synchronously
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
    bool isLoading = false;

    if (tipeAksi == 'tambah') {
      judulForm = 'Form Tambah Kategori';
      namaTombol = 'Simpan';
    } else if (tipeAksi == 'edit') {
      judulForm = 'Form Edit Kategori';
      namaTombol = 'Update';
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
            padding: EdgeInsets.all(12),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: [
                  Text(
                    judulForm,
                    style: TextStyle(
                      fontSize: 16,
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
                    spacing: 5,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              setState(() {
                                isLoading = true;
                              });
                              if (tipeAksi == 'tambah') {
                                await createCategory(nama, context);
                              } else if (tipeAksi == 'edit') {
                                await editCategory(kategori, nama, context);
                              } else if (tipeAksi == 'hapus') {
                                await deleteCategory(context);
                              }
                              setState(() {
                                isLoading = false;
                              });
                              _getDataKategori();
                              Navigator.pop(context);
                            } on AppwriteException catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Error encountered: $e')));
                            }
                          },
                          child: isLoading
                              ? CircularProgressIndicator()
                              : Text(namaTombol),
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

  Future<void> deleteCategory(BuildContext context) async {
    await AppConfig().database.deleteDocument(
        databaseId: AppConfig().databaseID,
        collectionId: 'kategori',
        documentId: ID.unique(),
      ).whenComplete(
      () {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Data berhasil disimpan')));
      },
    );
  }

  Future<void> editCategory(Kategori? kategori, TextEditingController nama, BuildContext context) async {
    await AppConfig().database.updateDocument(
        databaseId: AppConfig().databaseID,
        collectionId: 'kategori',
        documentId: kategori!.id,
        data: {'nama': nama.text}).whenComplete(
      () =>
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Data berhasil diubah')))
    );
  }

  Future<void> createCategory(TextEditingController nama, BuildContext context) async {
    await AppConfig().database.createDocument(
        databaseId: AppConfig().databaseID,
        collectionId: 'kategori',
        documentId: ID.unique(),
        data: {'nama': nama.text}).whenComplete(
      () {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Data berhasil disimpan')));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
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
                                onPressed: () => _tampilFormKategori('tipeAksi', kategori: kategori),
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

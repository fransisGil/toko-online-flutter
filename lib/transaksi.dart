import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:latihan5/app_config.dart';
import 'package:intl/intl.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  List _dataTransaksi = [];
  final formatRp = NumberFormat.simpleCurrency(
    decimalDigits: 2,
    locale: 'id_ID'
  );
  final formatTgl = DateFormat.yMMMMd();

  void _getDataTransaksi() async {
    try {
      final data = await AppConfig().database.listDocuments(
        databaseId: AppConfig().databaseID,
        collectionId: 'transaksi',
        queries: [
          Query.orderDesc('\$createdAt')
        ]
      );

      List dataTransaksi = [];
      for (var element in data.documents) {
        List dataProduk = jsonDecode(element.data['item_transaksi']);
        for (var item in dataProduk) {
          item['produk'] = await getNamaProduk(item['produk']);
        }
        element.data['item_transaksi'] = jsonEncode(dataProduk);
        dataTransaksi.add(element);
      }
      setState(() {
        _dataTransaksi = dataTransaksi;
      });
    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Get Data Transaksi : $e')));
    }
  }

  Future<String> getNamaProduk(String kodeProduk) async {
    final data = await AppConfig().database.getDocument(
        databaseId: AppConfig().databaseID,
        collectionId: 'produk',
        documentId: kodeProduk,
      );

    return data.data['nama'];
  }

  @override
  void initState() {
    _getDataTransaksi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        spacing: 12,
        children: [
          _dataTransaksi.isEmpty
              ? Center(
                  child: Text('Data masih kosong.'),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: _dataTransaksi.length,
                    itemBuilder: (context, index) {
                      Document transaksi = _dataTransaksi[index];
                      List itemProduk = jsonDecode(transaksi.data['item_transaksi']);

                      return Card(
                        child: ExpansionTile(
                          title: Text(transaksi.data['nomor_transaksi']),
                          subtitle: Row(
                            spacing: 12,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tanggal'),
                                  Text('Nama'),
                                  Text('Ekspedisi'),
                                  Text('Ongkir'),
                                  Text('Total'),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(formatTgl.format(DateTime.parse(transaksi.$createdAt))),
                                  Text(transaksi.data['nama']),
                                  Text(transaksi.data['ekspedisi']),
                                  Text(formatRp.format(transaksi.data['ongkir'])),
                                  Text(formatRp.format(transaksi.data['total'])),
                                ],
                              ),
                            ],
                          ),
                          children: [
                            Column(
                              children: itemProduk.map((e) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    bottom: 16,
                                  ),
                                  child: Row(
                                    spacing: 12,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Produk'),
                                          Text('Jumlah'),
                                          Text('Sub Total'),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(e['produk']),
                                          Text(e['jumlah'].toString()),
                                          Text(formatRp.format(e['subtotal'])),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },).toList(),
                            ),
                          ],
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

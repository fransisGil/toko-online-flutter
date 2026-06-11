import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:latihan5/app_config.dart';
import 'package:latihan5/toko.dart';
import 'package:latihan5/webview.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  List _dataProvinsi = [];
  List _dataKota = [];
  List _dataKecamatan = [];
  List _dataPengiriman = [];

  final _totalAkhir = TextEditingController();
  final _nama = TextEditingController();
  final _nohp = TextEditingController();
  final _alamat = TextEditingController();

  final _asal = 513;
  int _tujuan = 0;
  double _ongkir = 0;
  String _ekspedisi = '';
  List<Keranjang> _dataKeranjang = [];

  final _formKey = GlobalKey<FormState>();

  Future<List> _fetchAPIOngkir(String endpoint,
      {String method = 'GET', Map? data}) async {
    var response;

    if (method == 'GET') {
      response = await Dio().get(
          'https://rajaongkir.komerce.id/api/v1/$endpoint',
          options:
              Options(headers: {'key': 'd43e75c39462237f191667a5aad980aa'}));
    } else {
      response =
          await Dio().post('https://rajaongkir.komerce.id/api/v1/$endpoint',
              options: Options(
                headers: {'key': 'd43e75c39462237f191667a5aad980aa'},
                contentType: Headers.formUrlEncodedContentType,
              ),
              data: data);
    }
    final result = response.data as Map;
    return result['data'] as List;
  }

  void _getProvince() async {
    final data = await _fetchAPIOngkir('destination/province');
    List dataProvinsi = [];
    for (var element in data) {
      dataProvinsi.add(element);
    }
    setState(() {
      _dataProvinsi = dataProvinsi;
    });
  }

  void _getCity(int provinceId) async {
    final data = await _fetchAPIOngkir('destination/city/$provinceId');
    List dataKota = [];
    for (var element in data) {
      dataKota.add(element);
    }
    setState(() {
      _dataKota = dataKota;
    });
  }

  void _getDistrict(int cityId) async {
    final data = await _fetchAPIOngkir('destination/district/$cityId');
    List dataKecamatan = [];
    for (var element in data) {
      dataKecamatan.add(element);
    }
    setState(() {
      _dataKecamatan = dataKecamatan;
    });
  }

  void _getShippingCost() async {
    final formData = {
      'origin': '$_asal',
      'destination': '$_tujuan',
      'weight': '1000',
      'courier': _ekspedisi,
      'price': 'lowest',
    };
    final data = await _fetchAPIOngkir('calculate/district/domestic-cost',
        method: 'POST', data: formData);
    List dataPengiriman = [];
    for (var element in data) {
      dataPengiriman.add(element);
    }
    setState(() {
      _dataPengiriman = dataPengiriman;
    });
  }

  Future<void> payWithMidtrans() async {
    if (_nama.text.isNotEmpty && _alamat.text.isNotEmpty && _nohp.text.isNotEmpty && _totalAkhir.text.isNotEmpty) {
      try {
        final nomorTransaksi = 'ORDER-${DateTime.now().millisecondsSinceEpoch}';
        final grossAmount = double.parse(_totalAkhir.text);

        final execution = await AppConfig().function.createExecution(
          functionId: AppConfig().functionID,
          body: jsonEncode({
            'orderId': nomorTransaksi,
            'grossAmount': grossAmount,
          }),
          path: '/generate-token',
          method: ExecutionMethod.pOST,
        );

        final response = jsonDecode(execution.responseBody);

        if (response['success'] == true) {
          final String redirectUrl = response['redirect_url'];
          final bool? paymentFinished = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => WebViewScreen(
                  snapUrl: redirectUrl,
                  callbackUrl: 'https://example.com/payment-success',
                ),
              ));
          if (paymentFinished == true) {
            List itemPembelian = [];
            for (var element in _dataKeranjang) {
              itemPembelian.add({
                'produk': element.produk.id,
                'jumlah': element.jumlah,
                'subtotal': element.subTotal,
              });
            }
            await AppConfig().database.createDocument(
              databaseId: AppConfig().databaseID, 
              collectionId: 'transaksi', 
              documentId: ID.unique(), 
              data: {
                'nomor_transaksi': nomorTransaksi,
                'nama': _nama.text,
                'nomor_telepon': _nohp.text,
                'alamat': _alamat.text,
                'total': grossAmount - _ongkir,
                'ongkir': _ongkir,
                'ekspedisi': _ekspedisi,
                'item_transaksi': jsonEncode(itemPembelian),
              }
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Pembayaran berhasil')),
            );
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false,);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Pembayaran dibatalkan atau belum selesai')),
            );
          }
        }
      } catch (e) {
        print('Gagal memproses pembayaran: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Isian Belum Lengkap')),
      );
    }
  }

  @override
  void initState() {
    _getProvince();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as Map;
    final dataKeranjang = data['dataKeranjang'] as List<Keranjang>;
    final totalKeranjang =
        dataKeranjang.fold(0.0, (pV, el) => pV + el.subTotal);

    setState(() {
      _dataKeranjang = dataKeranjang;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Check Out'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Text('Daftar Produk'),
                DataTable(
                  columns: [
                    DataColumn(label: Text('Produk')),
                    DataColumn(label: Text('Qty'), numeric: true),
                    DataColumn(label: Text('Sub Total'), numeric: true),
                  ],
                  rows: (dataKeranjang.map(
                        (e) {
                          return DataRow(cells: [
                            DataCell(Text(e.produk.nama)),
                            DataCell(Text(e.jumlah.toString())),
                            DataCell(Text(e.subTotal.toString())),
                          ]);
                        },
                      ).toList()) +
                      [
                        DataRow(
                          cells: [
                            DataCell(Text('')),
                            DataCell(Text('Total')),
                            DataCell(Text(totalKeranjang.toString())),
                          ],
                        ),
                      ],
                ),
                Text('Informasi Pengiriman'),
                TextFormField(
                  controller: _nama,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                  ),
                ),
                TextFormField(
                  controller: _nohp,
                  decoration: InputDecoration(
                    labelText: 'Nomor Handphone',
                  ),
                ),
                TextFormField(
                  controller: _alamat,
                  decoration: InputDecoration(
                    labelText: 'Alamat Lengkap',
                  ),
                  minLines: 3,
                  maxLines: 5,
                ),
                DropdownMenu(
                  label: Text('Pilih Provinsi'),
                  width: double.infinity,
                  dropdownMenuEntries: _dataProvinsi
                      .map(
                        (e) =>
                            DropdownMenuEntry(value: e['id'], label: e['name']),
                      )
                      .toList(),
                  onSelected: (value) {
                    _getCity(value!);
                  },
                ),
                DropdownMenu(
                  label: Text('Pilih Kota'),
                  width: double.infinity,
                  dropdownMenuEntries: _dataKota
                      .map(
                        (e) =>
                            DropdownMenuEntry(value: e['id'], label: e['name']),
                      )
                      .toList(),
                  onSelected: (value) {
                    _getDistrict(value!);
                  },
                ),
                DropdownMenu(
                  label: Text('Pilih Kecamatan'),
                  width: double.infinity,
                  dropdownMenuEntries: _dataKecamatan
                      .map(
                        (e) =>
                            DropdownMenuEntry(value: e['id'], label: e['name']),
                      )
                      .toList(),
                  onSelected: (value) {
                    setState(() {
                      _tujuan = value!;
                    });
                  },
                ),
                DropdownMenu(
                  label: Text('Pilih Ekspedisi'),
                  width: double.infinity,
                  dropdownMenuEntries: [
                    DropdownMenuEntry(value: 'jne', label: 'JNE'),
                    DropdownMenuEntry(value: 'jnt', label: 'JNT'),
                    DropdownMenuEntry(value: 'sicepat', label: 'Sicepat'),
                    DropdownMenuEntry(value: 'tiki', label: 'TIKI'),
                    DropdownMenuEntry(value: 'pos', label: 'POS Indonesia'),
                  ],
                  onSelected: (value) {
                    setState(() {
                      _ekspedisi = value!;
                    });
                    _getShippingCost();
                  },
                ),
                DropdownMenu(
                  label: Text('Pilih Jenis Pengiriman'),
                  width: double.infinity,
                  dropdownMenuEntries: _dataPengiriman.map((e) {
                    return DropdownMenuEntry(
                        value: e['cost'],
                        label:
                            '${e['description']} (${e['service']}) - ETD: ${e['etd']} - ${e['cost']}');
                  }).toList(),
                  onSelected: (value) {
                    setState(() {
                      _totalAkhir.text =
                          (totalKeranjang + double.parse(value.toString()))
                              .toString();
                      _ongkir = double.parse(value.toString());
                    });
                  },
                ),
                TextFormField(
                  controller: _totalAkhir,
                  decoration: InputDecoration(
                    labelText: 'Total Pembayaran',
                  ),
                  readOnly: true,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: payWithMidtrans,
                    child: Text('Proses Pembayaran'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

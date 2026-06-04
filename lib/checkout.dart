import 'dart:convert';

import 'package:appwrite/enums.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:latihan5/app_config.dart';
import 'package:latihan5/toko.dart';
import 'package:url_launcher/url_launcher.dart';

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

  final _asal = 513;
  int _tujuan = 0;

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

  void _getShippingCost(String ekspedisi) async {
    final formData = {
      'origin': '$_asal',
      'destination': '$_tujuan',
      'weight': '1000',
      'courier': ekspedisi,
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

  Future<void> payWithMidtrans(double grossAmount) async {
    try {
      // 1. Panggil Appwrite Function untuk membuat token
      final execution = await AppConfig().function.createExecution(
        functionId: AppConfig().functionID,
        body: jsonEncode({
          'orderId': 'ORDER-${DateTime.now().millisecondsSinceEpoch}',
          'grossAmount': grossAmount,
        }),
        path: '/generate-token',
        method: ExecutionMethod.pOST,
      );

      // 2. Parse response dan buka redirect URL
      final response = jsonDecode(execution.responseBody);
      
      if (response['success'] == true) {
        final String redirectUrl = response['redirect_url'];
        
        // Buka halaman pembayaran Midtrans di browser / webview
        if (!await launchUrl(Uri.parse(redirectUrl), mode: LaunchMode.inAppWebView)) {
          throw Exception('Tidak dapat membuka halaman pembayaran');
        }
      }
    } catch (e) {
      print('Gagal memproses pembayaran: $e');
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Check Out'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
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
              DropdownMenu(
                label: Text('Pilih Provinsi'),
                width: double.infinity,
                dropdownMenuEntries: _dataProvinsi
                    .map(
                      (e) => DropdownMenuEntry(value: e['id'], label: e['name']),
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
                      (e) => DropdownMenuEntry(value: e['id'], label: e['name']),
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
                      (e) => DropdownMenuEntry(value: e['id'], label: e['name']),
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
                  _getShippingCost(value!);
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
                  onPressed: () => payWithMidtrans(double.parse(_totalAkhir.text)),
                  child: Text('Proses Pembayaran'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

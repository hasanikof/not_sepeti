import 'package:flutter/material.dart';
import 'package:not_sepeti/models/kategori.dart';
import 'package:not_sepeti/models/notlar.dart';
import 'package:not_sepeti/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NotDetay extends StatefulWidget {
  String? baslik;
  Not? duzenlenecekNot;

  NotDetay({this.baslik, this.duzenlenecekNot});

  @override
  _NotDetayState createState() => _NotDetayState();
}

class _NotDetayState extends State<NotDetay> {
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  List<Kategori>? _tumKategoriler;
  DatabaseHelper? _databaseHelper;
  int? kategoriID;
  int? secilenOncelikID;
  String? notBaslik, notIcerik;
  static var _oncelik = ["Düşük", "Orta", "Yüksek"];

  @override
  void initState() {
    super.initState();

    _tumKategoriler = List<Kategori>.empty(growable: true);
    _databaseHelper = DatabaseHelper();

    _databaseHelper!.kategorileriGetir().then((kategorileriIcerenMapListesi) {
      for (Map<String, dynamic> okunanMap in kategorileriIcerenMapListesi) {
        _tumKategoriler!.add(Kategori.fromMap(okunanMap));
      }
      if (widget.duzenlenecekNot != null) {
        kategoriID = widget.duzenlenecekNot!.kategoriID;
        secilenOncelikID = widget.duzenlenecekNot!.notOncelik;
      } else {
        kategoriID = _tumKategoriler!.first.kategoriID;
        secilenOncelikID = 0;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: widget.baslik == null ? Text("Konu başlığı") : Text(widget.baslik.toString()),
      ),
      body: _tumKategoriler!.length <= 0
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text("Kategori : "),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              items: kategoriItemleriOlustur(),
                              value: kategoriID,
                              onChanged: (_secilenKategoriID) {
                                setState(() {
                                  kategoriID = _secilenKategoriID!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        initialValue: widget.duzenlenecekNot != null ? widget.duzenlenecekNot!.notBaslik : "",
                        validator: (text) {
                          if (text!.length < 3) {
                            return "en az 3 karekter olmalı !";
                          }
                        },
                        onSaved: (text) {
                          notBaslik = text;
                        },
                        decoration: InputDecoration(
                          hintText: "Not başlığı giriniz",
                          labelText: "Başlık",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        initialValue: widget.duzenlenecekNot != null ? widget.duzenlenecekNot!.notIcerik : "",
                        onSaved: (text) {
                          notIcerik = text;
                        },
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Not içeriğini giriniz",
                          labelText: "Not",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text("Öncelik : "),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              items: _oncelik.map((oncelik) {
                                return DropdownMenuItem<int>(
                                  
                                  child: Text(oncelik),
                                  
                                  value: _oncelik.indexOf(oncelik),
                                );
                              }).toList(),
                              value: secilenOncelikID,
                              onChanged: (_secilenOncelikID) {
                                setState(() {
                                  secilenOncelikID = _secilenOncelikID!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Vazgeç")),
                        TextButton(
                            onPressed: () {
                              if (_formkey.currentState!.validate()) {
                                _formkey.currentState!.save();

                                var suan = DateTime.now();

                                if (widget.duzenlenecekNot == null) {
                                  _databaseHelper!.notEkle(Not(kategoriID, notBaslik, notIcerik, suan.toString(), secilenOncelikID)).then((value) {
                                    if (value != 0) {
                                      Navigator.pop(context);
                                    }
                                  });
                                } else {
                                  _databaseHelper!
                                      .notGuncelle(Not.withID(
                                          widget.duzenlenecekNot!.notID, kategoriID, notBaslik, notIcerik, suan.toString(), secilenOncelikID))
                                      .then((value) {
                                    if (value != 0) {
                                      Navigator.pop(context);
                                    }
                                  });
                                }
                              }
                            },
                            child: Text("Kaydet")),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  List<DropdownMenuItem<int>> kategoriItemleriOlustur() {
    //  Altta yazdık gerek kalmadı
    // List<DropdownMenuItem<int>> _kategoriler = [];

    return _tumKategoriler!
        .map((kategori) => DropdownMenuItem<int>(
              value: kategori.kategoriID,
              child: Text(kategori.kategoriBaslik.toString()),
            ))
        .toList();
  }
}

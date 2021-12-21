import 'package:flutter/material.dart';
import 'package:not_sepeti/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import 'models/kategori.dart';

class Kategoriler extends StatefulWidget {
  const Kategoriler({Key? key}) : super(key: key);

  @override
  _KategorilerState createState() => _KategorilerState();
}

class _KategorilerState extends State<Kategoriler> {
  List<Kategori>? tumKategoriler;
  DatabaseHelper? databaseHelper;

  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    if (tumKategoriler == null) {
      tumKategoriler = List<Kategori>.empty(growable: true);
      kategoriListesiniGuncelle();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Kategoriler"),
      ),
      body: ListView.builder(
          itemCount: tumKategoriler!.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(tumKategoriler![index].kategoriBaslik.toString()),
              trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _kategoriSil(tumKategoriler![index].kategoriID);
                  }),
              leading: Icon(Icons.category),
            );
          }),
    );
  }

  void kategoriListesiniGuncelle() {
    databaseHelper!.kategoriListesiniGetir().then((kategorileriIcerenList) {
      setState(() {
        tumKategoriler = kategorileriIcerenList;
      });
    });
  }

  void _kategoriSil(int? kategoriID) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
              title: Text("Kategori Sil"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Kategoriyi sildiğinizde bununla ilgili tüm veriler silinecektir, eminmisiniz?"),
                  ButtonBar(
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Vazgeç")),
                      TextButton(
                          onPressed: () {
                            databaseHelper!.kategoriSil(kategoriID!.toInt()).then((silinenKategori) {
                              if (silinenKategori != 0) {
                                setState(() {
                                  //silinen değişiklik veritabanından
                                  //ekrana yansıması için bu yapılıyor
                                  kategoriListesiniGuncelle();
                                  Navigator.pop(context);
                                });
                              }
                            });
                          },
                          child: Text(
                            "Sil",
                            style: TextStyle(color: Colors.red),
                          )),
                    ],
                  ),
                ],
              ));
        });
  }
}

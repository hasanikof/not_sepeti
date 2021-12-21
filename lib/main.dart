import 'package:flutter/material.dart';
import 'package:not_sepeti/kategori_islemleri.dart';
import 'package:not_sepeti/utils/database_helper.dart';
import 'package:not_sepeti/utils/not_detay.dart';
import 'package:sqflite/sqflite.dart';

import 'models/kategori.dart';
import 'models/notlar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Demo",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NotListesi(),
    );
  }
}

class NotListesi extends StatefulWidget {
  @override
  State<NotListesi> createState() => _NotListesiState();
}

class _NotListesiState extends State<NotListesi> {
  
  
  DatabaseHelper databaseHelper = DatabaseHelper();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Not Sepeti"),
        centerTitle: true,
        actions: [
          PopupMenuButton(
              shape: Border.all(style: BorderStyle.solid, width: 1, color: Colors.grey),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: ListTile(
                        leading: Icon(Icons.category),
                        title: Text("Kategoriler"),
                        onTap: () {
                          _kategorilerSayfasinaGit(context);
                        }),
                  ),
                ];
              }),
        ],
      ),
      floatingActionButton: Column(
        
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            mini: true,
            tooltip: "Kategori Ekle",
            heroTag: "KategoriEkle",
            onPressed: () {
              kategoriEkleDialog(context);
            },
            child: Icon(Icons.eleven_mp),
          ),
          FloatingActionButton(
            tooltip: "Not Ekle",
            heroTag: "NotEkle",
            onPressed: () {
              _detaySayfasinaGit(context);
            },
            child: Icon(Icons.add),
          ),
          Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 50)),
        ],
      ),
      body: Notlar(),
    );
  }

  void kategoriEkleDialog(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    String? yeniKategoriAdi;

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Kategori ekle"),
            children: [
              Form(
                key: formKey,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: "Kategori adı",
                      border: OutlineInputBorder(),
                    ),
                    validator: (girilenKategoriAdi) {
                      if (girilenKategoriAdi!.length < 3) {
                        return "En az 3 karakter giriniz.";
                      }
                    },
                    onSaved: (yenideger) {
                      yeniKategoriAdi = yenideger;
                    },
                  ),
                ),
              ),
              ButtonBar(
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Vazgeç")),
                  TextButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          databaseHelper.kategoriEkle(Kategori(yeniKategoriAdi)).then((kategoriID) {
                            if (kategoriID > 0) {
                              _scaffoldKey.currentState!.showSnackBar(
                                  
                                SnackBar(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  
                                  elevation: 6.0,
                                  behavior: SnackBarBehavior.floating,
                                  content: Text("Kategori eklendi."),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          });
                        }
                      },
                      child: Text("Kaydet")),
                ],
              ),
            ],
          );
        });
  }

  void _detaySayfasinaGit(BuildContext myContext) {
    Navigator.push(myContext, MaterialPageRoute(builder: (context) => NotDetay(baslik: "Yeni Not"))).then((value) {
      setState(() {});
    });
  }

  void _kategorilerSayfasinaGit(BuildContext myContext) {
    Navigator.of(myContext).push(MaterialPageRoute(builder: (context) => Kategoriler())).then((value) {
      setState(() {});
    });
  }
}

class Notlar extends StatefulWidget {
  const Notlar({Key? key}) : super(key: key);

  @override
  NotlarState createState() => NotlarState();
}

class NotlarState extends State<Notlar> {
  List<Not>? tumNotlar;
  DatabaseHelper? databaseHelper;

  @override
  void initState() {
    super.initState();

    tumNotlar = List<Not>.empty(growable: true);
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: databaseHelper!.notListesiniGetir(),
      builder: (BuildContext context, AsyncSnapshot<List<Not>> snapShot) {
        if (snapShot.connectionState == ConnectionState.done) {
          tumNotlar = snapShot.data;
          return ListView.builder(
              itemCount: tumNotlar!.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  leading: _oncelikIconuAta(tumNotlar![index].notOncelik),
                  title: Text("${tumNotlar![index].notBaslik}"),
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Kategori : ", style: TextStyle(color: Colors.red)),
                              ),
                              Text("${tumNotlar![index].kategoriBaslik}"),
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Oluşturulma tarihi : ", style: TextStyle(color: Colors.red)),
                              ),
                              Text("${databaseHelper!.dateFormat(DateTime.parse(tumNotlar![index].notTarih.toString()))}"),
                            ],
                          ),
                          Padding(padding: EdgeInsets.all(8), child: Text("İçerik : \n" + tumNotlar![index].notIcerik.toString())),
                          ButtonBar(
                            alignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    _notSil(tumNotlar![index].notID!.toInt());
                                  },
                                  child: Text(
                                    "Sil",
                                    style: TextStyle(color: Colors.redAccent),
                                  )),
                              TextButton(
                                  onPressed: () {
                                    _detaySayfasinaGit(context, tumNotlar![index]);
                                  },
                                  child: Text(
                                    "Güncelle",
                                    style: TextStyle(color: Colors.blueAccent),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              });
        } else {
          return Center(child: Text("YÜKLENİYOR"));
        }
      },
    );
  }

  _detaySayfasinaGit(BuildContext myContext, Not not) {
    Navigator.push(
        myContext,
        MaterialPageRoute(
            builder: (context) => NotDetay(
                  baslik: "Notu düzenle",
                  duzenlenecekNot: not,
                ))).then((value) {
      setState(() {});
    });
  }

  _oncelikIconuAta(int? notOncelik) {
    switch (notOncelik) {
      case 0:
        return CircleAvatar(
            child: Text(
              "AZ",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent.shade100);
        break;
      case 1:
        return CircleAvatar(
            child: Text(
              "ORTA",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent.shade400);
        break;
      case 2:
        return CircleAvatar(
            child: Text(
              "ACİL",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent.shade700);
        break;
    }
  }

  _notSil(int notID) {
    databaseHelper!.notSil(notID).then((silinenID) {
      if (silinenID != 0) {
        
        Scaffold.of(context).showSnackBar(SnackBar(
          
          
          content: Text("Not başarıyla silindi !"),
          elevation: 8,
        ));
      }
    }).then((value) {
      setState(() {});
    });
  }
}

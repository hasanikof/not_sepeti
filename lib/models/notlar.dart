class Not {
  int? notID;
  int? kategoriID;
  String? kategoriBaslik;
  String? notBaslik;
  String? notIcerik;
  String? notTarih;
  int? notOncelik;

  //db ye eklerken kullanılıyor
  //id ye gerek yok db otomatik oluşturuyor
  Not(this.kategoriID, this.notBaslik, this.notIcerik, this.notTarih, this.notOncelik); //verileri yazarken lazım

  //db den veri okunurken kullanılıyor
  Not.withID(this.notID, this.kategoriID, this.notBaslik, this.notIcerik, this.notTarih, this.notOncelik); //verileri okurken lazım

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map["notID"] = notID;
    map["kategoriID"] = kategoriID;
    map["notBaslik"] = notBaslik;
    map["notIcerik"] = notIcerik;
    map["notTarih"] = notTarih;
    map["notOncelik"] = notOncelik;

    return map;
  }

  Not.fromMap(Map<String, dynamic> map) {
    notID = map["notID"];
    kategoriID = map["kategoriID"];
    kategoriBaslik = map["kategoriBaslik"];   
    notBaslik = map["notBaslik"];
    notIcerik = map["notIcerik"];
    notTarih = map["notTarih"];
    notOncelik = map["notOncelik"];
  }
}

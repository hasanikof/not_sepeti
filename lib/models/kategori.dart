class Kategori {
  int? kategoriID;
  String? kategoriBaslik;

  //db ye eklerken kullanılıyor
  //id ye gerek yok db otomatik oluşturuyor
  Kategori(this.kategoriBaslik);

  //db den veri okunurken kullanılıyor
  Kategori.withID(this.kategoriID, this.kategoriBaslik);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map["kategoriID"] = kategoriID;
    map["kategoriBaslik"] = kategoriBaslik;

    return map;
  }

  Kategori.fromMap(Map<String, dynamic> map) {
    this.kategoriID = map["kategoriID"];
    this.kategoriBaslik = map["kategoriBaslik"];
  }
}

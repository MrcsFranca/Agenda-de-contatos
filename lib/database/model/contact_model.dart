String idColumn = "idColumn";
String nameColumn = "nameColumn";
String emailColumn = "emailColumn";
String phoneColumn = "phoneColumn";
String imgColumn = "imgColumn";
String contactTable = "contactTable";

String cepColumn = "cepColumn";
String logradouroColumn = "logradouroColumn";
String numeroColumn = "numeroColumn";
String complementoColumn = "complementoColumn";
String bairroColumn = "bairroColumn";
String cidadeColumn = "cidadeColumn";
String ufColumn = "ufColumn";

class Contact {
  Contact({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.img,
    this.cep,
    this.logradouro,
    this.numero,
    this.complemento,
    this.bairro,
    this.cidade,
    this.uf,
  });

  int? id;
  String name;
  String email;
  String phone;
  String? img;
  String? cep;
  String? logradouro;
  String? numero;
  String? complemento;
  String? bairro;
  String? cidade;
  String? uf;

  Contact.fromMap(Map<String, dynamic> map)
    : id = map[idColumn],
      name = map[nameColumn],
      email = map[emailColumn],
      phone = map[phoneColumn],
      img = map[imgColumn],
      cep = map[cepColumn],
      logradouro = map[logradouroColumn],
      numero = map[numeroColumn],
      complemento = map[complementoColumn],
      bairro = map[bairroColumn],
      cidade = map[cidadeColumn],
      uf = map[ufColumn];

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img,
      cepColumn: cep,
      logradouroColumn: logradouro,
      numeroColumn: numero,
      complementoColumn: complemento,
      bairroColumn: bairro,
      cidadeColumn: cidade,
      ufColumn: uf,
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img), cep: $cep";
  }
}

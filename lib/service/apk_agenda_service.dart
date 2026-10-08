import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class Validador {
  static String? cep(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'CEP é obrigatório';
    String numeros = valor.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeros.length != 8) return 'CEP deve ter 8 dígitos';
    return null;
  }

  static String? email(String? valor) {
    if (valor == null || valor.trim().isEmpty) return null;
    final regex = RegExp(
      r'^[a-z0-9._%+-]+@[a-z0-9-]+(\.[a-z0-9-]+)*\.[a-z]{2,}$',
    );
    if (!regex.hasMatch(valor.trim().toLowerCase())) return 'E-mail inválido';
    return null;
  }
}

class InvertextoApiService {
  static const String _token = String.fromEnvironment('INVERTEXTO_TOKEN');

  Future<Map<String, dynamic>> buscaCEP(String? valor) async {
    final erro = Validador.cep(valor);
    if (erro != null) throw Exception(erro);

    final uri = Uri.parse(
      "https://api.invertexto.com/v1/cep/$valor",
    ).replace(queryParameters: {'token': _token});
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } on SocketException {
      throw Exception('Erro de conexão com a internet');
    } catch (e) {
      rethrow;
    }
  }
}

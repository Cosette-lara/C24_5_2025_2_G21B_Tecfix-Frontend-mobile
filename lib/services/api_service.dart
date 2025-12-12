import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/ubicacion_model.dart';
import '../models/tipo_incidencia_model.dart';
import '../models/incidencia_model.dart';

class ApiService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<dynamic>> _get(String endpoint) async {
    try {
      final token = await _getToken();
      final res = await http.get(
        Uri.parse('${Constants.baseUrl}/$endpoint'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      print("Error GET $endpoint: $e");
    }
    return [];
  }

  Future<List<Pabellon>> getPabellones() async {
    final data = await _get('ubicacion/pabellones');
    return data.map((e) => Pabellon.fromJson(e)).toList();
  }

  Future<List<Salon>> getSalones(int idPabellon) async {
    final data = await _get('ubicacion/salones/$idPabellon');
    return data.map((e) => Salon.fromJson(e)).toList();
  }

  Future<List<TipoIncidencia>> getTipos() async {
    final data = await _get('tipos');
    return data.map((e) => TipoIncidencia.fromJson(e)).toList();
  }

  Future<List<Incidencia>> getMisReportes() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final data = await _get('incidencia/mis-reportes/$userId');
    return data.map((e) => Incidencia.fromJson(e)).toList();
  }

  Future<bool> crearIncidencia({
    required String descripcion,
    required String urgencia,
    required int idSalon,
    required int idTipo,
    required File fotoCodigo,
    required File fotoAveria,
  }) async {
    try {
      final token = await _getToken();
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      var request = http.MultipartRequest(
          'POST', Uri.parse('${Constants.baseUrl}/incidencia/crear'));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['descripcion'] = descripcion;
      request.fields['urgencia'] = urgencia;
      request.fields['id_salon'] = idSalon.toString();
      request.fields['id_tipo'] = idTipo.toString();
      request.fields['id_usuario_reporta'] = userId.toString();

      request.files.add(
          await http.MultipartFile.fromPath('foto_codigo', fotoCodigo.path));
      request.files.add(
          await http.MultipartFile.fromPath('foto_averia', fotoAveria.path));

      var response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      print("Error enviando reporte: $e");
      return false;
    }
  }
}

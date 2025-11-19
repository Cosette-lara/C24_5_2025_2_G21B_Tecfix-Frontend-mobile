// Archivo: lib/screens/reportar_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:tecfix_frontend_mobile/utils/constants.dart';

// --- Modelos de Datos para los Dropdowns ---

class Pabellon {
  final int id;
  final String nombre;
  Pabellon({required this.id, required this.nombre});
  
  factory Pabellon.fromJson(Map<String, dynamic> json) {
    return Pabellon(
      id: json['id_pabellon'],
      nombre: json['nombre_pabellon'],
    );
  }
}

class Salon {
  final int id;
  final String nombre;
  Salon({required this.id, required this.nombre});

  factory Salon.fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json['id_salon'],
      nombre: json['nombre_salon'],
    );
  }
}

// --- Pantalla Principal ---

class ReportarScreen extends StatefulWidget {
  const ReportarScreen({Key? key}) : super(key: key);

  @override
  _ReportarScreenState createState() => _ReportarScreenState();
}

class _ReportarScreenState extends State<ReportarScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores de texto
  final _descripcionController = TextEditingController();
  
  // Listas para los Dropdowns
  List<Pabellon> _listaPabellones = [];
  List<Salon> _listaSalones = [];
  
  // Valores seleccionados
  Pabellon? _pabellonSeleccionado;
  Salon? _salonSeleccionado;
  String? _tipoSeleccionado; // Asumimos ID 1, 2, 3...
  String? _urgenciaSeleccionada; // "Baja", "Media", "Alta", "Crítica"
  
  File? _fotoSeleccionada;
  bool _estaEnviando = false;
  bool _cargandoPabellones = true;
  bool _cargandoSalones = false;

  @override
  void initState() {
    super.initState();
    _fetchPabellones();
  }

  // --- LÓGICA DE CONEXIÓN AL BACKEND (Dropdowns) ---

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      // Manejar error de autenticación, ej. navegar al login
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (ctx) => const Scaffold(body: Center(child: Text("Sesión expirada. Por favor, inicie sesión.")))),
        (Route<dynamic> route) => false,
      );
    }
    return token;
  }

  // Paso 1: Carga los Pabellones al iniciar la pantalla
  Future<void> _fetchPabellones() async {
    setState(() { _cargandoPabellones = true; });
    try {
      final token = await _getToken();
      if (token == null) return;
      
      final response = await http.get(
        Uri.parse('$API_URL/api/ubicaciones/pabellones'),
        headers: {'x-auth-token': token},
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _listaPabellones = data.map((json) => Pabellon.fromJson(json)).toList();
        });
      } else {
        throw Exception('Error al cargar pabellones');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() { _cargandoPabellones = false; });
    }
  }

  // Paso 2: Carga los Salones CUANDO se selecciona un Pabellón
  Future<void> _fetchSalones(int idPabellon) async {
    setState(() { 
      _cargandoSalones = true; 
      _salonSeleccionado = null; // Resetea el salón anterior
    });
    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$API_URL/api/ubicaciones/salones/$idPabellon'),
        headers: {'x-auth-token': token},
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _listaSalones = data.map((json) => Salon.fromJson(json)).toList();
        });
      } else {
        throw Exception('Error al cargar salones');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() { _cargandoSalones = false; });
    }
  }

  // --- Lógica de la Cámara y Galería ---
  Future<void> _tomarFoto(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 1024);
    if (pickedFile != null) {
      setState(() {
        _fotoSeleccionada = File(pickedFile.path);
      });
    }
  }

  // --- LÓGICA DE CONEXIÓN AL BACKEND (Enviar Reporte RF-01) ---
  Future<void> _enviarReporte() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fotoSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe adjuntar una prueba fotográfica.')),
      );
      return;
    }

    setState(() { _estaEnviando = true; });

    try {
      // 1. Obtener datos de sesión
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final idUsuario = prefs.getInt('usuario_id');
      if (token == null || idUsuario == null) throw Exception('Sesión inválida.');

      // 2. Preparar la solicitud Multipart (para enviar archivos)
      var request = http.MultipartRequest('POST', Uri.parse('$API_URL/api/incidencias'));

      // 3. Añadir cabecera de autenticación (RNF-03)
      request.headers['x-auth-token'] = token;

      // 4. Añadir los campos del formulario (basado en el backend)
      request.fields['descripcion'] = _descripcionController.text;
      request.fields['id_salon'] = _salonSeleccionado!.id.toString(); // <-- CAMPO NUEVO (normalizado)
      request.fields['id_tipo'] = _tipoSeleccionado!; // (Ej. '1', '2', '3')
      request.fields['urgencia'] = _urgenciaSeleccionada!; // (Ej. 'Baja', 'Media', 'Alta')
      request.fields['id_usuario_reporta'] = idUsuario.toString();
      
      // 5. Añadir el archivo de la foto
      request.files.add(
        await http.MultipartFile.fromPath(
          'prueba_fotografica', // Debe coincidir con el nombre en Multer (backend)
          _fotoSeleccionada!.path,
        ),
      );

      // 6. Enviar la solicitud
      var response = await request.send();

      // 7. Manejar la respuesta
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incidencia reportada con éxito.')),
        );
        _limpiarFormulario();
        // TODO: Notificar a las otras pantallas que se actualicen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reportar (Código: ${response.statusCode})')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: ${e.toString()}')),
      );
    } finally {
      setState(() { _estaEnviando = false; });
    }
  }

  void _limpiarFormulario() {
    _formKey.currentState?.reset();
    _descripcionController.clear();
    setState(() {
      _pabellonSeleccionado = null;
      _salonSeleccionado = null;
      _listaSalones = [];
      _tipoSeleccionado = null;
      _urgenciaSeleccionada = null;
      _fotoSeleccionada = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Incidencia'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('¿Qué problema encontraste?', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              
              // --- Campo: Descripción ---
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Describe el problema',
                  hintText: 'Explica qué está pasando, cuándo lo notaste...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                maxLines: 4,
                validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),

              // --- Campo: Pabellón (Dropdown 1) ---
              DropdownButtonFormField<Pabellon>(
                initialValue: _pabellonSeleccionado,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Pabellón / Área',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: _cargandoPabellones ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2)) : null,
                ),
                hint: const Text('Seleccione un pabellón'),
                items: _listaPabellones.map((pabellon) {
                  return DropdownMenuItem(
                    value: pabellon,
                    child: Text(pabellon.nombre),
                  );
                }).toList(),
                onChanged: (Pabellon? newValue) {
                  setState(() {
                    _pabellonSeleccionado = newValue;
                  });
                  if (newValue != null) {
                    _fetchSalones(newValue.id); // Carga el segundo dropdown
                  }
                },
                validator: (value) => (value == null) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              
              // --- Campo: Salón (Dropdown 2) ---
              DropdownButtonFormField<Salon>(
                initialValue: _salonSeleccionado,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Salón / Oficina',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: _cargandoSalones ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2)) : null,
                ),
                hint: Text(_pabellonSeleccionado == null ? 'Primero elija un pabellón' : 'Seleccione un salón'),
                // El dropdown está deshabilitado si no hay pabellón o si está cargando
                items: (_pabellonSeleccionado == null || _cargandoSalones) 
                    ? [] 
                    : _listaSalones.map((salon) {
                  return DropdownMenuItem(
                    value: salon,
                    child: Text(salon.nombre),
                  );
                }).toList(),
                onChanged: (Salon? newValue) {
                  setState(() {
                    _salonSeleccionado = newValue;
                  });
                },
                validator: (value) => (value == null) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              
              // --- Campo: Tipo de Problema ---
              DropdownButtonFormField<String>(
                initialValue: _tipoSeleccionado,
                decoration: InputDecoration(
                  labelText: '¿Qué tipo de problema es?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                hint: const Text('Seleccione el tipo'),
                items: const [
                  // Estos IDs deben coincidir con la BD (script_db.sql)
                  DropdownMenuItem(value: '1', child: Text('Eléctrico')),
                  DropdownMenuItem(value: '2', child: Text('Infraestructura')),
                  DropdownMenuItem(value: '3', child: Text('Sanitario')),
                  DropdownMenuItem(value: '4', child: Text('Equipamiento de Taller')),
                  DropdownMenuItem(value: '5', child: Text('Sistemas')),
                ],
                onChanged: (value) => setState(() => _tipoSeleccionado = value),
                validator: (value) => (value == null) ? 'Campo requerido' : null,
              ),
const SizedBox(height: 16),
              
              // --- Campo: Urgencia ---
              DropdownButtonFormField<String>(
                initialValue: _urgenciaSeleccionada,
                decoration: InputDecoration(
                  labelText: '¿Qué tan urgente es?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                hint: const Text('Seleccione la urgencia'),
                items: const [
                  DropdownMenuItem(value: 'Baja', child: Text('Baja - Puede esperar')),
                  DropdownMenuItem(value: 'Media', child: Text('Media - Atender pronto')),
                  DropdownMenuItem(value: 'Alta', child: Text('Alta - Atender hoy')),
                  DropdownMenuItem(value: 'Crítica', child: Text('Crítica - ¡Urgente!')),
                ],
                onChanged: (value) => setState(() => _urgenciaSeleccionada = value),
                validator: (value) => (value == null) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 24),

              // --- Sección: Prueba Fotográfica ---
              Text('Prueba Fotográfica (Requerida)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _fotoSeleccionada == null
                    ? const Center(child: Text('Aún no se ha seleccionado una foto.'))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_fotoSeleccionada!, fit: BoxFit.cover, width: double.infinity),
                      ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Tomar Foto'),
                    onPressed: () => _tomarFoto(ImageSource.camera),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image_search),
                    label: const Text('Galería'),
                    onPressed: () => _tomarFoto(ImageSource.gallery),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[7700]),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- Botón: Enviar Reporte ---
              ElevatedButton(
                onPressed: _estaEnviando ? null : _enviarReporte,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _estaEnviando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Enviar Reporte'),
              ),
              TextButton(
                onPressed: _estaEnviando ? null : _limpiarFormulario,
                child: const Text('Cancelar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
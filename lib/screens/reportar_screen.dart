import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/ubicacion_model.dart';
import '../models/tipo_incidencia_model.dart';

class ReportarScreen extends StatefulWidget {
  @override
  _ReportarScreenState createState() => _ReportarScreenState();
}

class _ReportarScreenState extends State<ReportarScreen> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();

  List<Pabellon> _pabs = [];
  List<Salon> _sals = [];
  List<TipoIncidencia> _tipos = [];

  Pabellon? _selPab;
  Salon? _selSal;
  TipoIncidencia? _selTipo;

  String _desc = '';
  String _urg = 'Media';
  File? _f1, _f2;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    try {
      final p = await _api.getPabellones();
      final t = await _api.getTipos();
      if (!mounted) return;
      setState(() {
        _pabs = p;
        _tipos = t;
      });
    } catch (e) {}
  }

  void _enviar() async {
    if (!_formKey.currentState!.validate() ||
        _selSal == null ||
        _selTipo == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Complete todos los campos')));
      return;
    }
    if (_f1 == null || _f2 == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Faltan fotos')));
      return;
    }

    setState(() => _loading = true);
    bool ok = await _api.crearIncidencia(
        descripcion: _desc,
        urgencia: _urg,
        idSalon: _selSal!.id,
        idTipo: _selTipo!.id,
        fotoCodigo: _f1!,
        fotoAveria: _f2!);

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Enviado correctamente')));
      setState(() {
        _desc = '';
        _selSal = null;
        _selPab = null;
        _selTipo = null;
        _f1 = null;
        _f2 = null;
      });
      _formKey.currentState!.reset();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al enviar')));
    }
  }

  Future<void> _foto(bool codigo) async {
    final f = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50);
    if (f != null)
      setState(() => codigo ? _f1 = File(f.path) : _f2 = File(f.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reportar')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(children: [
                  DropdownButtonFormField<Pabellon>(
                      hint: Text('Pabellón'),
                      value: _selPab,
                      items: _pabs
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e.nombre)))
                          .toList(),
                      onChanged: (v) async {
                        setState(() {
                          _selPab = v;
                          _sals = [];
                          _selSal = null;
                        });
                        if (v != null) {
                          final s = await _api.getSalones(v.id);
                          if (!mounted) return;
                          setState(() => _sals = s);
                        }
                      }),
                  DropdownButtonFormField<Salon>(
                    hint: Text('Salón'),
                    value: _selSal,
                    items: _sals
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text(e.nombre)))
                        .toList(),
                    onChanged: (v) => setState(() => _selSal = v),
                  ),
                  DropdownButtonFormField<TipoIncidencia>(
                    hint: Text('Tipo Problema'),
                    value: _selTipo,
                    items: _tipos
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text(e.nombre)))
                        .toList(),
                    onChanged: (v) => setState(() => _selTipo = v),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Descripción'),
                    onChanged: (v) => _desc = v,
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  DropdownButtonFormField(
                    value: _urg,
                    items: ['Baja', 'Media', 'Alta']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _urg = v!),
                  ),
                  SizedBox(height: 20),
                  Row(children: [
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () => _foto(true),
                            child: Text(_f1 == null ? 'Foto Código' : 'OK'))),
                    SizedBox(width: 10),
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () => _foto(false),
                            child: Text(_f2 == null ? 'Foto Falla' : 'OK'))),
                  ]),
                  SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: _enviar, child: Text('ENVIAR REPORTE'))
                ]),
              ),
            ),
    );
  }
}

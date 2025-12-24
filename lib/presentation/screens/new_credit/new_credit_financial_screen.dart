/*

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../../models/credito_dto.dart';
import '../../../services/creditoMostrarHome.dart';
import '../../../presentation/widgets/custom_text_field.dart';
import '../../../models/CreditoMostrarDTO.dart';
import '../../../presentation/widgets/photo_upload_card.dart'; // Importar
import '../../../services/firebase_service.dart'; // Importar

class NewCreditFinancialScreen extends StatefulWidget {
  //final int clienteId;
  final int tiendaId;

  const NewCreditFinancialScreen({super.key, required this.tiendaId,
  /*, required this.clienteId, required this.tiendaId*/});

  @override
  State<NewCreditFinancialScreen> createState() => _NewCreditFinancialScreenState();
}

class _NewCreditFinancialScreenState extends State<NewCreditFinancialScreen> {
 
 final creditoMostrarHome creditoHomeService = creditoMostrarHome();

  final _formKey = GlobalKey<FormState>();

  final _montoCtrl = TextEditingController();
  final _entradaCtrl = TextEditingController();
  final _plazoCtrl = TextEditingController();
 DateTime _proximaCuota = DateTime.now();
  String? _frecuenciaSeleccionada;

  // VARIABLES DE EVIDENCIA (Contrato y Celular)
  File? _fotoContrato;
  File? _fotoCelular;

  bool _isLoading = false;

  // Variables calculadas
  double _valorCuota = 0.0;
  double _totalPagar = 0.0;

  final List<String> _frecuencias = ['Semanal', 'Quincenal', 'Mensual'];
//final creditoServicio = creditoMostrarHome();
 //late final creditoMostrarHome creditoServicio;

  // NUEVOS
  final _marcaCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _montoCtrl.addListener(_calcularValores);
    _entradaCtrl.addListener(_calcularValores);
    _plazoCtrl.addListener(_calcularValores);
    
     debugPrint("🟠 [NEW CREDIT] usando instancia → hash: ${creditoHomeService.hashCode}");
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _entradaCtrl.dispose();
    _plazoCtrl.dispose();
    super.dispose();
  }
 // NUEVO: Variable para el combo de cuotas
  int? _plazoSeleccionado;
  final List<int> _opcionesCuotas = [3, 6, 9, 12, 15, 18, 24];
  // --- LÓGICA DE CALCULADORA ---
  void _calcularValores() {
    double monto = double.tryParse(_montoCtrl.text) ?? 0.0;
    double entrada = double.tryParse(_entradaCtrl.text) ?? 0.0;
    int plazo = int.tryParse(_plazoCtrl.text) ?? 0;

    if (monto > 0 && plazo > 0) {
      double saldoFinanciar = monto - entrada;

      // Simulación de Interés
      double factorInteres = 1.0;
      if (_frecuenciaSeleccionada == 'Semanal') factorInteres = 1.05;
      if (_frecuenciaSeleccionada == 'Quincenal') factorInteres = 1.10;
      if (_frecuenciaSeleccionada == 'Mensual') factorInteres = 1.15;

      double totalConInteres = saldoFinanciar * (_frecuenciaSeleccionada != null ? factorInteres : 1.0);

      setState(() {
        _totalPagar = totalConInteres;
        _valorCuota = totalConInteres / plazo;
      });
    } else {
      setState(() {
        _valorCuota = 0.0;
        _totalPagar = 0.0;
      });
    }
  }

  void _finalizarSolicitud() async {
    // ... validaciones ...
    if (_marcaCtrl.text.isEmpty || _modeloCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falta Marca o Modelo')));
      return;
    }

    // VALIDACIÓN DE EVIDENCIAS (NUEVO)
    if (_fotoContrato == null || _fotoCelular == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes subir fotos de Contrato y Celular'), backgroundColor: Colors.red)
      );
      return;
    }

    setState(() => _isLoading = true);

    // Dialogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 20), Text("Subiendo evidencias...", style: TextStyle(fontWeight: FontWeight.bold))]),
        ),
      ),
    );

    try {
      final firebaseService = FirebaseService();

      // 1. SUBIR EVIDENCIAS
       String? urlContrato = await firebaseService.uploadImage(_fotoContrato!, 'contratos_nuevos');
      String? urlCelular = await firebaseService.uploadImage(_fotoCelular!, 'celulares_nuevos');

      // Simulación
      await Future.delayed(const Duration(seconds: 2));
     

      if (mounted) Navigator.pop(context); // Cierra loading fotos

      // 2. CREAR DTO
      final credito = CreditoDTO(
        id: 0,
        //clienteId: widget.clienteId,
        montoTotal: double.parse(_montoCtrl.text),
        entrada: _entradaCtrl.text.isEmpty ? 0.0 : double.parse(_entradaCtrl.text),
        plazoCuotas: _plazoSeleccionado!,
        frecuenciaPago: _frecuenciaSeleccionada!,
        valorPorCuota: _valorCuota,
        montoPendiente: _totalPagar,
        diaPago: DateTime.now(),
        estado: "Pendiente",
        tiendaId: widget.tiendaId,

        // CAMPOS NUEVOS
        marca: _marcaCtrl.text,
        modelo: _modeloCtrl.text,
        estadoCuota: "Pendiente",
        abonadoTotal: 0.0,

        fotoContratoUrl: urlContrato,
        fotoCelularUrl: urlCelular,
      );
        //final CreditoServicio = creditoMostrarHome();

   final response=await creditoHomeService.guardarCredito(credito);

      debugPrint("✅ [NEW CREDIT] Crédito creado en backend:");
    debugPrint("id: ${response.id}");
    debugPrint("montoPendiente: ${response.montoPendiente}");
    debugPrint("estado: ${response.estado}");
    debugPrint("proximaCuotaStr: ${response.proximaCuotaStr}");
    
   
      // LLAMADA AL BACKEND:

  // 2️⃣ Refrescar la lista completa desde backend
  await creditoHomeService.getCreditos(forceRefresh: true);
  debugPrint("🟠 [NEW CREDIT] notifier → ${creditoHomeService.creditosNotifier.value?.length}");
 
     debugPrint("🔄 ValueNotifier después de actualizar:");
    debugPrint(creditoHomeService.creditosNotifier.value.toString());
      await Future.delayed(const Duration(seconds: 2)); // Simulación

      if (mounted) {
        setState(() => _isLoading = false);
        _mostrarExito(credito.montoTotal);
      }

    } catch (e) {
      if (mounted) Navigator.pop(context);
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al enviar solicitud')));
    }
  }

  void _mostrarExito(double monto) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: const Column(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text('¡Solicitud Exitosa!'),
          ],
        ),
        content: Text('Tu crédito por \$$monto ha sido registrado correctamente.', textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
  //            context.go('/home');
              context.go('/home', extra: true);
                      // cerrar diálogo
 // context.go('/home', extra: true);
  debugPrint("✅ [NEW CREDIT] Crédito creado, haciendo pop()");
//context.pop(true);
  // context.pop(true);      // Volver al inicio
            },
            child: const Text('FINALIZAR'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String etiquetaCuota = _frecuenciaSeleccionada != null ? "Cuota $_frecuenciaSeleccionada" : "Cuota Estimada";

    return Scaffold(
      appBar: AppBar(title: const Text('Paso 3: Cotizador Final')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- CALCULADORA ---
              FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Text('RESUMEN DE PAGOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$etiquetaCuota:', style: const TextStyle(fontSize: 16)),
                          Text('\$${_valorCuota.toStringAsFixed(2)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                        ],
                      ),
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total a Financiar:', style: TextStyle(fontWeight: FontWeight.w500)),
                          Text('\$${_totalPagar.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: CustomTextField(label: 'Marca', controller: _marcaCtrl, icon: Icons.branding_watermark)),
                  const SizedBox(width: 10),
                  Expanded(child: CustomTextField(label: 'Modelo', controller: _modeloCtrl, icon: Icons.phone_android)),
                ],
              ),

              const SizedBox(height: 15),
              CustomTextField(
                label: 'Precio Equipo (\$)',
                controller: _montoCtrl,
                keyboardType: TextInputType.number,
                icon: Icons.attach_money,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),

              CustomTextField(
                  label: 'Entrada Inicial (\$)',
                  controller: _entradaCtrl,
                  keyboardType: TextInputType.number,
                  icon: Icons.money_off
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Plazo',
                      controller: _plazoCtrl,
                      keyboardType: TextInputType.number,
                      icon: Icons.calendar_today,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),

// 4. CAMBIO: DROPDOWN DE CUOTAS
                  

                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Frecuencia', border: OutlineInputBorder()),
                      value: _frecuenciaSeleccionada,
                      items: _frecuencias.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                      onChanged: (v) {
                        setState(() => _frecuenciaSeleccionada = v);
                        _calcularValores();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // --- SECCIÓN EVIDENCIAS (NUEVO) ---
              const Divider(),
              const Text("EVIDENCIA DIGITAL", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(child: PhotoUploadCard(label: 'Contrato Nuevo *', onImageSelected: (f) => _fotoContrato = f)),
                  const SizedBox(width: 10),
                  Expanded(child: PhotoUploadCard(label: 'Celular Nuevo *', onImageSelected: (f) => _fotoCelular = f)),
                ],
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _finalizarSolicitud,
                  style: ElevatedButton.styleFrom(elevation: 5, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: _isLoading
                      ? const Text('Procesando...', style: TextStyle(color: Colors.white))
                      : const Text('FINALIZAR SOLICITUD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


 */

/*

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../../models/credito_dto.dart';
import '../../../services/creditoMostrarHome.dart';
import '../../../presentation/widgets/custom_text_field.dart';
import '../../../models/CreditoMostrarDTO.dart';
import '../../../presentation/widgets/photo_upload_card.dart';
import '../../../services/firebase_service.dart';

class NewCreditFinancialScreen extends StatefulWidget {
  final int tiendaId;
  // Se requiere el clienteId para crear el crédito, se puede pasar en el constructor o sacar del provider
  // Aquí asumo que viene en el mapa de argumentos del router como vimos antes, si no, restáuralo.
  final int clienteId;

  const NewCreditFinancialScreen({
    super.key,
    required this.tiendaId,
    required this.clienteId,
  });

  @override
  State<NewCreditFinancialScreen> createState() => _NewCreditFinancialScreenState();
}

class _NewCreditFinancialScreenState extends State<NewCreditFinancialScreen> {

  final creditoMostrarHome creditoHomeService = creditoMostrarHome();
  final _formKey = GlobalKey<FormState>();

  final _montoCtrl = TextEditingController();
  final _entradaCtrl = TextEditingController();
  // final _plazoCtrl = TextEditingController(); // YA NO SE USA

  DateTime _proximaCuota = DateTime.now();
  String? _frecuenciaSeleccionada;

  // VARIABLES DE EVIDENCIA
  File? _fotoContrato;
  File? _fotoCelular;

  bool _isLoading = false;

  // Variables calculadas
  double _valorCuota = 0.0;
  double _totalPagar = 0.0;

  final List<String> _frecuencias = ['Semanal', 'Quincenal', 'Mensual'];

  // NUEVOS
  final _marcaCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();

  // COMBO CUOTAS
  int? _plazoSeleccionado;
  final List<int> _opcionesCuotas = [3, 6, 9, 12, 15, 18, 24];

  @override
  void initState() {
    super.initState();
    _montoCtrl.addListener(_calcularValores);
    _entradaCtrl.addListener(_calcularValores);
    // _plazoCtrl.addListener(_calcularValores);

    debugPrint("🟠 [NEW CREDIT] usando instancia → hash: ${creditoHomeService.hashCode}");
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _entradaCtrl.dispose();
    _marcaCtrl.dispose();
    _modeloCtrl.dispose();
    super.dispose();
  }

  // --- LÓGICA DE CALCULADORA ---
  void _calcularValores() {
    double monto = double.tryParse(_montoCtrl.text) ?? 0.0;
    double entrada = double.tryParse(_entradaCtrl.text) ?? 0.0;
    int plazo = _plazoSeleccionado ?? 0; // Usamos el combo

    if (monto > 0 && plazo > 0) {
      double saldoFinanciar = monto - entrada;

      // Simulación de Interés
      double factorInteres = 1.0;
      if (_frecuenciaSeleccionada == 'Semanal') factorInteres = 1.05;
      if (_frecuenciaSeleccionada == 'Quincenal') factorInteres = 1.10;
      if (_frecuenciaSeleccionada == 'Mensual') factorInteres = 1.15;

      double totalConInteres = saldoFinanciar * (_frecuenciaSeleccionada != null ? factorInteres : 1.0);

      setState(() {
        _totalPagar = totalConInteres;
        _valorCuota = totalConInteres / plazo;
      });
    } else {
      setState(() {
        _valorCuota = 0.0;
        _totalPagar = 0.0;
      });
    }
  }

  void _finalizarSolicitud() async {
    if (!_formKey.currentState!.validate()) return;

    if (_marcaCtrl.text.isEmpty || _modeloCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falta Marca o Modelo')));
      return;
    }
    if (_frecuenciaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una frecuencia')));
      return;
    }
    if (_plazoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona el plazo')));
      return;
    }

    // VALIDACIÓN DE EVIDENCIAS
    if (_fotoContrato == null || _fotoCelular == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes subir fotos de Contrato y Celular'), backgroundColor: Colors.red)
      );
      return;
    }

    setState(() => _isLoading = true);

    // Dialogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 20), Text("Subiendo evidencias...", style: TextStyle(fontWeight: FontWeight.bold))]),
        ),
      ),
    );

    try {
      final firebaseService = FirebaseService();

      // 1. SUBIR EVIDENCIAS
      String? urlContrato = await firebaseService.uploadImage(_fotoContrato!, 'contratos_nuevos');
      String? urlCelular = await firebaseService.uploadImage(_fotoCelular!, 'celulares_nuevos');

      // Simulación (Quitar en producción si usas Firebase real arriba)
      await Future.delayed(const Duration(seconds: 2));
      // Si la subida real falla, urlContrato será null
      if (urlContrato == null || urlCelular == null) throw Exception("Error al subir evidencias");

      if (mounted) Navigator.pop(context); // Cierra loading fotos

      // 2. CREAR DTO
      final now = DateTime.now().toUtc();

      final credito = CreditoDTO(
        id: 0,
        clienteId: widget.clienteId, // Usamos el ID pasado al widget
        montoTotal: double.parse(_montoCtrl.text),
        entrada: _entradaCtrl.text.isEmpty ? 0.0 : double.parse(_entradaCtrl.text),
        plazoCuotas: _plazoSeleccionado!,
        frecuenciaPago: _frecuenciaSeleccionada!,
        valorPorCuota: _valorCuota,
        montoPendiente: _totalPagar,
        diaPago: DateTime.now(),
        proximaCuota: _proximaCuota,
        proximaCuotaStr: DateFormat('yyyy-MM-dd').format(_proximaCuota),
        estado: "Pendiente",
        tiendaId: widget.tiendaId,
        fechaCreacion: now,

        // CAMPOS NUEVOS
        marca: _marcaCtrl.text,
        modelo: _modeloCtrl.text,
        estadoCuota: "Pendiente",
        abonadoTotal: 0.0,

        // CAMPO STRING FECHA
        fechaCreacionStr: DateFormat('dd/MM/yyyy').format(now),

        fotoContratoUrl: urlContrato,
        fotoCelularUrl: urlCelular,
      );

      final response = await creditoHomeService.guardarCredito(credito);

      debugPrint("✅ [NEW CREDIT] Crédito creado en backend ID: ${response.id}");

      // 2️⃣ Refrescar la lista completa desde backend
      await creditoHomeService.getCreditos(forceRefresh: true);

      if (mounted) {
        setState(() => _isLoading = false);
        _mostrarExito(credito.montoTotal);
      }

    } catch (e) {
      if (mounted) Navigator.pop(context);
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al enviar solicitud')));
    }
  }

  void _mostrarExito(double monto) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: const Column(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text('¡Solicitud Exitosa!'),
          ],
        ),
        content: Text('Tu crédito por \$$monto ha sido registrado correctamente.', textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              context.go('/home', extra: true); // Regresar al home
            },
            child: const Text('FINALIZAR'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String etiquetaCuota = _frecuenciaSeleccionada != null ? "Cuota $_frecuenciaSeleccionada" : "Cuota Estimada";

    return Scaffold(
      appBar: AppBar(title: const Text('Paso 3: Cotizador Final')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- CALCULADORA ---
              FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Text('RESUMEN DE PAGOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$etiquetaCuota:', style: const TextStyle(fontSize: 16)),
                          Text('\$${_valorCuota.toStringAsFixed(2)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                        ],
                      ),
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total a Financiar:', style: TextStyle(fontWeight: FontWeight.w500)),
                          Text('\$${_totalPagar.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: CustomTextField(label: 'Marca', controller: _marcaCtrl, icon: Icons.branding_watermark)),
                  const SizedBox(width: 10),
                  Expanded(child: CustomTextField(label: 'Modelo', controller: _modeloCtrl, icon: Icons.phone_android)),
                ],
              ),

              const SizedBox(height: 15),
              CustomTextField(
                label: 'Precio Equipo (\$)', controller: _montoCtrl, keyboardType: TextInputType.number, icon: Icons.attach_money,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),

              CustomTextField(
                  label: 'Entrada Inicial (\$)', controller: _entradaCtrl, keyboardType: TextInputType.number, icon: Icons.money_off
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    // --- COMBO DE CUOTAS ---
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Plazo (Cuotas)',
                        prefixIcon: const Icon(Icons.calendar_view_week),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      value: _plazoSeleccionado,
                      items: _opcionesCuotas.map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value cuotas'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _plazoSeleccionado = val;
                          _calcularValores();
                        });
                      },
                      validator: (v) => v == null ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Frecuencia', border: OutlineInputBorder()),
                      value: _frecuenciaSeleccionada,
                      items: _frecuencias.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                      onChanged: (v) {
                        setState(() => _frecuenciaSeleccionada = v);
                        _calcularValores();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // --- SECCIÓN EVIDENCIAS ---
              const Divider(),
              const Text("EVIDENCIA DIGITAL", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(child: PhotoUploadCard(label: 'Contrato Nuevo *', onImageSelected: (f) => _fotoContrato = f)),
                  const SizedBox(width: 10),
                  Expanded(child: PhotoUploadCard(label: 'Celular Nuevo *', onImageSelected: (f) => _fotoCelular = f)),
                ],
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _finalizarSolicitud,
                  style: ElevatedButton.styleFrom(elevation: 5, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: _isLoading
                      ? const Text('Procesando...', style: TextStyle(color: Colors.white))
                      : const Text('FINALIZAR SOLICITUD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../../models/credito_dto.dart';
import '../../../services/creditoMostrarHome.dart';
import '../../../services/usuario_service.dart'; // <--- IMPORTANTE: Para obtener el ID
import '../../../presentation/widgets/custom_text_field.dart';
import '../../../presentation/widgets/photo_upload_card.dart';
import '../../../services/firebase_service.dart';

class NewCreditFinancialScreen extends StatefulWidget {
  final int tiendaId;
  // Eliminamos clienteId del constructor para no romper tu ruta existente

  const NewCreditFinancialScreen({
    super.key,
    required this.tiendaId,
  });

  @override
  State<NewCreditFinancialScreen> createState() => _NewCreditFinancialScreenState();
}

class _NewCreditFinancialScreenState extends State<NewCreditFinancialScreen> {
  final creditoMostrarHome creditoHomeService = creditoMostrarHome();
  final UsuarioService _usuarioService = UsuarioService(); // Servicio para buscar el cliente
  final _formKey = GlobalKey<FormState>();

  final _montoCtrl = TextEditingController();
  final _entradaCtrl = TextEditingController();

  final _marcaCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();

  DateTime _proximaCuota = DateTime.now();
  String? _frecuenciaSeleccionada;

  File? _fotoContrato;
  File? _fotoCelular;

  bool _isLoading = false;
  double _valorCuota = 0.0;
  double _totalPagar = 0.0;

  final List<String> _frecuencias = ['Semanal', 'Quincenal', 'Mensual'];
  int? _plazoSeleccionado;
  final List<int> _opcionesCuotas = [3, 6, 9, 12, 15, 18, 24];

  @override
  void initState() {
    super.initState();
    _montoCtrl.addListener(_calcularValores);
    _entradaCtrl.addListener(_calcularValores);
    debugPrint("🟠 [NEW CREDIT] usando instancia → hash: ${creditoHomeService.hashCode}");
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _entradaCtrl.dispose();
    _marcaCtrl.dispose();
    _modeloCtrl.dispose();
    super.dispose();
  }

  void _calcularValores() {
    double monto = double.tryParse(_montoCtrl.text) ?? 0.0;
    double entrada = double.tryParse(_entradaCtrl.text) ?? 0.0;
    int plazo = _plazoSeleccionado ?? 0;

    if (monto > 0 && plazo > 0) {
      double saldoFinanciar = monto - entrada;
      double factorInteres = 1.0;
      if (_frecuenciaSeleccionada == 'Semanal') factorInteres = 1.05;
      if (_frecuenciaSeleccionada == 'Quincenal') factorInteres = 1.10;
      if (_frecuenciaSeleccionada == 'Mensual') factorInteres = 1.15;

      double totalConInteres = saldoFinanciar * (_frecuenciaSeleccionada != null ? factorInteres : 1.0);

      setState(() {
        _totalPagar = totalConInteres;
        _valorCuota = totalConInteres / plazo;
      });
    } else {
      setState(() {
        _valorCuota = 0.0;
        _totalPagar = 0.0;
      });
    }
  }

  void _finalizarSolicitud() async {
    if (!_formKey.currentState!.validate()) return;

    if (_marcaCtrl.text.isEmpty || _modeloCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falta Marca o Modelo')));
      return;
    }
    if (_frecuenciaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una frecuencia')));
      return;
    }
    if (_plazoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona el plazo')));
      return;
    }
    if (_fotoContrato == null || _fotoCelular == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes subir fotos de evidencia'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 20), Text("Procesando solicitud...", style: TextStyle(fontWeight: FontWeight.bold))]),
        ),
      ),
    );

    try {
      // 1. Obtener Cliente ID (Ya que no vino por ruta)
      final clienteData = await _usuarioService.getCliente();
      final int clienteIdReal = clienteData.id;

      final firebaseService = FirebaseService();

      // 2. Subir Fotos
      String? urlContrato = await firebaseService.uploadImage(_fotoContrato!, 'contratos_nuevos');
      String? urlCelular = await firebaseService.uploadImage(_fotoCelular!, 'celulares_nuevos');

      // Simulación (Quitar si ya funciona Firebase real)
      await Future.delayed(const Duration(seconds: 2));

      // Si la subida real falla, urlContrato será null.
      // Si estás en modo prueba y Firebase falla, puedes comentar esta validación temporalmente.
      if (urlContrato == null || urlCelular == null) throw Exception("Error al subir evidencias");

      if (mounted) Navigator.pop(context); // Cierra loading fotos

      // 3. Crear DTO
      final now = DateTime.now().toUtc();

      final credito = CreditoDTO(
        id: 0,
        clienteId: clienteIdReal, // Usamos el ID obtenido del servicio
        montoTotal: double.parse(_montoCtrl.text),
        entrada: _entradaCtrl.text.isEmpty ? 0.0 : double.parse(_entradaCtrl.text),
        plazoCuotas: _plazoSeleccionado!,
        frecuenciaPago: _frecuenciaSeleccionada!,
        valorPorCuota: _valorCuota,
        montoPendiente: _totalPagar,
        diaPago: DateTime.now(),
        proximaCuota: _proximaCuota,
        proximaCuotaStr: DateFormat('yyyy-MM-dd').format(_proximaCuota),
        estado: "Pendiente",
        tiendaId: widget.tiendaId,
        fechaCreacion: now,

        // CAMPOS NUEVOS
        marca: _marcaCtrl.text,
        modelo: _modeloCtrl.text,
        estadoCuota: "Pendiente",
        abonadoTotal: 0.0,
        fechaCreacionStr: DateFormat('dd/MM/yyyy').format(now), // String formateado

        fotoContratoUrl: urlContrato,
        fotoCelularUrl: urlCelular,
      );

      final response = await creditoHomeService.guardarCredito(credito);
      debugPrint("✅ [NEW CREDIT] ID: ${response.id}");

      await creditoHomeService.getCreditos(forceRefresh: true);

      if (mounted) {
        setState(() => _isLoading = false);
        _mostrarExito(credito.montoTotal);
      }

    } catch (e) {
      if (mounted) Navigator.pop(context);
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _mostrarExito(double monto) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: const Column(children: [Icon(Icons.check_circle_outline, color: Colors.green, size: 60), SizedBox(height: 10), Text('¡Solicitud Exitosa!')]),
        content: Text('Tu crédito por \$$monto ha sido registrado.', textAlign: TextAlign.center),
        actions: [TextButton(onPressed: () { Navigator.pop(c); context.go('/home', extra: true); }, child: const Text('FINALIZAR'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String etiquetaCuota = _frecuenciaSeleccionada != null ? "Cuota $_frecuenciaSeleccionada" : "Cuota Estimada";

    return Scaffold(
      appBar: AppBar(title: const Text('Paso 3: Cotizador Final')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.primaryColor.withOpacity(0.3))),
                  child: Column(
                    children: [
                      const Text('RESUMEN DE PAGOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 20),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('$etiquetaCuota:', style: const TextStyle(fontSize: 16)),
                        Text('\$${_valorCuota.toStringAsFixed(2)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                      ]),
                      const Divider(height: 30),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Total a Financiar:', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text('\$${_totalPagar.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: CustomTextField(label: 'Marca', controller: _marcaCtrl, icon: Icons.branding_watermark)),
                  const SizedBox(width: 10),
                  Expanded(child: CustomTextField(label: 'Modelo', controller: _modeloCtrl, icon: Icons.phone_android)),
                ],
              ),

              const SizedBox(height: 15),
              CustomTextField(label: 'Precio Equipo (\$)', controller: _montoCtrl, keyboardType: TextInputType.number, icon: Icons.attach_money, validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 15),
              CustomTextField(label: 'Entrada Inicial (\$)', controller: _entradaCtrl, keyboardType: TextInputType.number, icon: Icons.money_off),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(labelText: 'Plazo (Cuotas)', prefixIcon: const Icon(Icons.calendar_view_week), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      value: _plazoSeleccionado,
                      items: _opcionesCuotas.map((int value) => DropdownMenuItem<int>(value: value, child: Text('$value cuotas'))).toList(),
                      onChanged: (val) { setState(() { _plazoSeleccionado = val; _calcularValores(); }); },
                      validator: (v) => v == null ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Frecuencia', border: OutlineInputBorder()),
                      value: _frecuenciaSeleccionada,
                      items: _frecuencias.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                      onChanged: (v) { setState(() => _frecuenciaSeleccionada = v); _calcularValores(); },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              const Divider(),
              const Text("EVIDENCIA DIGITAL", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(child: PhotoUploadCard(label: 'Contrato Nuevo *', onImageSelected: (f) => _fotoContrato = f)),
                  const SizedBox(width: 10),
                  Expanded(child: PhotoUploadCard(label: 'Celular Nuevo *', onImageSelected: (f) => _fotoCelular = f)),
                ],
              ),

              const SizedBox(height: 50),
              SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _isLoading ? null : _finalizarSolicitud, style: ElevatedButton.styleFrom(elevation: 5, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: _isLoading ? const Text('Procesando...', style: TextStyle(color: Colors.white)) : const Text('FINALIZAR SOLICITUD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../../models/credito_dto.dart';
import '../../../presentation/widgets/custom_text_field.dart';
import '../../../presentation/widgets/photo_upload_card.dart'; // Importar
import '../../../services/firebase_service.dart'; // Importar

class NewCreditFinancialScreen extends StatefulWidget {
  final int clienteId;
  final int tiendaId;

  const NewCreditFinancialScreen({super.key, required this.clienteId, required this.tiendaId});

  @override
  State<NewCreditFinancialScreen> createState() => _NewCreditFinancialScreenState();
}

class _NewCreditFinancialScreenState extends State<NewCreditFinancialScreen> {
  final _formKey = GlobalKey<FormState>();

  final _montoCtrl = TextEditingController();
  final _entradaCtrl = TextEditingController();
  final _plazoCtrl = TextEditingController();

  String? _frecuenciaSeleccionada;

  // VARIABLES DE EVIDENCIA (Contrato y Celular)
  File? _fotoContrato;
  File? _fotoCelular;

  bool _isLoading = false;

  // Variables calculadas
  double _valorCuota = 0.0;
  double _totalPagar = 0.0;

  final List<String> _frecuencias = ['Semanal', 'Quincenal', 'Mensual'];

  @override
  void initState() {
    super.initState();
    _montoCtrl.addListener(_calcularValores);
    _entradaCtrl.addListener(_calcularValores);
    _plazoCtrl.addListener(_calcularValores);
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _entradaCtrl.dispose();
    _plazoCtrl.dispose();
    super.dispose();
  }

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
    if (!_formKey.currentState!.validate()) return;
    if (_frecuenciaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una frecuencia')));
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
      // String? urlContrato = await firebaseService.uploadImage(_fotoContrato!, 'contratos_nuevos');
      // String? urlCelular = await firebaseService.uploadImage(_fotoCelular!, 'celulares_nuevos');

      // Simulación
      await Future.delayed(const Duration(seconds: 2));
      String urlContrato = "https://mock.url/contrato.jpg";
      String urlCelular = "https://mock.url/celular.jpg";

      if (mounted) Navigator.pop(context); // Cierra loading fotos

      // 2. CREAR DTO
      final credito = CreditoDTO(
        id: 0,
        clienteId: widget.clienteId,
        montoTotal: double.parse(_montoCtrl.text),
        entrada: _entradaCtrl.text.isEmpty ? 0.0 : double.parse(_entradaCtrl.text),
        plazoCuotas: int.parse(_plazoCtrl.text),
        frecuenciaPago: _frecuenciaSeleccionada!,
        valorPorCuota: _valorCuota,
        montoPendiente: _totalPagar,
        diaPago: DateTime.now(),
        estado: "PENDIENTE",
        // Nuevos campos
        fotoContratoUrl: urlContrato,
        fotoCelularUrl: urlCelular,
      );

      // LLAMADA AL BACKEND:
      // await creditoService.crearCredito(credito);

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
              context.go('/home'); // Volver al inicio
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
              const SizedBox(height: 30),

              // --- CAMPOS ---
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
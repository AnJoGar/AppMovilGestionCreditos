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

  // 1. ELIMINAMOS _plazoCtrl y AGREGAMOS variable para el combo
  int? _plazoSeleccionado;
  final List<int> _opcionesCuotas = [3, 6, 9, 12, 15, 18, 24];

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

  @override
  void initState() {
    super.initState();
    _montoCtrl.addListener(_calcularValores);
    _entradaCtrl.addListener(_calcularValores);
    // _plazoCtrl.addListener(_calcularValores); // YA NO ES NECESARIO

    debugPrint("🟠 [NEW CREDIT] usando instancia → hash: ${creditoHomeService.hashCode}");
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _entradaCtrl.dispose();
    // _plazoCtrl.dispose(); // YA NO ES NECESARIO
    super.dispose();
  }

  // --- LÓGICA DE CALCULADORA ---
  void _calcularValores() {
    double monto = double.tryParse(_montoCtrl.text) ?? 0.0;
    double entrada = double.tryParse(_entradaCtrl.text) ?? 0.0;

    // 2. USAMOS EL VALOR DEL COMBO
    int plazo = _plazoSeleccionado ?? 0;

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
    // VALIDAMOS QUE HAYA SELECCIONADO UN PLAZO
    if (_plazoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona el plazo')));
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
        // clienteId: widget.clienteId, // Ajusta si lo necesitas
        montoTotal: double.parse(_montoCtrl.text),
        entrada: _entradaCtrl.text.isEmpty ? 0.0 : double.parse(_entradaCtrl.text),

        // 3. USAMOS EL PLAZO DEL COMBO PARA EL DTO
        plazoCuotas: _plazoSeleccionado!,

        frecuenciaPago: _frecuenciaSeleccionada!,
        valorPorCuota: _valorCuota,
        montoPendiente: _totalPagar,
        diaPago: DateTime.now(),
        proximaCuota: _proximaCuota,
        proximaCuotaStr: DateFormat('yyyy-MM-dd').format(_proximaCuota),
        estado: "Pendiente",
        tiendaId: widget.tiendaId,
        fechaCreacion: DateTime.now().toUtc(),

        // Nuevos campos
        fotoContratoUrl: urlContrato,
        fotoCelularUrl: urlCelular,
      );

      final response = await creditoHomeService.guardarCredito(credito);

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
              context.go('/home', extra: true);
              debugPrint("✅ [NEW CREDIT] Crédito creado, haciendo pop()");
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
                    // 4. CAMBIO: DROPDOWN DE CUOTAS
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
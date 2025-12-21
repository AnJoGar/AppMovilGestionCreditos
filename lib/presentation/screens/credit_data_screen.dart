import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/register_provider.dart';
import '../../models/credito_dto.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/photo_upload_card.dart';
import '../../services/UsuarioRegistroData.dart';
import '../../services/ValidarCuenta.dart';
import '../../services/firebase_service.dart';

class CreditDataScreen extends StatefulWidget {
  const CreditDataScreen({super.key});

  @override
  State<CreditDataScreen> createState() => _CreditDataScreenState();
}

class _CreditDataScreenState extends State<CreditDataScreen> {
  UsuarioRegistroData registroData = UsuarioRegistroData();
  final _precioCtrl = TextEditingController();
  final _entradaCtrl = TextEditingController();
  // final _cuotasCtrl = TextEditingController(); // YA NO SE USA CONTROLADOR DE TEXTO

  String _frecuencia = 'Semanal';
  DateTime _fechaPago = DateTime.now();

  // NUEVO: Variable para el combo de cuotas
  int? _plazoSeleccionado;
  final List<int> _opcionesCuotas = [3, 6, 9, 12, 15, 18, 24];

  double _montoFinanciar = 0;
  double _valorCuota = 0;
  DateTime _proximaCuota = DateTime.now();

  File? _fotoContrato;
  File? _fotoCelular;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _precioCtrl.addListener(_calcularValores);
    _entradaCtrl.addListener(_calcularValores);
  }

  @override
  void dispose() {
    _precioCtrl.dispose(); _entradaCtrl.dispose();
    super.dispose();
  }

  void _calcularValores() {
    final precio = double.tryParse(_precioCtrl.text) ?? 0;
    final entrada = double.tryParse(_entradaCtrl.text) ?? 0;
    // Usamos el valor seleccionado del combo
    final cuotas = _plazoSeleccionado ?? 1;

    setState(() {
      _montoFinanciar = precio - entrada;
      if (_montoFinanciar < 0) _montoFinanciar = 0;
      _valorCuota = (cuotas > 0) ? _montoFinanciar / cuotas : 0;
      _proximaCuota = _calcularProximaFecha(_fechaPago, _frecuencia);
    });
  }

  DateTime _calcularProximaFecha(DateTime fechaBase, String frecuencia) {
    switch (frecuencia) {
      case 'Semanal': return fechaBase.add(const Duration(days: 7));
      case 'Quincenal': return fechaBase.add(const Duration(days: 15));
      case 'Mensual': return DateTime(fechaBase.year, fechaBase.month + 1, fechaBase.day);
      default: return fechaBase.add(const Duration(days: 7));
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context, initialDate: _fechaPago, firstDate: DateTime.now().toUtc(), lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() { _fechaPago = picked; _calcularValores(); });
    }
  }

  void _finalizarRegistro() async {
    if (_precioCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Define el precio')));
      return;
    }
    if (_plazoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona el plazo de cuotas')));
      return;
    }

    if (_fotoContrato == null || _fotoCelular == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes subir fotos de Contrato y Celular'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isUploading = true);

    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final firebaseService = FirebaseService();
      String? urlContrato = await firebaseService.uploadImage(_fotoContrato!, 'contratos');
      String? urlCelular = await firebaseService.uploadImage(_fotoCelular!, 'celulares');

      if (urlContrato == null || urlCelular == null) throw Exception("Error al subir evidencias");

      if (mounted) Navigator.pop(context);

      final credito = CreditoDTO(
        montoTotal: double.parse(_precioCtrl.text),
        entrada: double.tryParse(_entradaCtrl.text) ?? 0,
        plazoCuotas: _plazoSeleccionado!, // Usamos la variable del combo
        frecuenciaPago: _frecuencia,
        diaPago: _fechaPago,
        valorPorCuota: _valorCuota,
        montoPendiente: _montoFinanciar,
        proximaCuota: _proximaCuota,
        proximaCuotaStr: DateFormat('yyyy-MM-dd').format(_proximaCuota),
        estado: 'Pendiente',
        fechaCreacion: DateTime.now().toUtc(),
        fotoContratoUrl: urlContrato,
        fotoCelularUrl: urlCelular,
      );

      final registerProvider = context.read<RegisterProvider>();
      registerProvider.setCredito(credito);

      final usuarioFinal = registerProvider.getUsuarioFinal();
      final correoUser = usuarioFinal.correo;

      if (correoUser == null || correoUser.isEmpty) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Correo no disponible')));
        return;
      }

      final validarCuenta = ValidarCuenta();
      final enviado = await validarCuenta.enviarCodigoCompleto(usuarioFinal);

      setState(() => _isUploading = false);

      if (enviado != null) {
        context.push('/verify-otp', extra: correoUser);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al enviar correo.'), backgroundColor: Colors.red));
      }

    } catch (e) {
      if (mounted) Navigator.pop(context);
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 4: Crédito y Evidencias')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  const Text('Saldo a Financiar', style: TextStyle(color: Colors.white70)),
                  Text('\$${_montoFinanciar.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Cuota: \$${_valorCuota.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                    Text('Prox: ${DateFormat('dd/MM').format(_proximaCuota)}', style: const TextStyle(color: Colors.greenAccent)),
                  ])
                ],
              ),
            ),
            const SizedBox(height: 30),

            CustomTextField(label: 'Precio Equipo (Total)', controller: _precioCtrl, keyboardType: TextInputType.number, icon: Icons.smartphone),
            const SizedBox(height: 15),
            CustomTextField(label: 'Entrada (Pago Inicial)', controller: _entradaCtrl, keyboardType: TextInputType.number, icon: Icons.monetization_on),
            const SizedBox(height: 15),

            // --- CAMBIO: COMBOS DE CUOTAS ---
            DropdownButtonFormField<int>(
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
            ),

            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _frecuencia,
              decoration: InputDecoration(labelText: 'Frecuencia de Pago', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              items: ['Semanal', 'Quincenal', 'Mensual'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
              onChanged: (val) { setState(() { _frecuencia = val!; _calcularValores(); }); },
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Fecha de Inicio / Pago'), subtitle: Text(DateFormat('dd MMMM yyyy').format(_fechaPago)),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withOpacity(0.5))),
              onTap: _seleccionarFecha,
            ),

            const SizedBox(height: 30),
            const Divider(),
            const Text("EVIDENCIA DIGITAL", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: PhotoUploadCard(label: 'Foto Contrato *', onImageSelected: (f) => _fotoContrato = f)),
                const SizedBox(width: 10),
                Expanded(child: PhotoUploadCard(label: 'Foto Celular *', onImageSelected: (f) => _fotoCelular = f)),
              ],
            ),

            const SizedBox(height: 40),
            SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: _finalizarRegistro,
                    child: const Text('FINALIZAR Y VERIFICAR', style: TextStyle(fontSize: 16))
                )
            ),
          ],
        ),
      ),
    );
  }
}
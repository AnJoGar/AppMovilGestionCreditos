import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/register_provider.dart';
import '../../models/credito_dto.dart';
import '../../data/services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/photo_upload_card.dart'; // IMPORTANTE
import '../../services/UsuarioRegistroData.dart';
import '../../models/cliente_dto.dart';
import '../../models/enviar_codigo_dto.dart';
import '../../services/ValidarCuenta.dart';
import '../../services/firebase_service.dart'; // IMPORTANTE

class CreditDataScreen extends StatefulWidget {


  const CreditDataScreen({super.key


  });

  @override
  State<CreditDataScreen> createState() => _CreditDataScreenState();
}

class _CreditDataScreenState extends State<CreditDataScreen> {
  UsuarioRegistroData registroData = UsuarioRegistroData();
  final _precioCtrl = TextEditingController();
  final _entradaCtrl = TextEditingController();
  final _cuotasCtrl = TextEditingController();
  final _marcaCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();
  String _tipoVenta = 'Crédito'; // 🔥 NUEVA VARIABLE
final List<String> _tiposVenta = ['Crédito', 'Contado'];

  // NUEVO: Controlador IMEI
  final _imeiCtrl = TextEditingController();

  bool _esVentaContado = false; // 🔥 NUEVA VARIABLE
String _metodoPago = 'Efectivo'; // Para saber cómo pagó el contado

  // ✅ NUEVO CONTROLADOR PARA CRÉDITO
  final _propietarioCreditoCtrl = TextEditingController();

  String _frecuencia = 'Semanal';
  DateTime _fechaPago = DateTime.now();

  double _montoFinanciar = 0;
  double _valorCuota = 0;
  DateTime _proximaCuota = DateTime.now();

  // NUEVO: Variable para Tipo de Producto
  String _tipoProducto = 'Teléfono';
  final List<String> _tiposProducto = ['Teléfono', 'Televisor'];
  final _capacidadCtrl = TextEditingController();

  // VARIABLES PARA LAS FOTOS
  // File? _fotoContrato; // 📸 COMENTADO
  // File? _fotoCelular;  // 📸 COMENTADO
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _precioCtrl.addListener(_calcularValores);
    _entradaCtrl.addListener(_calcularValores);
    _cuotasCtrl.addListener(_calcularValores);
  }

  // NUEVO: Variable para el combo de cuotas
  int? _plazoSeleccionado;
  final List<int> _opcionesCuotas = [3, 6, 9, 12, 15, 18, 24];


  @override
  void dispose() {
    _precioCtrl.dispose(); _entradaCtrl.dispose(); _cuotasCtrl.dispose();
    _marcaCtrl.dispose();
    _modeloCtrl.dispose();
    _imeiCtrl.dispose(); // Dispose IMEI
    _propietarioCreditoCtrl.dispose();
    _capacidadCtrl.dispose();
    super.dispose();
  }

  void _calcularValores() {


 bool esContado = _tipoVenta == 'Contado';
if (esContado) {

   
    // Si es contado, forzamos valores
    _entradaCtrl.text = _precioCtrl.text;
    _cuotasCtrl.text = '1';
    _frecuencia = 'Mensual'; // Valor por defecto técnico
  }



    final precio = double.tryParse(_precioCtrl.text) ?? 0;
    final entrada = double.tryParse(_entradaCtrl.text) ?? 0;
    final cuotas = int.tryParse(_cuotasCtrl.text) ?? 1;

    setState(() {
      _montoFinanciar = precio - entrada;
      if (_montoFinanciar < 0) _montoFinanciar = 0;
      _valorCuota = (cuotas > 0) ? _montoFinanciar / cuotas : 0;
      _proximaCuota = _calcularProximaFecha(_fechaPago, _frecuencia);

        _esVentaContado = esContado;
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
    if (_precioCtrl.text.isEmpty || _cuotasCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Define precio y cuotas')));
      return;
    }

    // ✅ VALIDAR PROPIETARIO
    if (_propietarioCreditoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El propietario del crédito es requerido'), backgroundColor: Colors.red));
      return;
    }

    // --- VALIDACIÓN DE CUOTAS DINÁMICA ---
    final int cuotasIngresadas = int.tryParse(_cuotasCtrl.text) ?? 0;
    int maxCuotas = 24; // Default Mensual

    if (_frecuencia == 'Semanal') maxCuotas = 52;
    if (_frecuencia == 'Quincenal') maxCuotas = 48;
    if (_frecuencia == 'Mensual') maxCuotas = 24;

    if (cuotasIngresadas > maxCuotas) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Para $_frecuencia el máximo es $maxCuotas cuotas'), backgroundColor: Colors.red)
      );
      return;
    }
    // ------------------------------------

    // VALIDAR IMEI SI ES TELÉFONO
    if (_tipoProducto == 'Teléfono' && _imeiCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El IMEI es requerido para teléfonos'), backgroundColor: Colors.red));
      return;
    }

    // ✅ VALIDAR CAPACIDAD SI ES TELÉFONO (Opcional, o siempre)
    if (_capacidadCtrl.text.isNotEmpty) {
      final cap = int.tryParse(_capacidadCtrl.text);
      if (cap == null || cap > 1000) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La capacidad máxima es 1000 GB'), backgroundColor: Colors.red));
        return;
      }
    }

    // ------------------------------------

    /* 📸 VALIDACIÓN DE FOTOS COMENTADA
    // 1. VALIDAR FOTOS
    if (_fotoContrato == null || _fotoCelular == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes subir fotos de Contrato y Celular'), backgroundColor: Colors.red));
      return;
    }
    */

    // Guardar crédito en Provider

    setState(() => _isUploading = true);

    // Dialogo de Carga
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                // ✅ CAMBIO: TEXTO SOLICITADO
                Text("Procesando solicitud...", style: TextStyle(fontWeight: FontWeight.bold))
              ]
          ),
        ),
      ),
    );

    try {
      // final firebaseService = FirebaseService(); // 📸 COMENTADO

      // 2. SUBIR EVIDENCIAS
      // String? urlContrato = await firebaseService.uploadImage(_fotoContrato!, 'contratos'); // 📸 COMENTADO
      // String? urlCelular = await firebaseService.uploadImage(_fotoCelular!, 'celulares');   // 📸 COMENTADO

      /* 📸 VALIDACIÓN URL COMENTADA
      if (urlContrato == null || urlCelular == null) throw Exception("Error al subir evidencias");
      */

      // ⚠️ ELIMINADO: if (mounted) Navigator.pop(context); (ESTO CERRABA EL DIALOGO MUY RÁPIDO)

      // 3. CREAR DTO
      final credito = CreditoDTO(

        esVentaContado: _esVentaContado, // 🔥 CAMPO NUEVO
  metodoPago: _esVentaContado ? 'Al Contado' : 'Efectivo', // 🔥 CAMPO NUEVO
        montoTotal: double.parse(_precioCtrl.text),
        entrada: double.tryParse(_entradaCtrl.text) ?? 0,
        plazoCuotas: int.parse(_cuotasCtrl.text) ,//_plazoSeleccionado!,
        frecuenciaPago: _frecuencia,
        diaPago: _fechaPago,
        valorPorCuota: _valorCuota,
        montoPendiente: _montoFinanciar,
        proximaCuota: _proximaCuota,
        proximaCuotaStr: DateFormat('yyyy-MM-dd').format(_proximaCuota),
        estado: 'Pendiente',
        fechaCreacion: DateTime.now().toUtc(),
        marca: _marcaCtrl.text,
        modelo: _modeloCtrl.text,
        estadoCuota: "Pendiente",
        abonadoTotal: 0.0,
        // ASIGNAMOS LAS URLS
        fotoContratoUrl: null, // urlContrato, // 📸 URL COMENTADA
        fotoCelularUrl: null,  // urlCelular,  // 📸 URL COMENTADA

        // NUEVOS CAMPOS PRODUCTO
        tipoProducto: _tipoProducto,
        imei: (_tipoProducto == 'Teléfono') ? _imeiCtrl.text : null,
        // ✅ ASIGNACIÓN AL DTO
        nombrePropietario: _propietarioCreditoCtrl.text,
        capacidad: int.tryParse(_capacidadCtrl.text),
      );

      final registerProvider = context.read<RegisterProvider>();
      registerProvider.setCredito(credito);

      // 4. ENVIAR CODIGO DE VERIFICACIÓN
      final usuarioFinal = registerProvider.getUsuarioFinal();
      final correoUser = usuarioFinal.correo;

      if (correoUser == null || correoUser.isEmpty) {
        if (mounted) Navigator.pop(context); // CERRAR SI HAY ERROR
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Correo no disponible')));
        return;
      }

      final validarCuenta = ValidarCuenta();
      // ESTO TARDARÁ UNOS SEGUNDOS Y EL DIÁLOGO SEGUIRÁ ABIERTO
      final enviado = await validarCuenta.enviarCodigoCompleto(usuarioFinal);

      // ✅ CAMBIO: AHORA SÍ CERRAMOS EL DIALOGO, JUSTO ANTES DE CAMBIAR DE PANTALLA
      if (mounted) Navigator.pop(context);

      setState(() => _isUploading = false);

      if (enviado != null) {
        context.push('/verify-otp', extra: correoUser);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al enviar correo.'), backgroundColor: Colors.red));
      }

    } catch (e) {
      if (mounted) Navigator.pop(context); // CERRAR SI HAY EXCEPCIÓN
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  // ----------------------------------------------------------------------
  // 🟢 WIDGET CALCULADORA VISUAL
  // ----------------------------------------------------------------------
  Widget _buildCalculatorVisualizer(ThemeData theme) {
    if (_montoFinanciar <= 0) return const SizedBox.shrink();

    final TextStyle valueStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.primaryColor);
    final TextStyle labelStyle = TextStyle(fontSize: 12, color: Colors.grey[600]);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calculate, size: 20, color: Colors.grey),
              const SizedBox(width: 5),
              Text("Desglose del Cálculo", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
            ],
          ),
          const SizedBox(height: 15),
          // OPERACIÓN 1: RESTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(children: [Text("\$${_precioCtrl.text}", style: valueStyle), Text("Precio", style: labelStyle)]),
              const Icon(Icons.remove_circle_outline, size: 20, color: Colors.redAccent),
              Column(children: [Text("\$${_entradaCtrl.text.isEmpty ? '0' : _entradaCtrl.text}", style: valueStyle), Text("Entrada", style: labelStyle)]),
              const Icon(Icons.drag_handle, size: 20, color: Colors.grey), // Igual
              Column(children: [Text("\$${_montoFinanciar.toStringAsFixed(2)}", style: valueStyle), Text("A Financiar", style: labelStyle)]),
            ],
          ),
          const Divider(height: 25),
          // OPERACIÓN 2: DIVISIÓN
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(children: [Text("\$${_montoFinanciar.toStringAsFixed(2)}", style: valueStyle), Text("Saldo", style: labelStyle)]),
              const Icon(Icons.percent, size: 20, color: Colors.orangeAccent), // División visual
              Column(children: [Text(_cuotasCtrl.text.isEmpty ? '1' : _cuotasCtrl.text, style: valueStyle), Text("Pagos ($_frecuencia)", style: labelStyle)]),
              const Icon(Icons.arrow_right_alt, size: 30, color: Colors.green), // Flecha resultado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(8)),
                child: Column(children: [Text("\$${_valorCuota.toStringAsFixed(2)}", style: valueStyle.copyWith(color: Colors.green[800])), Text("Cuota Final", style: labelStyle)]),
              ),
            ],
          ),
        ],
      ),
    );
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
          // --- RESUMEN ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // 🔥 Cambiar color según tipo de venta
              color: _tipoVenta == 'Contado' ? Colors.green : theme.primaryColor,
              borderRadius: BorderRadius.circular(15)
            ),
            child: Column(
              children: [
                // 🔥 Título condicional mejorado
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _tipoVenta == 'Contado' ? Icons.payments : Icons.credit_card,
                      color: Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _tipoVenta == 'Contado' ? 'VENTA AL CONTADO' : 'VENTA A CRÉDITO',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _tipoVenta == 'Contado' ? 'Monto Total' : 'Saldo a Financiar',
                  style: const TextStyle(color: Colors.white70, fontSize: 14)
                ),
                Text(
                  '\$${_tipoVenta == 'Contado' ? (_precioCtrl.text.isEmpty ? '0.00' : _precioCtrl.text) : _montoFinanciar.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)
                ),
                
                // 🔥 Solo mostrar detalles si es Crédito
                if (_tipoVenta == 'Crédito') ...[
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Cuota: \$${_valorCuota.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                      Text('Prox: ${DateFormat('dd/MM').format(_proximaCuota)}', style: const TextStyle(color: Colors.greenAccent)),
                    ]
                  )
                ] else ...[
                  // Si es contado, mostrar mensaje
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text('Pago Completo', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ✅ CAMPO PROPIETARIO CREDITO
          CustomTextField(
            label: 'Propietario del Crédito',
            controller: _propietarioCreditoCtrl,
            icon: Icons.person_pin,
            validator: (v) => v!.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 15),

          // --- TIPO PRODUCTO Y MARCA ---
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Tipo Producto', border: OutlineInputBorder()),
                  value: _tipoProducto,
                  items: _tiposProducto.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) {
                    setState(() => _tipoProducto = val!);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: CustomTextField(label: 'Marca', controller: _marcaCtrl, icon: Icons.branding_watermark)),
            ],
          ),
          const SizedBox(height: 15),

          // --- MODELO y CAPACIDAD ---
          Row(
            children: [
              Expanded(flex: 2, child: CustomTextField(label: 'Modelo', controller: _modeloCtrl, icon: Icons.devices)),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: CustomTextField(
                  label: 'Cap.',
                  controller: _capacidadCtrl,
                  keyboardType: TextInputType.number,
                  suffixText: 'GB',
                  validator: (v) {
                    if (v != null && v.isNotEmpty) {
                      final n = int.tryParse(v);
                      if (n == null || n > 2000) return 'Max 1TB';
                    }
                    return null;
                  },
                )
              ),
            ],
          ),

          // --- IMEI (Si es teléfono) ---
          if (_tipoProducto == 'Teléfono') ...[
            const SizedBox(height: 15),
            CustomTextField(label: 'IMEI', controller: _imeiCtrl, icon: Icons.qr_code),
          ],

          const SizedBox(height: 15),

          // 🔥 REEMPLAZAR EL SWITCH POR UN DROPDOWN
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _tipoVenta == 'Contado' 
                    ? [Colors.green.shade50, Colors.green.shade100]
                    : [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _tipoVenta == 'Contado' ? Colors.green : Colors.blue,
                width: 2
              ),
            ),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Tipo de Venta',
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _tipoVenta == 'Contado' ? Colors.green.shade800 : Colors.blue.shade800
                ),
                prefixIcon: Icon(
                  _tipoVenta == 'Contado' ? Icons.flash_on : Icons.credit_card,
                  color: _tipoVenta == 'Contado' ? Colors.green : Colors.blue,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              value: _tipoVenta,
              items: _tiposVenta.map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Row(
                    children: [
                      Icon(
                        tipo == 'Contado' ? Icons.payments : Icons.credit_card,
                        size: 20,
                        color: tipo == 'Contado' ? Colors.green : Colors.blue,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        tipo == 'Contado' ? 'Venta al Contado' : 'Venta a Crédito',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: tipo == 'Contado' ? Colors.green.shade800 : Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _tipoVenta = val!;
                  if (_tipoVenta == 'Contado') {
                    _cuotasCtrl.text = '1';
                    if (_precioCtrl.text.isNotEmpty) {
                      _entradaCtrl.text = _precioCtrl.text;
                    }
                    _frecuencia = 'Mensual';
                  } else {
                    _entradaCtrl.clear();
                    _cuotasCtrl.text = '3';
                  }
                  _calcularValores();
                });
              },
            ),
          ),
          const SizedBox(height: 15),

          // --- PRECIO EQUIPO (SIEMPRE VISIBLE) ---
          CustomTextField(
            label: 'Precio Equipo (Total)',
            controller: _precioCtrl,
            keyboardType: TextInputType.number,
            icon: Icons.monetization_on_outlined
          ),
          const SizedBox(height: 15),

          // 🔥 CAMPOS OCULTOS SI ES CONTADO
          if (_tipoVenta == 'Crédito') ...[
            // ENTRADA
            CustomTextField(
              label: 'Entrada (Pago Inicial)',
              controller: _entradaCtrl,
              keyboardType: TextInputType.number,
              icon: Icons.monetization_on
            ),
            const SizedBox(height: 15),

            // PLAZO
            CustomTextField(
              label: 'Plazo (Cuotas)',
              controller: _cuotasCtrl,
              keyboardType: TextInputType.number,
              icon: Icons.calendar_view_week
            ),
            const SizedBox(height: 20),

            // FRECUENCIA
            DropdownButtonFormField<String>(
              value: _frecuencia,
              decoration: InputDecoration(
                labelText: 'Frecuencia de Pago',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
              ),
              items: ['Semanal', 'Quincenal', 'Mensual']
                  .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _frecuencia = val!;
                  _calcularValores();
                });
              },
            ),
            const SizedBox(height: 20),

            // FECHA DE INICIO
            ListTile(
              title: const Text('Fecha de Inicio / Pago'),
              subtitle: Text(DateFormat('dd MMMM yyyy').format(_fechaPago)),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.withOpacity(0.5))
              ),
              onTap: _seleccionarFecha,
            ),

            // CALCULADORA VISUAL
            _buildCalculatorVisualizer(theme),
          ],

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _tipoVenta == 'Contado' ? Colors.green : Colors.blue
              ),
              onPressed: _finalizarRegistro,
              child: Text(
                _tipoVenta == 'Contado' ? 'REGISTRAR VENTA AL CONTADO' : 'FINALIZAR Y VERIFICAR',
                style: const TextStyle(fontSize: 16, color: Colors.white)
              )
            )
          ),
        ],
      ),
    ),
  );
}
}
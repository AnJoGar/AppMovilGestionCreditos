import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/register_provider.dart';
import '../../models/detalle_cliente_dto.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/photo_upload_card.dart';
import '../../services/UsuarioRegistroData.dart';
import '../../services/firebase_service.dart';
import '../../models/cliente_dto.dart';

class ClientDataScreen extends StatefulWidget {
  const ClientDataScreen({super.key});

  @override
  State<ClientDataScreen> createState() => _ClientDataScreenState();
}

class _ClientDataScreenState extends State<ClientDataScreen> {
  bool _isUploading = false;
  UsuarioRegistroData registroData = UsuarioRegistroData();
  final _formKey = GlobalKey<FormState>();
  final _cedulaCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();

  File? _fotoCliente;
  // SE ELIMINARON: _fotoCelular y _fotoContrato de esta pantalla

  @override
  void initState() {
    super.initState();
    final nombreRegistrado = context.read<RegisterProvider>().usuario.nombreApellidos;
    _nombreCtrl.text = nombreRegistrado ?? '';
  }

  @override
  void dispose() {
    _cedulaCtrl.dispose(); _nombreCtrl.dispose(); _telefonoCtrl.dispose(); _direccionCtrl.dispose();
    super.dispose();
  }

  void _onNextPressed() async {
    // 1. Validar Inputs
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Validar Foto Cliente (Única obligatoria aquí)
    if (_fotoCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debes subir la foto del Cliente (Selfie)'),
            backgroundColor: Colors.red
        ),
      );
      return;
    }

    // 3. Mostrar diálogo de carga
    setState(() => _isUploading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                  "Subiendo foto de perfil...",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final firebaseService = FirebaseService();

      // 4. Subir SOLO foto cliente
      final String? urlCliente = await firebaseService.uploadImage(_fotoCliente!, 'clientes');

      // Cerrar diálogo
      if (mounted) Navigator.pop(context);
      setState(() => _isUploading = false);

      if (urlCliente == null) {
        throw Exception("Error al subir la imagen.");
      }

      // 5. Crear DTO Limpio
      final detalle = DetalleClienteDTO(
        numeroCedula: _cedulaCtrl.text,
        nombreApellidos: _nombreCtrl.text,
        telefono: _telefonoCtrl.text,
        direccion: _direccionCtrl.text,
        fotoClienteUrl: urlCliente,
        // fotoCelularEntregadoUrl y fotoContrato ya no van aquí
      );

      // 6. Guardar en Provider
      final registerProvider = context.read<RegisterProvider>();
      registerProvider.setDetalleCliente(detalle);

      // 7. Guardar local
      registroData.cliente ??= ClienteDTO();
      registroData.cliente!.detalleCliente = detalle;

      // 8. Navegar
      if (mounted) context.push('/store-data');

    } catch (e) {
      if (mounted) Navigator.pop(context);
      setState(() => _isUploading = false);
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 2: Datos Cliente'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Información Personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 15),
              CustomTextField(
                label: 'Número de Cédula', controller: _cedulaCtrl, keyboardType: TextInputType.number,
                validator: (v) => (v!.isEmpty || v.length != 10) ? 'Debe tener 10 dígitos' : null,
              ),
              const SizedBox(height: 15),
              CustomTextField(label: 'Nombres y Apellidos', controller: _nombreCtrl, icon: Icons.person, validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 15),
              CustomTextField(label: 'Teléfono', controller: _telefonoCtrl, keyboardType: TextInputType.phone, icon: Icons.phone, validator: (v) => (v!.isEmpty || v.length != 10) ? '10 dígitos' : null),
              const SizedBox(height: 15),
              CustomTextField(label: 'Dirección / Sector', controller: _direccionCtrl, icon: Icons.location_on, validator: (v) => v!.isEmpty ? 'Requerido' : null),

              const SizedBox(height: 30),
              const Text('Evidencia de Identidad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 15),

              // SOLO WIDGET DE FOTO CLIENTE
              Center(
                child: SizedBox(
                  width: 200,
                  child: PhotoUploadCard(label: 'Foto del cliente', onImageSelected: (f) => _fotoCliente = f),
                ),
              ),

              const SizedBox(height: 40),
              SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _onNextPressed, child: const Text('SIGUIENTE: DATOS TIENDA'))),
            ],
          ),
        ),
      ),
    );
  }
}
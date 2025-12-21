import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../providers/register_provider.dart';
import '../../../models/detalle_cliente_dto.dart';
import '../../../presentation/widgets/custom_text_field.dart';
import '../../../presentation/widgets/photo_upload_card.dart';
import '../../../services/firebase_service.dart';
import '../../../services/usuario_service.dart';

import '../../../models/DetalleCLientePostDTO.dart';
class ClientUpdateScreen extends StatefulWidget {
  //final int clienteId;
  const ClientUpdateScreen({super.key, /*required this.clienteId*/});

  @override
  State<ClientUpdateScreen> createState() => _ClientUpdateScreenState();
}

class _ClientUpdateScreenState extends State<ClientUpdateScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de Texto
  final _cedulaCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();

  // SOLO FOTO CLIENTE
  File? _fotoCliente;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<RegisterProvider>().usuario;
    _nombreCtrl.text = user.nombreApellidos ?? '';
  }

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  void _actualizarDatos() async {
    if (!_formKey.currentState!.validate()) return;

    // VALIDACIÓN SOLO FOTO CLIENTE
    if (_fotoCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Debes subir tu Foto (Selfie) actualizada'),
          backgroundColor: Colors.orange
      ));
      return;
    }

    setState(() => _isLoading = true);

    // Diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
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
              Text("Actualizando foto de perfil...", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );

    try {
      final firebaseService = FirebaseService();

      // 1. SUBIR FOTOS (Simulado o Real)
      // Descomenta las líneas reales cuando tengas el bucket listo
       String? urlCliente = await firebaseService.uploadImage(_fotoCliente!, 'clientes');
      //String? urlCelular = await firebaseService.uploadImage(_fotoCelular!, 'celulares');
      //String? urlContrato = await firebaseService.uploadImage(_fotoContrato!, 'contratos');

      // Simulación de delay
      await Future.delayed(const Duration(seconds: 2));



      if (mounted) Navigator.pop(context); // Cerrar diálogo

      // 2. CREAR DTO DETALLE CLIENTE
     
      // 1. SUBIR SOLO FOTO CLIENTE
      // String? urlCliente = await firebaseService.uploadImage(_fotoCliente!, 'clientes');

      // Simulación de delay
      await Future.delayed(const Duration(seconds: 2));
     

     // if (mounted) Navigator.pop(context); // Cerrar diálogo

      // 2. CREAR DTO DETALLE CLIENTE LIMPIO
      final detalleUpdate = DetalleClientePostDTO(
        numeroCedula: _cedulaCtrl.text,
        nombreApellidos: _nombreCtrl.text,
        telefono: _telefonoCtrl.text,
        direccion: _direccionCtrl.text,
        fotoClienteUrl: urlCliente,
      );
      final usuarioService = UsuarioService();

    await usuarioService.actualizarDetalleClienteFotos(detalleUpdate);
      // 3. LLAMADA AL BACKEND (PUT /Cliente/{id})
      // await clienteService.actualizarDetalles(widget.clienteId, detalleUpdate);

      if (mounted) {
        setState(() => _isLoading = false);
        // Avanzamos al Paso 2: Datos de Tienda
        context.push('/new-credit-store', /*extra: widget.clienteId*/);
        // Avanzamos al Paso 2
      //  context.push('/new-credit-store', extra: widget.clienteId);
      }

    } catch (e) {
      if (mounted) Navigator.pop(context);
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar datos')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 1: Validar Datos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(child: const Text('Información Personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey))),
              const SizedBox(height: 20),

              CustomTextField(label: 'Cédula', controller: _cedulaCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 15),
              CustomTextField(label: 'Nombre Completo', controller: _nombreCtrl, icon: Icons.person),
              const SizedBox(height: 15),
              CustomTextField(label: 'Teléfono', controller: _telefonoCtrl, keyboardType: TextInputType.phone, icon: Icons.phone),
              const SizedBox(height: 15),
              CustomTextField(label: 'Dirección', controller: _direccionCtrl, icon: Icons.location_on),

              const SizedBox(height: 30),
              FadeInDown(child: const Text('Evidencia de Identidad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey))),
              const SizedBox(height: 15),

              // --- SOLO FOTO CLIENTE ---
              Center(
                child: SizedBox(
                  width: 200,
                  child: PhotoUploadCard(label: 'Foto Cliente (Selfie) *', onImageSelected: (f) => _fotoCliente = f),
                ),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _actualizarDatos,
                  child: const Text('SIGUIENTE: DATOS TIENDA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
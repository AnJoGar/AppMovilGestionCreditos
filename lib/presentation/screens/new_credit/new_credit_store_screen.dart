import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../../models/tienda_crear_dto.dart';
import '../../../presentation/widgets/custom_text_field.dart';
import '../../../services/tiendaService.dart';


class NewCreditStoreScreen extends StatefulWidget {
  //final int tiendaId;
  //final int clienteId;
  const NewCreditStoreScreen({super.key,/* required this.tiendaId*/});

  @override
  State<NewCreditStoreScreen> createState() => _NewCreditStoreScreenState();
}

class _NewCreditStoreScreenState extends State<NewCreditStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreTiendaCtrl = TextEditingController();
  final _codigoTiendaCtrl = TextEditingController();
  final _encargadoCtrl = TextEditingController();
  final _telefonoTiendaCtrl = TextEditingController();
  final _direccionTiendaCtrl = TextEditingController();

  bool _isLoading = false;

  void _guardarTienda() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // 1. Crear DTO Tienda
    final tienda = TiendaCrearDTO(
      nombreTienda: _nombreTiendaCtrl.text,
      //codigoTienda: _codigoTiendaCtrl.text,
      nombreEncargado: _encargadoCtrl.text,
      telefono: _telefonoTiendaCtrl.text,
      direccion: _direccionTiendaCtrl.text,

    );
    final tiendaServicio = tiendaService();

    final tiendaCreada = await tiendaServicio.GuardarTienda(tienda);
    // 2. LLAMADA AL BACKEND (POST /Tienda)
    // int tiendaId = await tiendaService.crearTienda(tienda);
    await Future.delayed(const Duration(seconds: 1)); // Simulación

    // Suponemos que el backend devuelve el ID de la tienda creada o que se asocia internamente
    int mockTiendaId = 99;

    if (mounted) {
      setState(() => _isLoading = false);
      // Avanzar al paso final: CRÉDITO + CALCULADORA
      // Pasamos clienteId y tiendaId (mapa de argumentos)
      context.push('/new-credit-financial',
        extra: tiendaCreada.id,
        /*, extra: {'clienteId': widget.clienteId, 'tiendaId': mockTiendaId}*/);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 2: Datos de Compra')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInLeft(child: const Text('¿Dónde estás comprando el equipo?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              const SizedBox(height: 20),

              CustomTextField(label: 'Nombre de la Tienda', controller: _nombreTiendaCtrl, icon: Icons.store),
              const SizedBox(height: 15),
              CustomTextField(label: 'Código de Tienda (QR)', controller: _codigoTiendaCtrl, icon: Icons.qr_code),
              const SizedBox(height: 15),
              CustomTextField(label: 'Nombre Vendedor', controller: _encargadoCtrl, icon: Icons.person_pin),
              const SizedBox(height: 15),
              CustomTextField(label: 'Teléfono Tienda', controller: _telefonoTiendaCtrl, keyboardType: TextInputType.phone, icon: Icons.phone),
              const SizedBox(height: 15),
              CustomTextField(label: 'Dirección Tienda', controller: _direccionTiendaCtrl, icon: Icons.map),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardarTienda,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('CONTINUAR A COTIZACIÓN'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../models/credito_dto.dart';
import '../../models/tienda_dto.dart';
import '../../models/CreditoMostrarDTO.dart';
import '../widgets/credit_summary_card.dart';
import '../widgets/side_menu.dart';
import '../../services/creditoMostrarHome.dart';
import '../../services/tiendaService.dart';
import '../../models/tiendaMostrar_dto.dart';
import '../../services/usuario_service.dart';
import '../../models/ClienteMostrarDTO.dart';
import '../../services/location_service.dart';
import 'new_credit_request_screen.dart';

import '../../services/notificacion_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // DATOS FICTICIOS PARA MAQUETACIÓN (MOCKS)
  // Luego esto vendrá de tu API con un FutureBuilder o Provider
  final creditoMostrarHome _creditoService = creditoMostrarHome();
  late Future<List<CreditoMostrarDTO>> _futureCreditos;
  late Future<void> _futureCreditos1;
  final tiendaService _tiendaService = tiendaService();
  late Future<List<tiendaMostrar_dto>> _Tiendas;
  final UsuarioService _clienteService = UsuarioService();
  late Future<ClienteMostrarDTO> _futureClientes;
  CreditoMostrarDTO? creditoActual;
  final LocationService _locationService = LocationService();

  //final String _nombreUsuario = "aszcsz";
  final String _emailUsuario = "luis@ejemplo.com";

  final TiendaDTO _tiendaMock = TiendaDTO(
    nombreTienda: "Celulares El Centro",
    nombreEncargado: "Luis",
    telefono: "0999999999",
    direccion: "Av. Principal 123",
    //  fechaRegistro: DateTime.now(),
  );
  // final creditoServicio = creditoMostrarHome();
  int _cantidadNotificaciones = 0;
  @override
  void initState() {
    super.initState();
    debugPrint("🔵 [HOME] usando instancia → hash: ${_creditoService.hashCode}");

    _Tiendas = _tiendaService.getTienda();
    _futureClientes = _clienteService.getCliente();

    debugPrint("🏠 [HOME] carga inicial créditos");
    _futureCreditos1 = _creditoService.getCreditos(); // carga inicial
    _creditoService.connectSignalR();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = GoRouterState.of(context);
      debugPrint("🏠 [HOME] extra recibido: ${state.extra}");
      if (state.extra == true) {
        debugPrint("🏠 [HOME] FORZANDO REFRESH DE CRÉDITOS");
        _creditoService.cargarCreditos();
      }
    });
    _futureCreditos1 = _creditoService.getCreditos(); // carga inicial
    _creditoService.connectSignalR();

    // 🔴 CARGAR NOTIFICACIONES AL INICIO
    _cargarNotificaciones();

    // 3. EJECUTAR RASTREO EN SEGUNDO PLANO (Sin await para no bloquear la UI)
    _locationService.sendCurrentLocation();
  }

// 🔴 FUNCIÓN NUEVA: Obtiene el conteo del servicio
  Future<void> _cargarNotificaciones() async {
    try {
      final lista = await NotificacionService().getNotificaciones();
      if (mounted) {
        setState(() {
          // Como el endpoint es 'pendientesNotApp', el total de la lista es el número a mostrar
          _cantidadNotificaciones = lista.length;
        });
      }
    } catch (e) {
      print("Error cargando notificaciones badge: $e");
    }
  }

  Future<void> _initCreditoFlow() async {
    await _creditoService.connectSignalR(); // ⏳ esperar conexión
    //_futureCreditos = _creditoService.getCreditos();
    _futureCreditos1 = _creditoService.getCreditos();
  }


  Future<void> _refreshCreditos() async {
    _futureCreditos1 = _creditoService.getCreditos();
    await _futureCreditos1;
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: theme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Badge(
              // Solo mostramos el globito si hay notificaciones
              isLabelVisible: _cantidadNotificaciones > 0,
              // El número
              label: Text('$_cantidadNotificaciones'),
              // Color del globito (opcional, por defecto es rojo theme)
              backgroundColor: Colors.red,
              // El ícono de siempre
              child: const Icon(Icons.notifications_none),
            ),
            onPressed: () async {
              // Navegamos y esperamos a que el usuario vuelva
              await context.push('/notifications');

              // Al volver, recargamos el contador (por si leyó alguna)
              _cargarNotificaciones();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sin notificaciones nuevas')),
              );
              context.push('/notifications');
            },
          ),
        ],
      ),
      drawer: //SideMenu(userName: _nombreUsuario, userEmail: _emailUsuario),
      FutureBuilder<ClienteMostrarDTO>(
        future: _futureClientes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Drawer(); // Drawer vacío mientras carga
          }

          if (snapshot.hasError) {
            return Drawer(
              child: Center(child: Text('Error: ${snapshot.error}')),
            );
          }

          final usuario = snapshot.data!;
          return SideMenu(
            userName: usuario.nombreApellidos,
            userEmail: usuario.correo,
          );
        },
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<ClienteMostrarDTO>(
              future: _futureClientes,
              builder: (context, snapshot) {
                // Verifica el estado de la conexión
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData) {
                  return const Text('No se encontraron datos del usuario');
                }

                String saludo = 'Hola, usuario';
                if (snapshot.hasData) {
                  saludo = 'Hola, ${snapshot.data!.nombreApellidos}';
                }
                return FadeInDown(
                  child: Text(
                    saludo,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),


            const SizedBox(height: 5),
            FadeInDown(
              child: Text(
                'Aquí está el resumen de tu crédito',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),

            const SizedBox(height: 20),


            ValueListenableBuilder<List<CreditoMostrarDTO>?>(
              valueListenable: _creditoService.creditosNotifier,
              builder: (context, creditos, _) {
                // Cargando
                if (creditos == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 🔥 CASO: NO TIENE CRÉDITOS → PUEDE SOLICITAR
                if (creditos.isEmpty) {
                  return Column(
                    children: [
                      const Text('No tienes créditos activos.'),
                      const SizedBox(height: 20),
                      _NewCreditRequestCard(
                        isPaid:
                        true, // Si no hay créditos, se asume que puede solicitar
                        onTap: () async {
                          context.push('/new-credit-request');
                          // await _refreshCreditos();
                        },
                      ),
                    ],
                  );
                }

                // 🔹 CASO: TIENE CRÉDITO
                final credito = creditos.first;

                final bool estaPagado = credito.montoPendiente <= 0;

                return Column(
                  children: [
                    CreditSummaryCard(credito: credito),
                    const SizedBox(height: 20),
                    _NewCreditRequestCard(
                      isPaid: estaPagado,

                      onTap: () async {
                        //  context.push('/new-credit-request');
                        await context.push('/new-credit-request');
                        await _refreshCreditos();
                      },


                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            // 3. Sección Tienda
            FadeInUp(
              child: Text(
                'Mi Tienda',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: FutureBuilder<List<tiendaMostrar_dto>>(
                future: _Tiendas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print("🔥 ERROR TIENDAS:");
                    print(snapshot.error);
                    print(snapshot.stackTrace);

                    return const Text(
                      'Error al cargar tienda',
                      style: TextStyle(color: Colors.red),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No hay tienda registrada');
                  }

                  final tienda = snapshot.data!.last;

                  return Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.store, color: Colors.orange),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tienda.nombreEncargado,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tienda.telefono,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),


            // 4. Accesos Rápidos (Opcional pero útil)
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _QuickActionBtn(
                    icon: Icons.receipt_long,
                    label: 'Historial',
                    color: Colors.blue,
                    onTap: () {},
                  ),
                  _QuickActionBtn(
                    icon: Icons.support_agent,
                    label: 'Soporte',
                    color: Colors.purple,
                    onTap: () {},
                  ),
                  _QuickActionBtn(
                    icon: Icons.qr_code,
                    label: 'Mi QR',
                    color: Colors.teal,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget auxiliar para botones rápidos
class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewCreditRequestCard extends StatelessWidget {
  final bool isPaid;
  final VoidCallback onTap;

  const _NewCreditRequestCard({required this.isPaid, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = isPaid ? theme.primaryColor : Colors.grey.shade300;
    final textColor = isPaid ? Colors.white : Colors.grey.shade600;
    final iconColor = isPaid ? Colors.white : Colors.grey.shade500;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isPaid ? onTap : null,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: isPaid
                ? [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isPaid ? 0.2 : 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_card_rounded, color: iconColor, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solicitar Nuevo Crédito',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isPaid
                          ? '¡Estás listo para renovar tu equipo!'
                          : 'Termina de pagar tu crédito actual para desbloquear.',
                      style: TextStyle(
                        color: textColor.withOpacity(isPaid ? 0.9 : 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPaid)
                Icon(Icons.arrow_forward_ios, color: textColor, size: 18)
              else
                Icon(Icons.lock_outline, color: iconColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
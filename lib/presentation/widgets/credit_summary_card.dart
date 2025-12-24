/*

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trabajo1/models/CreditoMostrarDTO.dart';
import '../../models/credito_dto.dart';

class CreditSummaryCard extends StatelessWidget {
  final CreditoMostrarDTO credito;

  const CreditSummaryCard({super.key, required this.credito});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final double totalCredito =
    credito.plazoCuotas * credito.valorPorCuota;

final double montoPagado =
    totalCredito - credito.montoPendiente;

final int cuotasPagadas =
    (montoPagado / credito.valorPorCuota).floor();

double progreso = cuotasPagadas / credito.plazoCuotas;

progreso = progreso.clamp(0.0, 1.0);

    final proximaCuotaStr = credito.proximaCuotaStr ?? "No definido";
        //? dateFormat.format(credito.proximaCuotaStr!)
        //: 'No definido';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, const Color(0xFF283593)], // Azul degradado
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Próximo Pago',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    credito.estado ?? 'ACTIVO',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              currencyFormat.format(credito.valorPorCuota),
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Vence el: $proximaCuotaStr',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Barra de Progreso
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: ${currencyFormat.format(credito.montoPendiente)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const Text('Progreso de pago', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progreso,
                backgroundColor: Colors.black26,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00BFA5)), // Verde menta
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


 */


/*
import 'package:flutter/material.dart';
import '../../models/CreditoMostrarDTO.dart'; // Asegúrate que apunte al modelo actualizado

class CreditSummaryCard extends StatelessWidget {
  final CreditoMostrarDTO credito;

  const CreditSummaryCard({super.key, required this.credito});

  @override
  Widget build(BuildContext context) {
    // Calculamos porcentaje pagado para una barra de progreso visual (opcional)
    // Asumimos que montoTotal = montoPendiente + abonadoTotal (aprox para visualización)
    double totalEstimado = credito.montoPendiente + credito.abonadoTotal;
    double progreso = totalEstimado > 0 ? (credito.abonadoTotal / totalEstimado) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Cabecera: Dispositivo y Estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dispositivo', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    '${credito.marca} ${credito.modelo}',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  credito.estado,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),

          const SizedBox(height: 20),

          // 2. Información Financiera Principal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoColumn(
                label: 'Próxima Cuota',
                value: credito.proximaCuotaStr,
                icon: Icons.calendar_today,
              ),
              _InfoColumn(
                label: 'Valor Cuota',
                value: '\$${credito.valorPorCuota.toStringAsFixed(2)}',
                icon: Icons.attach_money,
              ),
            ],
          ),

          const SizedBox(height: 15),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),

          // 3. Nuevos Campos: Abonado y Estado Cuota
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Abonado', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    '\$${credito.abonadoTotal.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Estado Cuota', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    credito.estadoCuota,
                    style: TextStyle(
                        color: _getColorEstadoCuota(credito.estadoCuota),
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),
          // Barra de progreso de pago
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: progreso,
              backgroundColor: Colors.black12,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorEstadoCuota(String estado) {
    if (estado.toLowerCase().contains('venci')) return Colors.redAccent;
    if (estado.toLowerCase().contains('pagad')) return Colors.greenAccent;
    return Colors.orangeAccent; // Pendiente o Al día
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoColumn({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ],
    );
  }
}

 */

import 'package:flutter/material.dart';
import '../../models/CreditoMostrarDTO.dart';

class CreditSummaryCard extends StatelessWidget {
  final CreditoMostrarDTO credito;

  const CreditSummaryCard({super.key, required this.credito});

  @override
  Widget build(BuildContext context) {
    // Cálculo visual de progreso (Monto Total estimado = Pendiente + Abonado)
    final double totalEstimado = credito.montoPendiente + credito.abonadoTotal;
    final double porcentajePagado = totalEstimado > 0
        ? (credito.abonadoTotal / totalEstimado).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Gradiente elegante para destacar la tarjeta
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. CABECERA: Marca/Modelo y Estado General
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TU DISPOSITIVO', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 2),
                    Text(
                      '${credito.marca} ${credito.modelo}',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _EstadoBadge(estado: credito.estado),
            ],
          ),

          const SizedBox(height: 20),

          // 2. DATOS PRINCIPALES: Cuota y Vencimiento
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoItem(
                label: 'Valor Cuota',
                value: '\$${credito.valorPorCuota.toStringAsFixed(2)}',
                icon: Icons.monetization_on_outlined,
              ),
              _InfoItem(
                label: 'Próximo Pago',
                value: credito.proximaCuotaStr,
                icon: Icons.calendar_month_outlined,
                alignRight: true,
              ),
            ],
          ),

          const SizedBox(height: 15),
          Divider(color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 10),

          // 3. NUEVOS DATOS: Abonado y Estado Cuota
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Abonado Total', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text(
                    '\$${credito.abonadoTotal.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Estado Cuota', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text(
                    credito.estadoCuota.toUpperCase(),
                    style: TextStyle(
                        color: _getColorEstadoCuota(credito.estadoCuota),
                        fontSize: 14,
                        fontWeight: FontWeight.w800
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 15),

          // 4. BARRA DE PROGRESO
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progreso del crédito', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
                  Text('${(porcentajePagado * 100).toInt()}%', style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: porcentajePagado,
                  backgroundColor: Colors.black26,
                  color: Colors.greenAccent,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorEstadoCuota(String estado) {
    if (estado.toLowerCase().contains('venc')) return Colors.redAccent;
    if (estado.toLowerCase().contains('pagad')) return Colors.greenAccent;
    return Colors.orangeAccent; // Pendiente o Al día
  }
}

// Widget auxiliar interno para items de información
class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool alignRight;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!alignRight) ...[
          _IconBox(icon: icon),
          const SizedBox(width: 12),
        ],
        Column(
          crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        if (alignRight) ...[
          const SizedBox(width: 12),
          _IconBox(icon: icon),
        ],
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  const _IconBox({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (estado == 'Aprobado' || estado == 'Activo') bg = Colors.green;
    else if (estado == 'Pendiente') bg = Colors.orange;
    else bg = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bg.withOpacity(0.5)),
      ),
      child: Text(
        estado.toUpperCase(),
        style: TextStyle(color: bg.withOpacity(1.0), fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
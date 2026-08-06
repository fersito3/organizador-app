import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../widgets/app_toast.dart';

class MercadoPagoCobroService {
  static const String _remoteUrl = 'https://organizador-app-server.onrender.com/api/mercadopago/preference';
  static const String _localUrl = 'http://10.0.2.2:3000/api/mercadopago/preference';

  /// Genera una preferencia en Mercado Pago y retorna el link de cobro (init_point)
  static Future<String?> generarLinkCobro({
    required String titulo,
    required double monto,
  }) async {
    final body = jsonEncode({
      'title': titulo,
      'amount': monto,
    });

    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(
        Uri.parse(_remoteUrl),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['init_point'] as String?;
      }
    } catch (_) {
      // Fallback a servidor local si falla el remoto
      try {
        final localResponse = await http.post(
          Uri.parse(_localUrl),
          headers: headers,
          body: body,
        ).timeout(const Duration(seconds: 10));

        if (localResponse.statusCode == 200) {
          final data = jsonDecode(localResponse.body);
          return data['init_point'] as String?;
        }
      } catch (_) {}
    }
    return null;
  }

  /// Muestra un modal diálogo interactivo con el Código QR y el Link de Cobro de Mercado Pago
  static void mostrarDialogoCobro(
    BuildContext context, {
    required String titulo,
    required double monto,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return _CobroDialog(titulo: titulo, monto: monto);
      },
    );
  }
}

class _CobroDialog extends StatefulWidget {
  final String titulo;
  final double monto;

  const _CobroDialog({required this.titulo, required this.monto});

  @override
  State<_CobroDialog> createState() => _CobroDialogState();
}

class _CobroDialogState extends State<_CobroDialog> {
  bool _cargando = true;
  String? _linkCobro;
  String? _error;

  @override
  void initState() {
    super.initState();
    _obtenerLink();
  }

  Future<void> _obtenerLink() async {
    final link = await MercadoPagoCobroService.generarLinkCobro(
      titulo: widget.titulo,
      monto: widget.monto,
    );

    if (mounted) {
      setState(() {
        _cargando = false;
        if (link != null) {
          _linkCobro = link;
        } else {
          _error = 'No se pudo generar el link de cobro en este momento.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final qrUrl = _linkCobro != null
        ? 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${Uri.encodeComponent(_linkCobro!)}'
        : null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: const [
          Icon(Icons.qr_code_2_rounded, color: Color(0xFF009EE3), size: 28), // MP Blue
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Cobro con Mercado Pago',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE), // Sky 100
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    widget.titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0369A1)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${widget.monto.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF0284C7)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_cargando) ...[
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF009EE3)),
                    SizedBox(height: 12),
                    Text('Generando QR y link de cobro...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    SizedBox(height: 4),
                    Text('Conectando con el servidor (esto puede tomar unos segundos si se está iniciando)...', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ] else if (_error != null) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ] else if (_linkCobro != null) ...[
              // IMAGEN DEL QR CODE
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    qrUrl!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return const SizedBox(
                        width: 200,
                        height: 200,
                        child: Center(child: CircularProgressIndicator(color: Color(0xFF009EE3))),
                      );
                    },
                    errorBuilder: (_, __, ___) => const SizedBox(
                      width: 200,
                      height: 200,
                      child: Icon(Icons.qr_code_scanner_rounded, size: 80, color: Color(0xFF009EE3)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Escaneá con la app de Mercado Pago para pagar',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // BOTÓN COPIAR LINK DE COBRO
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _linkCobro!));
                  AppToast.show(context, message: 'Link de cobro copiado al portapapeles!', icon: Icons.copy_rounded);
                },
                icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                label: const Text('Copiar Link de Cobro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009EE3), // Mercado Pago Blue
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/imei_provider.dart';
import 'result_screen.dart';

class ManualInputScreen extends StatefulWidget {
  final String? imeiPrellenado;
  const ManualInputScreen({super.key, this.imeiPrellenado});

  @override
  State<ManualInputScreen> createState() => _ManualInputScreenState();
}

class _ManualInputScreenState extends State<ManualInputScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.imeiPrellenado ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _consultar() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ImeiProvider>();
    await provider.consultar(_controller.text.trim());

    if (!mounted) return;

    if (provider.status == ImeiStatus.success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ResultScreen()),
      );
    } else if (provider.status == ImeiStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Error desconocido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.watch<ImeiProvider>().status == ImeiStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Ingresar IMEI')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                maxLength: 15,
                decoration: const InputDecoration(
                  labelText: 'IMEI',
                  hintText: '14 o 15 dígitos',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Ingresa un IMEI';
                  if (!RegExp(r'^\d{14,15}$').hasMatch(v)) {
                    return 'El IMEI debe tener 14 o 15 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: isLoading ? null : _consultar,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Consultar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

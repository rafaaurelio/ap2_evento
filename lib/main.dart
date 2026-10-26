import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tibia Championship 2026',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF141210), // Fundo Dark Medieval
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C3A21),
          primary: const Color(0xFF5C3A21), // Marrom Couro / Madeira
          secondary: const Color(0xFFDAA520), // Dourado Tibiano
          surface: const Color(0xFF1F1C18),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFE5D5C5)),
          bodyMedium: TextStyle(color: Color(0xFFE5D5C5)),
        ),
        useMaterial3: true,
      ),
      home: const PaginaIngresso(),
    );
  }
}

class PaginaIngresso extends StatefulWidget {
  const PaginaIngresso({super.key});

  @override
  State<PaginaIngresso> createState() => _PaginaIngressoState();
}

class _PaginaIngressoState extends State<PaginaIngresso> {
  // Controllers dos campos de texto
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Estados da aplicação (mantidos em memória)
  bool _ingressoGerado = false;
  String _nomeIngresso = '';
  String _emailIngresso = '';

  bool _isLendoCamera = false; // Alterna para o leitor de QR Code na mesma tela

  // Status do Check-in: 0 = Nenhum, 1 = Sucesso, 2 = Já feito, 3 = Inválido
  int _statusCheckIn = 0;
  String _nomeCheckInSucesso = '';

  // Lista de presença mantida apenas em memória
  final List<String> _listaPresenca = ['Eternal Oblivion', 'Bubble'];

  MobileScannerController? _scannerController;

  @override
  void dispose() {
    _scannerController?.dispose();
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _abrirScanner() {
    _scannerController?.dispose();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      returnImage: false,
    );
    setState(() {
      _isLendoCamera = true;
    });
  }

  void _fecharScanner() {
    _scannerController?.stop();
    _scannerController?.dispose();
    _scannerController = null;
    setState(() {
      _isLendoCamera = false;
    });
  }

  void _gerarIngresso() {
    setState(() {
      _nomeIngresso = _nomeController.text.trim();
      _emailIngresso = _emailController.text.trim();
      _ingressoGerado = true;
    });
  }

  void _processarQRCode(String rawValue) {
    _fecharScanner();

    // Formato esperado: CHECKIN|nome|e-mail
    if (!rawValue.startsWith('CHECKIN|')) {
      setState(() {
        _statusCheckIn = 3; // QR Inválido
      });
      return;
    }

    List<String> partes = rawValue.split('|');
    if (partes.length < 3) {
      setState(() {
        _statusCheckIn = 3; // QR Inválido
      });
      return;
    }

    String nomeLido = partes[1].trim();

    if (_listaPresenca.contains(nomeLido)) {
      setState(() {
        _statusCheckIn = 2; // Já fez check-in
      });
    } else {
      setState(() {
        _listaPresenca.add(nomeLido);
        _nomeCheckInSucesso = nomeLido;
        _statusCheckIn = 1; // Check-in confirmado
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tibia Championship 2026 ⚔️',
          style: TextStyle(color: Color(0xFFF3E5AB), fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3B2414),
        centerTitle: false,
        elevation: 4,
      ),
      body: _isLendoCamera ? _buildTelaScanner() : _buildTelaPrincipal(),
    );
  }

  Widget _buildTelaScanner() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          if (_scannerController != null)
            MobileScanner(
              controller: _scannerController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    _processarQRCode(barcode.rawValue!);
                    break;
                  }
                }
              },
              errorBuilder: (context, error, child) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.videocam_off, color: Colors.redAccent, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Erro na câmera: ${error.errorCode.name}',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B2414),
                            foregroundColor: const Color(0xFFDAA520),
                          ),
                          onPressed: _abrirScanner,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          // Overlay visual
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDAA520), width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B2414),
                foregroundColor: const Color(0xFFDAA520),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFFDAA520)),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: _fecharScanner,
              child: const Text('Cancelar Leitura', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // --- TELA PRINCIPAL (Formulário, Card, Leitor, Resultado e Lista) ---
  Widget _buildTelaPrincipal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Campos de Texto: Nome e E-mail
          TextField(
            controller: _nomeController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Nome do Jogador / Character',
              labelStyle: TextStyle(color: Color(0xFFBCAAA4)),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF5C3A21))),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFDAA520))),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'E-mail da Conta',
              labelStyle: TextStyle(color: Color(0xFFBCAAA4)),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF5C3A21))),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFDAA520))),
            ),
          ),
          const SizedBox(height: 16),

// Botão Emissão de Ingresso
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B0000), // Vermelho Tibiano
              disabledBackgroundColor: Colors.grey[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: _nomeController.text.trim().isEmpty ? null : _gerarIngresso,
            child: const Text('Emitir Passe de Entrada', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),

          // Card do Ingresso (Aparece após gerar)
          if (_ingressoGerado) ...[
            Card(
              color: const Color(0xFF2C241D),
              elevation: 6,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFFDAA520), width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Banner do evento
                    Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF141210),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF5C3A21)),
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield, color: Color(0xFFDAA520)),
                          SizedBox(width: 8),
                          Text(
                            'THARIAN ARENA - TIBIA 2026',
                            style: TextStyle(color: Color(0xFFF3E5AB), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _nomeIngresso,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF3E5AB)),
                    ),
                    Text(
                      _emailIngresso,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // QR Code sobre fundo claro para manter boa leitura
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: QrImageView(
                        data: 'CHECKIN|$_nomeIngresso|$_emailIngresso',
                        version: QrVersions.auto,
                        size: 180.0,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],

          // Seção Check-in
          const Text(
            'Check-in',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Botão Ler Ingresso
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFF00796B)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: _abrirScanner,
            icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF00796B)),
            label: const Text(
              'Ler ingresso',
              style: TextStyle(color: Color(0xFF00796B), fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),

          // Feedback de Leitura / Resultado do Check-in
          _buildFeedbackBox(),

          const SizedBox(height: 24),

          // Lista de Presença (Contador e Column)
          Text(
            'Presentes (${_listaPresenca.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _listaPresenca.map((nome) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(nome, style: const TextStyle(fontSize: 15)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Widget para os 3 resultados de validação diferentes
  Widget _buildFeedbackBox() {
    if (_statusCheckIn == 1) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B381E),
          border: Border.all(color: Colors.greenAccent),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.greenAccent, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Entrada Permitida na Arena!',
                  style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(_nomeCheckInSucesso, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      );
    } else if (_statusCheckIn == 2) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF3D2C10),
          border: Border.all(color: Colors.orangeAccent),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 28),
            SizedBox(width: 12),
            Text(
              'Gladiador já registrado!',
              style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      );
    } else if (_statusCheckIn == 3) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF3D1414),
          border: Border.all(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.redAccent, size: 28),
            SizedBox(width: 12),
            Text(
              'Passe Recusado / QR Inválido',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
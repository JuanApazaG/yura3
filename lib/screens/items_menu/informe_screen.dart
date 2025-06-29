import 'package:flutter/material.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class InformeScreen extends StatefulWidget {
  final String? audioFilePath;
  const InformeScreen({Key? key, this.audioFilePath}) : super(key: key);

  static final List<Map<String, String>> tiposInforme = [
    {'nombre': 'Evolución Geriátrica', 'icono': 'word', 'tipo_enum': 'EVOLUCION_GERIATRICA'},
    {'nombre': 'Epicrisis', 'icono': 'word', 'tipo_enum': 'EPICRISIS'},
    {'nombre': 'Certificado Médico', 'icono': 'word', 'tipo_enum': 'CERTIFICADO_MEDICO'},
    {'nombre': 'Referencia Médica', 'icono': 'word', 'tipo_enum': 'REFERENCIA_MEDICA'},
    {'nombre': 'Informe de Laboratorio', 'icono': 'word', 'tipo_enum': 'INFORME_LABORATORIO'},
    {'nombre': 'Informe de Consulta Externa', 'icono': 'word', 'tipo_enum': 'CONSULTA_EXTERNA'},
    {'nombre': 'Informe de Urgencias', 'icono': 'word', 'tipo_enum': 'INFORME_URGENCIAS'},
    {'nombre': 'Nota de Evolución', 'icono': 'word', 'tipo_enum': 'NOTA_EVOLUCION'},
  ];

  @override
  State<InformeScreen> createState() => _InformeScreenState();
}

class _InformeScreenState extends State<InformeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int? _selectedIndex;
  bool _isLoading = false;
  String? _errorMsg;
  String? _docxPath;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
    _audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        _duration = d;
      });
    });
    _audioPlayer.onPositionChanged.listen((p) {
      setState(() {
        _position = p;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPauseAudio() async {
    if (widget.audioFilePath == null) return;
    final file = File(widget.audioFilePath!);
    if (!await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El archivo no existe en: ${widget.audioFilePath}')),
      );
      return;
    }
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(DeviceFileSource(widget.audioFilePath!));
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _position = Duration.zero;
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _enviarAlBackend() async {
    if (_selectedIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un tipo de informe.')),
      );
      return;
    }
    if (widget.audioFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay archivo de audio para enviar.')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
      _docxPath = null;
      _errorMsg = null;
    });
    try {
      var uri = Uri.parse("https://884d-190-104-20-155.ngrok-free.app/procesar_informe");
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'audio',
          widget.audioFilePath!,
          filename: path.basename(widget.audioFilePath!),
        ))
        ..fields['tipo_informe'] = InformeScreen.tiposInforme[_selectedIndex!]['tipo_enum']!;
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['documento_base64'] != null) {
          // Decodificar y guardar el docx
          final bytes = base64Decode(data['documento_base64']);
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(tempDir.path, 'documento_generado.docx');
          final file = File(filePath);
          await file.writeAsBytes(bytes);
          setState(() {
            _docxPath = filePath;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMsg = 'No se recibió el documento.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMsg = 'Error del servidor: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Error al enviar: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _abrirDocx() async {
    if (_docxPath == null) return;
    await OpenFile.open(_docxPath!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tipo de Informe'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              'Audio guardado correctamente',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (widget.audioFilePath != null)
              _buildAudioPlayer(),
            const SizedBox(height: 32),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (_errorMsg != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_errorMsg!, style: const TextStyle(color: Colors.red)),
              ),
            if (_docxPath != null)
              Column(
                children: [
                  const Text(
                    'Documento generado:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    onPressed: _abrirDocx,
                    icon: const Icon(Icons.description),
                    label: const Text('Ver documento'),
                  ),
                ],
              ),
            if (_docxPath == null && !_isLoading)
              Expanded(
                child: ListView.builder(
                  itemCount: InformeScreen.tiposInforme.length,
                  itemBuilder: (context, index) {
                    final tipo = InformeScreen.tiposInforme[index];
                    final bool selected = _selectedIndex == index;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      elevation: selected ? 6 : 3,
                      color: selected ? Colors.blue : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: selected
                            ? const BorderSide(color: Colors.blueAccent, width: 2)
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        leading: Image.asset(
                          'assets/imagenes/logo_word.png',
                          width: 36,
                          height: 36,
                        ),
                        title: Text(
                          tipo['nombre']!,
                          style: TextStyle(
                            fontSize: 18,
                            color: selected ? Colors.white : Colors.black,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        hoverColor: Colors.blue[100],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  elevation: 4,
                ),
                onPressed: _isLoading ? null : _enviarAlBackend,
                child: const Text('Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return Card(
      color: Colors.blue[50],
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  iconSize: 40,
                  icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: Colors.blue),
                  onPressed: _playPauseAudio,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Slider(
                        min: 0,
                        max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1,
                        value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                        onChanged: (value) async {
                          final pos = Duration(seconds: value.toInt());
                          await _audioPlayer.seek(pos);
                        },
                        activeColor: Colors.blue,
                        inactiveColor: Colors.blue[100],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(_position), style: const TextStyle(fontSize: 12)),
                          Text(_formatDuration(_duration), style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.stop_circle, color: Colors.red, size: 32),
                  onPressed: _stopAudio,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'dart:convert';

class InformeScreen extends StatefulWidget {
  final String? audioFilePath;
  const InformeScreen({Key? key, this.audioFilePath}) : super(key: key);

  static final List<Map<String, String>> tiposInforme = [
    {'nombre': 'Ren', 'icono': 'pdf', 'tipo_enum': 'EVOLUCION_GERIATRICA'},
    {'nombre': 'Medio', 'icono': 'pdf', 'tipo_enum': 'EVOLUCION_GERIATRICA'},
    {'nombre': 'Informe de evolución', 'icono': 'pdf', 'tipo_enum': 'EVOLUCION_GERIATRICA'},
    {'nombre': 'Informe completo', 'icono': 'pdf', 'tipo_enum': 'EVOLUCION_GERIATRICA'},
    {'nombre': 'Nota rápida', 'icono': 'pdf', 'tipo_enum': 'EVOLUCION_GERIATRICA'},
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
  dynamic _jsonResponse;
  String? _errorMsg;

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
      _jsonResponse = null;
      _errorMsg = null;
    });
    try {
      var uri = Uri.parse("https://dd78-190-104-20-155.ngrok-free.app/procesar_informe");
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
        setState(() {
          _jsonResponse = data;
          _isLoading = false;
        });
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
            if (_jsonResponse != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      const JsonEncoder.withIndent('  ').convert(_jsonResponse),
                      style: const TextStyle(fontSize: 16, color: Colors.black87, fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
            if (_jsonResponse == null && !_isLoading)
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
                        leading: Icon(Icons.picture_as_pdf,
                            color: selected ? Colors.white : Colors.red, size: 36),
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

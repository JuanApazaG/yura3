import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:gestor_de_membresias/screens/items_menu/informe_screen.dart';

// Importaciones necesarias para la grabación de audio y permisos
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart'; // Para obtener rutas de directorio temporal
import 'dart:io'; // Para trabajar con archivos
import 'package:file_picker/file_picker.dart';

class MicrofonoScreen extends StatefulWidget {
  const MicrofonoScreen({Key? key}) : super(key: key);

  @override
  State<MicrofonoScreen> createState() => _MicrofonoScreenState();
}

class _MicrofonoScreenState extends State<MicrofonoScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Instancia del grabador de audio
  final AudioRecorder _audioRecorder = AudioRecorder();
  // Estado para saber si estamos grabando
  bool _isRecording = false;
  // Ruta donde se guardará el archivo de audio
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();

    // Iniciar la grabación automáticamente cuando la pantalla se muestra
    _startRecording();
  }

  @override
  void dispose() {
    // Asegurarse de detener la grabación y liberar los recursos al salir de la pantalla
    _audioRecorder.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Método para verificar y solicitar permisos de micrófono
  Future<void> _checkPermissions() async {
    // Solicita el permiso del micrófono
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      print('Permiso de micrófono concedido.');
    } else if (status.isDenied) {
      print('Permiso de micrófono denegado. Por favor, otórgalo en la configuración de la aplicación.');
      // Opcional: mostrar un mensaje al usuario o un diálogo
    } else if (status.isPermanentlyDenied) {
      print('Permiso de micrófono permanentemente denegado. Abriendo configuración de la aplicación.');
      // Redirigir al usuario a la configuración de la aplicación
      openAppSettings();
    }
  }

  // Método para iniciar la grabación de audio
  Future<void> _startRecording() async {
    try {
      // Primero, verifica los permisos
      await _checkPermissions();

      // Si el permiso está concedido, procede con la grabación
      if (await _audioRecorder.hasPermission()) {
        // Obtener el directorio temporal de la aplicación
        final directory = await getTemporaryDirectory();
        // Definir la ruta completa del archivo de audio. Puedes elegir el formato (m4a, wav, aac, etc.)
        final path = '${directory.path}/my_audio.m4a';

        // Iniciar la grabación
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          _isRecording = true;
          _audioPath = path; // Almacenar la ruta del archivo
        });
        print('Grabación iniciada en: $path');
      } else {
        print('No se pudo iniciar la grabación: Permiso no concedido.');
      }
    } catch (e) {
      print('Error al iniciar la grabación: $e');
      // Opcional: mostrar un diálogo de error al usuario
    }
  }

  // Método para detener la grabación de audio
  Future<void> _stopRecording() async {
    try {
      if (_isRecording) {
        // Detener la grabación y obtener la ruta final del archivo
        final path = await _audioRecorder.stop();
        setState(() {
          _isRecording = false;
          _audioPath = path; // Asegurarse de tener la ruta final
        });
        print('Grabación detenida. Archivo guardado en: $path');

        if (path != null && mounted) {
          // Si el archivo se grabó correctamente, navegar a InformeScreen
          // Asegúrate de que el widget todavía está montado antes de navegar
          Navigator.of(context).pop();
          // Luego navegamos a InformeScreen, pasando la ruta del archivo de audio
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => InformeScreen(audioFilePath: path), // Pasamos la ruta
            ),
          );
        }
      }
    } catch (e) {
      print('Error al detener la grabación: $e');
      // Opcional: mostrar un diálogo de error al usuario
    }
  }

  Future<void> _importarAudio() async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de almacenamiento denegado.')),
        );
        return;
      }
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['m4a', 'aac', 'wav', 'mp3', 'ogg'],
      );
      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        print('Archivo importado: $filePath');
        if (mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => InformeScreen(audioFilePath: filePath),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se seleccionó ningún archivo.')),
        );
      }
    } catch (e) {
      print('Error al importar audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al importar audio: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: screenHeight * _animation.value,
            width: double.infinity,
            color: Colors.blue,
            child: _animation.value > 0.95 ? _buildContent() : null,
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Micrófono animado
        _AnimatedMic(),
        const SizedBox(height: 32),
        Text(
          _isRecording ? 'Escuchando consulta...' : 'Grabación finalizada.',
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                // Acción de detener: llama a la función para detener la grabación
                await _stopRecording();
              },
              icon: const Icon(Icons.stop),
              label: const Text('Detener'),
            ),
            const SizedBox(width: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                // Acción de cancelar: detener la grabación y descartar el archivo
                if (_isRecording) {
                  await _audioRecorder.stop(); // Detiene la grabación sin procesar el archivo
                  print('Grabación cancelada.');
                }
                Navigator.of(context).pop(); // Vuelve a la pantalla anterior
              },
              icon: const Icon(Icons.cancel),
              label: const Text('Cancelar'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 220,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
            onPressed: _importarAudio,
            icon: const Icon(Icons.upload_file),
            label: const Text('Importar audio'),
          ),
        ),
      ],
    );
  }
}

class _AnimatedMic extends StatefulWidget {
  @override
  State<_AnimatedMic> createState() => _AnimatedMicState();
}

class _AnimatedMicState extends State<_AnimatedMic> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double scale = 1 + 0.2 * math.sin(_controller.value * 2 * math.pi);
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(32),
            child: const Icon(Icons.mic, color: Colors.blue, size: 64),
          ),
        );
      },
    );
  }
}

// Asegúrate de que tu InformeScreen pueda recibir la ruta del archivo de audio
// Si no lo tienes, puedes agregarlo así:
/*
class InformeScreen extends StatelessWidget {
  final String? audioFilePath;

  const InformeScreen({Key? key, this.audioFilePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informe')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Contenido del Informe'),
            if (audioFilePath != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Ruta del audio grabado: $audioFilePath'),
              ),
            // Aquí puedes agregar lógica para reproducir el audio o subirlo
            // Por ejemplo, un botón para reproducir:
            // if (audioFilePath != null)
            //   ElevatedButton(
            //     onPressed: () {
            //       // Lógica para reproducir el audio desde audioFilePath
            //       print('Reproduciendo audio desde: $audioFilePath');
            //     },
            //     child: const Text('Reproducir Audio'),
            //   ),
          ],
        ),
      ),
    );
  }
}
*/

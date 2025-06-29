// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:gestor_de_membresias/utils/Config.dart';
// import 'login_screen.dart';

// class ActualizarContrasenaScreen extends StatefulWidget {
//   const ActualizarContrasenaScreen({super.key});

//   @override
//   State<ActualizarContrasenaScreen> createState() => _ActualizarContrasenaScreenState();
// }

// class _ActualizarContrasenaScreenState extends State<ActualizarContrasenaScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _pass1 = TextEditingController();
//   final TextEditingController _pass2 = TextEditingController();
//   bool _enviando = false;

//   Future<void> _actualizarContrasena() async {
//     final email = _emailController.text.trim();
//     final pass1 = _pass1.text.trim();
//     final pass2 = _pass2.text.trim();

//     if (email.isEmpty || pass1.isEmpty || pass2.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Completa todos los campos')),
//       );
//       return;
//     }
//     if (pass1 != pass2) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Las contraseñas no coinciden')),
//       );
//       return;
//     }
//     if (pass1.length < 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres')),
//       );
//       return;
//     }

//     setState(() {
//       _enviando = true;
//     });

//     try {
//       final response = await http.post(
//         Uri.parse('${Config.baseUrl}/api/actualizar-contrasena'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           "email": email,
//           "nuevaContrasena": pass1,
//         }),
//       );

//       if (response.statusCode == 200) {
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (_) => AlertDialog(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             title: const Text('¡Éxito!'),z
//             content: const Text('Contraseña cambiada con éxito'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Cierra el dialog
//                   Navigator.of(context).pushAndRemoveUntil(
//                     MaterialPageRoute(builder: (_) => LoginScreen(onLoginSuccess: () {})),
//                     (route) => false,
//                   );
//                 },
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('No se pudo actualizar la contraseña')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     } finally {
//       setState(() {
//         _enviando = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Nueva contraseña',
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//           ),
//         ),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'Crea tu nueva contraseña',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 22,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 28),
//               TextField(
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 enabled: !_enviando,
//                 decoration: InputDecoration(
//                   prefixIcon: const Icon(Icons.email_outlined, color: Colors.blue),
//                   hintText: 'Correo electrónico',
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(vertical: 18),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _pass1,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   prefixIcon: const Icon(Icons.lock_outline, color: Colors.blue),
//                   hintText: 'Nueva contraseña',
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(vertical: 18),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _pass2,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   prefixIcon: const Icon(Icons.lock_outline, color: Colors.blue),
//                   hintText: 'Repite la nueva contraseña',
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(vertical: 18),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: ElevatedButton(
//                   onPressed: _enviando ? null : _actualizarContrasena,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF2196F3),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     elevation: 2,
//                   ),
//                   child: _enviando
//                       ? const SizedBox(
//                           width: 24,
//                           height: 24,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 3,
//                           ),
//                         )
//                       : const Text(
//                           'Cambiar contraseña',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
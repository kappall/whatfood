import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/core/constants/costants.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';

// class GoogleSigninButton extends ConsumerWidget {
//   final bool isFromLogin;
//   const GoogleSigninButton({super.key, this.isFromLogin = true});

//   void signInWIthGoogle(BuildContext context, WidgetRef ref) {
//     ref
//         .read(authControllerProvider.notifier)
//         .signInWithGoogle(context, isFromLogin);
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return FilledButton.icon(
//       onPressed: () {
//         signInWIthGoogle(context, ref);
//       },
//       icon: Image.asset(
//         Constants.googlePath,
//         width: 35,
//       ),
//       label: const Text('Continue with Google'),
//       style: FilledButton.styleFrom(
//           backgroundColor: Colors.lightGreen,
//           minimumSize: const Size(double.infinity, 50),
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
//     );
//   }
// }

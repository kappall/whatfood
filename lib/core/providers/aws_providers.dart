import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final apiProvider = Provider((ref) => Amplify.API);
final authProvider = Provider((ref) => AmplifyAuthCognito());
final storageProvider = Provider((ref) => Amplify.Storage);
final googleSignInProvider = Provider((ref) => GoogleSignIn());

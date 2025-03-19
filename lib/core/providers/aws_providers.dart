import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:whatfood/models/ModelProvider.dart';

final api = Amplify.API;
final auth = AmplifyAuthCognito();
final storage = Amplify.Storage;
final datastore = AmplifyDataStore(modelProvider: ModelProvider.instance);
final googleSignIn = GoogleSignIn();

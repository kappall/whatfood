import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/preferences/widgets/intollerances_list.dart';
import 'package:whatfood/features/preferences/controller/preferences_controller.dart';
import 'package:whatfood/models/User.dart';

class PreferencesView extends ConsumerStatefulWidget {
  const PreferencesView(
      {super.key, required this.isFromProfile, this.userModel});
  final bool isFromProfile;
  final User? userModel;

  @override
  ConsumerState<PreferencesView> createState() => _PreferencesViewState();
}

class _PreferencesViewState extends ConsumerState<PreferencesView> {
  // Funzione per ottenere i dati utente
  Future<Map<String, dynamic>> getUserData() async {
    final attributes = await Amplify.Auth.fetchUserAttributes();
    return Map.fromEntries(
      attributes.map((attr) => MapEntry(attr.userAttributeKey.key, attr.value)),
    );
  }

  // Metodo per salvare le preferenze, utilizzando il provider PreferencesController
  Future<void> savePreferences(
      BuildContext context, List<String> preferences) async {
    await ref.read(preferencesControllerProvider.notifier).savePreferences(
          context: context,
          preferences: preferences,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Se la pagina proviene dal profilo e non è stato passato un userModel, si deve caricare l'utente
    if (widget.isFromProfile && widget.userModel == null) {
      return FutureBuilder<Map<String, dynamic>>(
        future: getUserData(),
        builder: (context, snapshot) {
          // Stato di caricamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: Loader()),
            );
          }
          // Gestione errori
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text("Error: ${snapshot.error}")),
            );
          }
          // Dati disponibili: creazione dell'oggetto User e UI
          if (snapshot.hasData) {
            final user = User.fromJson(snapshot.data!);
            final intolerances = user.preferences ?? [];
            return _buildPreferencesScaffold(context, intolerances);
          }
          return const Scaffold(
            body: Center(child: Loader()),
          );
        },
      );
    } else {
      // Se si tratta di un flusso non proveniente dal profilo, oppure se è stato passato un userModel,
      // si utilizzano i dati già disponibili (o una lista vuota)
      final intolerances = widget.userModel?.preferences ?? [];
      return _buildPreferencesScaffold(context, intolerances);
    }
  }

  // Metodo ausiliario per costruire la Scaffold principale
  Widget _buildPreferencesScaffold(
      BuildContext context, List<String> intolerances) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Food Preferences',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            if (!widget.isFromProfile)
              TextButton(
                onPressed: () => Routemaster.of(context).replace('/'),
                child: const Text(
                  'Skip',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              )
          ],
          backgroundColor: Colors.green,
          elevation: 2,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'What foods can\'t you eat?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[100],
                  border: Border.all(
                    color: Colors.green,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.width * 0.9,
                ),
                child: IntollerancesList(
                  intollerances: intolerances,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () async {
                await savePreferences(context, intolerances);
                if (context.mounted) {
                  Routemaster.of(context)
                      .popUntil((route) => route.path == '/');
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

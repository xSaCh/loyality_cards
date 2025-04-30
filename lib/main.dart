import 'package:ext/firebase_options.dart';
import 'package:ext/global.dart';
import 'package:ext/repositories/firebase_loyalty_card_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ext/blocs/dashboard/dashboard_bloc.dart';
import 'package:ext/pages/dashboard_page.dart';
import 'package:ext/repositories/shared_pref_loyalty_card_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Global.init(SharedPrefLoyaltyCardRepo());
  Global.init(FirebaseLoyaltyCardRepository());
  // Global.instance.loyaltyCardRepository.clearAllCards();
  // for (var card in mockLoyaltyCards) {
  //   Global.instance.loyaltyCardRepository.addCard(card);
  // }
  // print(
  //     "${(await Global.instance.loyaltyCardRepository.getCards()).last.imagePath}");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DashboardBloc()..add(LoadDashboard()), // Load initial data here
      child: MaterialApp(
        title: 'Everyday Rewards Inc.',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const DashboardPage(),
      ),
    );
  }
}

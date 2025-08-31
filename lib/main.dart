import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_p2p/providers/p2p_provider.dart';
import 'package:flutter_p2p/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => P2PProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter P2P',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/aine_provider.dart';
import '../../provider/auth_provider.dart';
import 'list_aine_screen.dart';

class AineScreen extends StatefulWidget {
  const AineScreen({super.key});

  @override
  State<AineScreen> createState() => _AineScreenState();
}

class _AineScreenState extends State<AineScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<AineProvider>(context, listen: false).fetchAines(auth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const ListAineScreen();
  }
}
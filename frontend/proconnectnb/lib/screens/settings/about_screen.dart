import 'package:flutter/material.dart';
import '../../widgets/tr_text.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TrText("about"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TrText("ProConnectNB", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TrText("version 1.0.0"),
            SizedBox(height: 16),
            TrText("ProConnectNB est une application mobile conçue pour améliorer la qualité de vie des personnes médicamentées du Nouveau-Brunswick. Elle répond à deux enjeux majeurs : la gestion de la santé et la lutte contre l’isolement social."),
          ],
        ),
      ),
    );
  }
}
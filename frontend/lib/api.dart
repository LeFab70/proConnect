import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http; // Import du package http pour les requetes HTTP qui sont plus universelles

class Api 
{
  final String baseUrl = "https://proconnectnb-d2bxe6embxg2e7h7.eastus2-01.azurewebsites.net";

  Future<String> getUser() async 
  {
    try 
    {
      final url = Uri.parse("$baseUrl/api/users/1"); // Exemple avec l'ID utilisateur 1

      print("URL: $url"); // Log de l'URL

      // TODO: Ajouter les headers si necessaire
      final response = await http.get(url);//, headers: defaultHeaders()); // Requete GET avec headers

      print("Status: ${response.statusCode}"); // Print dans vscode console

      // Retours sur la app dart en fonction du status code
      if (response.statusCode == 200) 
      {
        return response.body;
      } 
      else if 
      (response.statusCode == 404) 
      {
        return "Utilisateur introuvable";
      } 
      else 
      {
        return "Erreur: ${response.statusCode}";
      }
    } 
    catch (ex) 
    {
      return "Exception: $ex";
    }
  }

  Future<String> getTest() async 
  {
    final client = HttpClient(); // Utilisation de HttpClient donc pas besoin de package http (tres basique)

    try 
    {
      print(baseUrl); // print de baseUrl pour debug

      final HttpClientRequest request = await client.getUrl(Uri.parse("$baseUrl/api/users/test")); // Creation de la requete GET

      final HttpClientResponse response = await request.close(); // Envoi de la requete et attente de la reponse

      if (response.statusCode == 200) 
      {
        final String body = await response.transform(utf8.decoder).join(); // Lecture du corps de la reponse et transformation en String
        return body; // Retour du corps de la reponse au caler (main.dart)
      }
      else 
      {
        return "Erreur: ${response.statusCode}";
      }
    }
    catch (ex) 
    {
      return "Exception durant l'exécution du api Test: $ex";
    } 
    finally 
    {
      client.close();
    }
  }

}
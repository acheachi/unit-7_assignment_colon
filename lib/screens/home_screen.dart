import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var content;
  bool loading = false;

  Future getList() async {
    setState(() {
      loading = true;
    });

    var data = await getContent();

    setState(() {
      loading = false;
      content = data['content'];
    });
  }

  Future<Map> getContent() async {
    var url = 'https://digi-api.com/api/v1/digimon?pageSize=20';
    var uri = Uri.parse(url);
    var response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);
    return json;
  }

  Future<String> getDescription(int digimonId) async {
    var url = 'https://digi-api.com/api/v1/digimon/$digimonId';
    var uri = Uri.parse(url);
    var response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);

    var descriptions = json['descriptions'] as List;
    var englishDescription = descriptions.firstWhere(
    (desc) => desc['language'] == 'en_us',
    orElse: () => {'description': 'No description available'}
    );
    return englishDescription['description'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit 7 - API Calls"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: FutureBuilder(
        // setup the URL for your API here
        future: getContent(),
        builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) {
          // Consider 3 cases here
          // when the process is ongoing
          // return CircularProgressIndicator();
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          // error
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }
          
          // when the process is completed:
          // successful
          // Use the library here
          var data = snapshot.data as Map;
          var results = data['content'];
          print(results);

          return ExpandedTileList.builder(
            itemCount: results.length,
            maxOpened: 1,
            itemBuilder: (context, index, controller) {
              var digimonId = results[index]['id'];

              return ExpandedTile(
                theme: const ExpandedTileThemeData(
                  headerColor: Colors.orangeAccent,
                  headerPadding: EdgeInsets.all(18.0),
                  headerSplashColor: Colors.deepOrange,
                  contentBackgroundColor: Colors.blueAccent,
                  contentPadding: EdgeInsets.all(24.0),
                ),
                controller: ExpandedTileController(),
                title: Text(
                  '${index + 1}. ${results[index]['name']}',
                  style: const TextStyle(
                    fontSize: 24.0,
                    color: Colors.white,
                  ),
                ),
                content: FutureBuilder<String>(
                  future: getDescription(digimonId),
                  builder: (context, descriptionSnapshot) {
                    if (descriptionSnapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (descriptionSnapshot.hasError) {
                      return Center(child: Text('Error: ${descriptionSnapshot.error}'));
                    }

                    if (!descriptionSnapshot.hasData) {
                      return const Center(child: Text('No description available'));
                    }

                    var description = descriptionSnapshot.data;

                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Image.network(
                              "https://digi-api.com/images/digimon/w/${results[index]['name'].replaceAll(' ', '_')}.png",
                              height: 200,
                              width: 200,
                            ),
                            Text(
                              'Name: ${results[index]['name']}',
                              style: const TextStyle(fontSize: 18.0, color: Colors.white),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Description: $description',
                                style: const TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
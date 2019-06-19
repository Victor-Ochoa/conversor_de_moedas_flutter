import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=c4b9d928";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  ));
}

Future<Map> getData() async {
  var response = await http.get(request);
  return jsonDecode(response.body)["results"]["currencies"];
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _realController = TextEditingController();

  void _realChanged(String newText) {
    if (newText.isEmpty) {
      _clearAll();
      return;
    }

    var real = double.parse(newText);
    _dollarController.text = (real / _dollar).toStringAsFixed(2);
    _euroController.text = (real / _euro).toStringAsFixed(2);
  }

  var _dollarController = TextEditingController();

  void _dollarChanged(String newText) {
    if (newText.isEmpty) {
      _clearAll();
      return;
    }

    var dollar = double.parse(newText);
    _realController.text = (dollar * _dollar).toStringAsFixed(2);
    _euroController.text = ((dollar * _dollar) / _euro).toStringAsFixed(2);
  }

  var _euroController = TextEditingController();

  void _euroChanged(String newText) {
    if (newText.isEmpty) {
      _clearAll();
      return;
    }

    var euro = double.parse(newText);
    _realController.text = (euro * _euro).toStringAsFixed(2);
    _dollarController.text = ((euro * _euro) / _dollar).toStringAsFixed(2);
  }

  var _dollar = 0.0;
  var _euro = 0.0;

  void _clearAll() {
    _dollarController.text = "";
    _realController.text = "";
    _euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.amber,
          centerTitle: true,
          title: Text("Conversor Monetário"),
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                case ConnectionState.active:
                  return Center(
                    child: Text(
                      "Carregando dados",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                case ConnectionState.done:
                default:
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Erro ao carregar os dados",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 25,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    _dollar = snapshot.data["USD"]["buy"];
                    _euro = snapshot.data["EUR"]["buy"];

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(
                            Icons.monetization_on,
                            size: 150,
                            color: Colors.amber,
                          ),
                          textFieldCurrency(
                              "Reais", "R\$ ", _realController, _realChanged),
                          textFieldCurrency("Dolares", "\$ ", _dollarController,
                              _dollarChanged),
                          textFieldCurrency(
                              "Euros", "€ ", _euroController, _euroChanged),
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

Widget textFieldCurrency(String name, String prefix,
        TextEditingController controller, Function changed) =>
    Padding(
      padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: name,
          labelStyle: TextStyle(color: Colors.amber),
          border: OutlineInputBorder(),
          prefixText: prefix,
        ),
        style: TextStyle(color: Colors.amber),
        onChanged: changed,
      ),
    );

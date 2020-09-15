import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

const request = 'https://api.hgbrasil.com/finance?key=79cb5ac4';

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white)))),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

 void _clearAll(){
   realController.text = "";
   dolarController.text = "";
   euroController.text = "";
 }

  void _realChanged(String text){
   if(text.isEmpty){
     _clearAll();
     return;
   }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text){
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (this.dolar * dolar).toStringAsFixed(2);
    euroController.text = ( dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text){
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  double dolar;
  double euro;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: _clearAll,)
        ],
      ),

      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                  child: Text(
                "Carregando dados...",
                style: TextStyle(color: Colors.amber, fontSize: 20.0),
                textAlign: TextAlign.center,
              ));
            default:
              if (snapshot.hasError) {

                return Center(
                  child: Text(
                    "Erro ao Carregar Dados :(",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );

              } else {

                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];

                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(

                  padding: EdgeInsets.all(10),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.stretch,

                    children: <Widget>[

                      Icon(Icons.monetization_on, size: 150.0, color: Colors.amber),

                      buildTextField("Reais", "R\$", realController, _realChanged),

                      Divider(),

                      buildTextField("Dólares", "US\$", dolarController, _dolarChanged),

                      Divider(),

                      buildTextField("Euros", "€", euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController controller, Function function){
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix + " "),

    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: function,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

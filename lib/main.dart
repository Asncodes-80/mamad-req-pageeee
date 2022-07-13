import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Mamad req pageeee'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String baseUrl = "";
  String data = "";
  String methodType = "";
  String bodyResponse = "";

  @override
  Widget build(BuildContext context) {
    // Setting dio base option about the connection timeout and others...
    Dio dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: 60 * 1000,
        receiveTimeout: 60 * 1000,
      ),
    );

    /// Making request by this function
    makeReq({required String baseUrl, required String method}) async {
      try {
        // Read pem files
        ByteData clientCert = await rootBundle.load("assets/cert.pem");
        ByteData privateKey = await rootBundle.load("assets/key.pem");

        (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
            (client) {
          // Set X509 if want setting default bad certificate callback
          // client.badCertificateCallback =
          //     (X509Certificate cert, String host, int port) => true;
          // return null;

          // Define security context for the application
          SecurityContext context = SecurityContext(withTrustedRoots: true);
          // // Using in cert chain rule
          context.useCertificateChainBytes(clientCert.buffer.asUint8List());
          context.usePrivateKeyBytes(privateKey.buffer.asUint8List());
          // // Submit this context to httpClient
          HttpClient httpClient = HttpClient(context: context);

          return httpClient;
        };

        Response res = await dio.request(
          baseUrl,
          data: data,
          options: Options(method: method, headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
          }),
        );
        setState(() => bodyResponse = res.toString());
      } catch (e) {
        print(e);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Text(
                      "Your method ",
                      style: ThemeData().textTheme.headline1!.copyWith(
                            fontSize: 30.0,
                            color: Colors.red,
                          ),
                    ),
                    Text(
                      methodType,
                      style: ThemeData().textTheme.bodyMedium!.copyWith(
                            fontSize: 20.0,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextFormField(
                  initialValue: baseUrl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    hintText: "Enter Your BaseURL",
                  ),
                  onChanged: (String onTextChange) =>
                      setState(() => baseUrl = onTextChange),
                ),
              ),
              const SizedBox(height: 10.0),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextFormField(
                  initialValue: data,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    hintText: "Data...",
                  ),
                  onChanged: (String onTextChange) =>
                      setState(() => data = onTextChange),
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => methodType = "POST"),
                      child: const Text("POST"),
                    ),
                    const SizedBox(width: 20.0),
                    ElevatedButton(
                      onPressed: () => setState(() => methodType = "GET"),
                      child: const Text("GET"),
                    ),
                  ],
                ),
              ),
              Builder(builder: (BuildContext context) {
                if (bodyResponse == "") {
                  return const Text("Data is empty.");
                }

                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: Row(
                        children: [
                          Text(
                            "Response",
                            style: ThemeData().textTheme.headline2!.copyWith(
                                  fontSize: 26.0,
                                  color: Colors.red,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20.0),
                      height: 250,
                      child: Card(
                        child: SelectableText(bodyResponse),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => makeReq(baseUrl: baseUrl, method: methodType),
        tooltip: 'Send req',
        child: const Icon(Icons.send),
      ),
    );
  }
}

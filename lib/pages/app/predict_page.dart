import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class PredictScreen extends StatefulWidget {
  const PredictScreen({Key? key}) : super(key: key);

  @override
  State<PredictScreen> createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  final user = FirebaseAuth.instance.currentUser;

  late Future<Prediction> prediction;

  var showPrediction = false;

  late final List<TextEditingController> c;

  var model = 'LR';

  final _models = ['Logistic Regression', 'Random Forest', 'SVM', 'xgBoost'];

  String? _selectedModel = "Logistic Regression";

  bool showCustom = true;

  final _years = yearsList();

  var _groundReport = "LOW";

  void resetAll() {
    for (TextEditingController t in c) {
      t.clear();
    }
    setState(() {
      showCustom = true;
      showPrediction = false;
    });
  }

  @override
  void initState() {
    super.initState();
    c = createControllers(12);
  }

  @override
  void dispose() {
    for (TextEditingController t in c) {
      t.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 100,
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    "Expected Rainfall",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Image.asset(
                    "assets/images/rain.png",
                    width: 40,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: DropdownButtonFormField(
                  menuMaxHeight: 300,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).primaryColor,
                  ),
                  decoration: const InputDecoration(
                    label: Text("Select Year of prediction or enter custom"),
                  ),
                  value: _years[0],
                  items: _years.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text("$e"),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != 'Custom') {
                      setControllers(c, int.parse(val as String));
                      getGroundPrediction(int.parse(val as String));
                      setState(() {
                        showCustom = false;
                      });
                    } else {
                      resetAll();
                      showCustom = true;
                    }

                    setState(() {
                      showPrediction = false;
                    });
                  }),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  child: Text("Enter monthly rainfall in mm"),
                )
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Column(
              children: [
                Row(
                  children: [
                    MonthRainfallInput(month: "JAN", c: c[0]),
                    MonthRainfallInput(month: "FEB", c: c[1]),
                    MonthRainfallInput(month: "MAR", c: c[2]),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    MonthRainfallInput(month: "APR", c: c[3]),
                    MonthRainfallInput(month: "MAY", c: c[4]),
                    MonthRainfallInput(month: "JUN", c: c[5]),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    MonthRainfallInput(month: "JUL", c: c[6]),
                    MonthRainfallInput(month: "AUG", c: c[7]),
                    MonthRainfallInput(month: "SEP", c: c[8]),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    MonthRainfallInput(month: "OCT", c: c[9]),
                    MonthRainfallInput(month: "NOV", c: c[10]),
                    MonthRainfallInput(month: "DEC", c: c[11]),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: DropdownButtonFormField(
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).primaryColor,
                  ),
                  decoration: const InputDecoration(
                    label: Text("Select Prediction Model"),
                  ),
                  value: _selectedModel,
                  items: _models.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedModel = val as String;
                      if (_selectedModel == _models[0]) {
                        model = 'LR';
                      } else if (_selectedModel == _models[1]) {
                        model = 'RF';
                      } else if (_selectedModel == _models[2]) {
                        model = 'SVM';
                      }
                    });
                  }),
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    resetAll();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).primaryColor, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 5),
                      child: Text(
                        "Reset",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showPrediction = true;
                      prediction = fetchPrediction(c, model);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.deepOrange[500]),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 80),
                      child: Text(
                        "Predict",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            if (!showCustom)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Ground Report (Flood Occurred): ",
                      style: TextStyle(fontSize: 20)),
                  Text(_groundReport,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w900))
                ],
              ),
            const SizedBox(
              height: 20,
            ),
            if (showPrediction)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                      child: Text("Flood Likelihood ",
                          style: TextStyle(fontSize: 20))),
                  const Center(
                      child: Text("(Model Prediction) : ",
                          style: TextStyle(fontSize: 15))),
                  const SizedBox(
                    height: 20,
                  ),
                  FutureBuilder<Prediction>(
                    future: prediction,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data!.prediction,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w900),
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      return CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      );
                    },
                  ),
                ],
              ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  void setControllers(List<TextEditingController> c, int val) async {
    List<List<dynamic>> year = await processCsv();
    int i = 0;
    for (var controller in c) {
      controller.text = "${year[val - 1900][2 + i]}";
      i++;
    }
  }

  void getGroundPrediction(int val) async {
    List<List<dynamic>> year = await processCsv();
    setState(() {
      _groundReport = year[val - 1900][15];
    });
  }

  Future<List<List<dynamic>>> processCsv() async {
    var result = await DefaultAssetBundle.of(context).loadString(
      "assets/data/kerala.csv",
    );
    return const CsvToListConverter().convert(result, eol: "\n");
  }

}


Future<Prediction> fetchPrediction(List controllers, model) async {
  Map<String, String> data = {
    'JAN': controllers[0].text.trim(),
    'FEB': controllers[1].text.trim(),
    'MAR': controllers[2].text.trim(),
    'APR': controllers[3].text.trim(),
    'MAY': controllers[4].text.trim(),
    'JUN': controllers[5].text.trim(),
    'JUL': controllers[6].text.trim(),
    'AUG': controllers[7].text.trim(),
    'SEP': controllers[8].text.trim(),
    'OCT': controllers[9].text.trim(),
    'NOV': controllers[10].text.trim(),
    'DEC': controllers[11].text.trim(),
    'MODEL': model
  };

  final response = await http.post(
      Uri.parse('https://project-school.onrender.com/predict'),
      body: data);
  if (response.statusCode == 200) {
    var pred = Prediction.fromJson(jsonDecode(response.body));
    uploadPrediction(controllers, pred.prediction, model);
    return pred;
  } else {
    // print(response.body);
    throw Exception('${response.statusCode}');
  }
}

List<TextEditingController> createControllers(n) {
  var x_list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  var _controllers = x_list.map((x) => TextEditingController()).toList();

  return _controllers;
}

Future uploadPrediction(controllers, prediction, model) async {
  await FirebaseFirestore.instance.collection('predictions').add({
    'UserID': FirebaseAuth.instance.currentUser?.email.toString(),
    'JAN': controllers[0].text.trim(),
    'FEB': controllers[1].text.trim(),
    'MAR': controllers[2].text.trim(),
    'APR': controllers[3].text.trim(),
    'MAY': controllers[4].text.trim(),
    'JUN': controllers[5].text.trim(),
    'JUL': controllers[6].text.trim(),
    'AUG': controllers[7].text.trim(),
    'SEP': controllers[8].text.trim(),
    'OCT': controllers[9].text.trim(),
    'NOV': controllers[10].text.trim(),
    'DEC': controllers[11].text.trim(),
    'PREDICTION': prediction,
    'MODEL': model,
    'TIME': FieldValue.serverTimestamp()
  });
}

class Prediction {
  const Prediction({required this.prediction});

  final String prediction;

  factory Prediction.fromJson(Map<String, dynamic> json) {
    var fetched = json['prediction'];
    if (fetched == '1') {
      return const Prediction(prediction: "HIGH");
    }
    return const Prediction(prediction: "LOW");
  }
}

List yearsList() {
  var years = ['Custom'];
  for (int i = 1901; i <= 2018; i++) {
    years.add("$i");
  }
  return years;
}

class MonthRainfallInput extends StatelessWidget {
  const MonthRainfallInput({
    Key? key,
    required this.month,
    required this.c,
  }) : super(key: key);

  final String? month;
  final TextEditingController c;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            "$month",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          InputField(
              prompt: "",
              isPassword: false,
              controller: c,
              onChanged: (str) {}),
        ],
      ),
    );
  }
}

class InputField extends StatelessWidget {
  InputField({
    required this.prompt,
    super.key,
    required this.isPassword,
    required this.controller,
    required this.onChanged,
  });

  final String prompt;
  final bool isPassword;
  final TextEditingController controller;
  Function(String) onChanged;

  void pass(callback) {
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
      child: TextField(
        autocorrect: false,
        onChanged: onChanged,
        controller: controller,
        obscureText: isPassword,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
            border: InputBorder.none,
            fillColor: Colors.grey[50],
            filled: true,
            hintText: prompt,
            focusColor: Theme.of(context).primaryColor),
      ),
    );
  }
}

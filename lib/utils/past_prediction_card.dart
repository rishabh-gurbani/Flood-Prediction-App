import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PastPredictionCard extends StatelessWidget {
  const PastPredictionCard({Key? key, required this.documentId, required this.onPressed}) : super(key: key);

  final String documentId;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {

    CollectionReference predictions = FirebaseFirestore.instance.collection('predictions');
    

    return FutureBuilder(
      future: predictions.doc(documentId).get(),
        builder: (context, snapshot)
        {
      if(snapshot.connectionState == ConnectionState.done){
        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child:
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(data['PREDICTION'],
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.grey[800]),),
                      IconButton(onPressed: onPressed,
                          icon: Icon(Icons.delete_outline_sharp, size: 25, color: Theme.of(context).primaryColor,)),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MonthRainfall(data: data, month: "JAN",),
                      MonthRainfall(data: data, month: "FEB",),
                      MonthRainfall(data: data, month: "MAR",),
                      MonthRainfall(data: data, month: "APR",),
                    ],
                  ),
                  const SizedBox(height: 5,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MonthRainfall(data: data, month: "MAY",),
                      MonthRainfall(data: data, month: "JUN",),
                      MonthRainfall(data: data, month: "JUL",),
                      MonthRainfall(data: data, month: "AUG",),
                    ],
                  ),
                  const SizedBox(height: 5,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MonthRainfall(data: data, month: "SEP",),
                      MonthRainfall(data: data, month: "OCT",),
                      MonthRainfall(data: data, month: "NOV",),
                      MonthRainfall(data: data, month: "DEC",),
                    ],
                  ),
                ],
              ),
        );
      }
      else {
        return const Text('loading..');
      }
    });
  }
}

class MonthRainfall extends StatelessWidget {
  const MonthRainfall({
    Key? key,
    required this.data,
    required this.month
  }) : super(key: key);

  final Map<String, dynamic> data;
  final String month;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("$month : ", style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),),
        Text(data[month], style: const TextStyle(fontSize: 12),),
        const SizedBox(width: 10,)
      ],
    );
  }
}

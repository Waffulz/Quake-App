import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Map _data;
List _features;

void main() async {
  _data = await getQuakes();
  _features = _data['features'];

  runApp(MaterialApp(
    title: 'Quakes',
    theme: ThemeData.dark(),
    home: new Quakes(),
    debugShowCheckedModeBanner: false,
  ));
}

class Quakes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quakes',
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.w500,
            color: Colors.white70
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ListView.builder(
          padding: const EdgeInsets.all(15.0),
          itemCount: _features.length,
          itemBuilder: (BuildContext context, int position) {
            if (position.isOdd) return Divider();
            final index = position ~/ 2;
            var dateFormat = DateFormat("MMM\nd");
            var date = dateFormat.format(DateTime.fromMillisecondsSinceEpoch(
                _features[index]['properties']['time'],
                isUtc: false
            ));
            var timeFormat = DateFormat.jm();
            var time = timeFormat.format(DateTime.fromMillisecondsSinceEpoch(
                _features[index]['properties']['time'],
                isUtc: false
            ));
            String place = '${_features[index]['properties']['place']}';
            var places = place.split(',');
            bool isCityOnly = false;

            if (places.length == 1){
              isCityOnly = true;
            }
            return QuakeCard(
              mag: '${_features[index]['properties']['mag']}',
              location: isCityOnly ? '' : places[0]+',',
              place: isCityOnly ? places[0] : places [1],
              time: '$time',
              date: '$date',
            );
          },
        ),
      ),
    );
  }
}

class QuakeCard extends StatelessWidget {
  final String mag;
  final String time;
  final String date;
  final String location;
  final String place;

  QuakeCard({
    this.mag,
    this.time,
    this.date,
    this.location,
    this.place
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: 70.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red,
                  Colors.redAccent,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Center(
              child: Text(
                mag,
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(200, 255, 255, 255)
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.watch_later, color: Colors.white70, size: 15.0,),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(
                            time,
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: location,
                      style: TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300
                      ),
                      children: <TextSpan> [
                        TextSpan(
                          text: place,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          )
                        )
                      ]
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 1.0,
            height: 50.0,
            color: Colors.white12,
          ),
          Padding(
            padding: const EdgeInsets.only(left:8.0, right: 8.0),
            child: Text(
              date,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromARGB(200, 255, 70, 60),
                fontSize: 22.0,
                fontWeight: FontWeight.w500
              ),
            ),
          )
        ],
      ),
    );
  }
}




Future<Map> getQuakes() async {
  String apiUrl =
      'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/4.5_month.geojson';
  http.Response response = await http.get(apiUrl);
  return json.decode(response.body);
}
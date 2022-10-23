import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable, use_key_in_widget_constructors
class GridDashboard extends StatelessWidget {
  GridDashboard({Key? key}) : super(key: key);
  Items item1 = Items(
      title: "Optimal route planning",
      subtitle: "Waste no time :)",
      event: "",
      img: "assets/efficiency.png",
      route: 'routing');

  @override
  Widget build(BuildContext context) {
    List<Items> myList = [
      item1,
    ];
    var color = 0xff453658;
    return Flexible(
      child: GridView.count(
        childAspectRatio: 1.0,
        padding: const EdgeInsets.only(left: 16, right: 16),
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        children: myList.map((data) {
          return Container(
            foregroundDecoration: BoxDecoration(
              color: Colors.transparent,
              backgroundBlendMode: BlendMode.saturation,
            ),
            decoration: BoxDecoration(
              color: Color(color),
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, data.route);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(data.img, width: 42),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      data.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.openSans(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.subtitle,
                    style: GoogleFonts.openSans(
                      textStyle: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    data.event,
                    style: GoogleFonts.openSans(
                      textStyle: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class Items {
  String title;
  String subtitle;
  String event;
  String img;
  String route;
  Items(
      {required this.title,
      required this.subtitle,
      required this.event,
      required this.img,
      required this.route});
}

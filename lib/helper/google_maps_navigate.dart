// import 'package:url_launcher/url_launcher.dart';
//
//
// void navigateTo(double lat, double lng) async {
//  // void launchMapsUrl(String plat, String plng, String dlat, String dlng) async {
//  String mapOptions = [
//   //'saddr=$lat,$lng',
//   'daddr=$lat,$lng',
//   'dir_action=navigate'
//  ].join('&');
//
//  final url = 'https://www.google.com/maps?$mapOptions';
//  if (await canLaunch(url)) {
//   await launch(url);
//  } else {
//   throw 'Could not launch $url';
//  }
//  //}
// // var uri = Uri.parse("google.navigation:q=$lat,$lng");
// // if (await canLaunch(uri.toString())) {
// // await launch(uri.toString());
// // } else {
// // throw 'Could not launch ${uri.toString()}';
// // }
// }
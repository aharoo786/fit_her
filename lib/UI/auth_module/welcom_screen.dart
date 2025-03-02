import 'package:fitness_zone_2/UI/auth_module/walt_through/walk_through_screenn.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> walkthroughData = [
    {
      "title": "Train Anytime,\nAnywhere!",
      "subtitle": "Join live workout sessions tailored to your fitness goals.",
      "icon": MyImgs.welcomeImage1, // icon for demo
    },
    {
      "title": "Personalized Diet\nJust for You",
      "subtitle":
          "Get meal plans customized to your health needs and preferences.",
      "icon": MyImgs.welcomeImage2 // icon for demo
    },
    {
      "title": "Mental Wellness\nSupport",
      "subtitle":
          "Talk to certified psychologists for emotional and mental health guidance.",
      "icon":MyImgs.welcomeImage3// icon for demo
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          OutlinedButton(
            onPressed: () {
              Get.offAll(() => const WalkThroughScreen());

              // Handle Skip action here
            },
            style: OutlinedButton.styleFrom(
              // padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Skip',
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: walkthroughData.length,
              onPageChanged: (int index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return buildPageContent(
                  title: walkthroughData[index]["title"]!,
                  subtitle: walkthroughData[index]["subtitle"]!,
                  icon: walkthroughData[index]["icon"]!
                );
              },
            ),
          ),
          SizedBox(height: 10),
          buildDotIndicator(),
          SizedBox(height: 30),
          buildButtons(),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget buildPageContent(
      {required String title, required String subtitle, required String icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 100),
          // Icon(
          //   IconData(icon, fontFamily: 'MaterialIcons'),
          //   size: 100,
          //   color: Colors.green,
          // ),
          SvgPicture.asset(icon),
          Spacer(),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        walkthroughData.length,
        (index) => buildDot(index == _currentPage),
      ),
    );
  }

  Widget buildDot(bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      width: isActive ? 10 : 8,
      height: isActive ? 10 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.green[200],
        shape: BoxShape.circle,
      ),
    );
  }

  Widget buildButtons() {
    return Column(
      children: [
        SizedBox(height: 10),
        CustomButton(
            text:
                _currentPage == walkthroughData.length - 1 ? 'Finish' : 'Next',
            onPressed: () {
              if (_currentPage == walkthroughData.length - 1) {
                Get.offAll(() => const WalkThroughScreen());

                // Last page, handle Continue action here
              } else {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              }
            }),
      ],
    );
  }
}

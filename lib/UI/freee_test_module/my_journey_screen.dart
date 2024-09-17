import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';

class OurJourneyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 260,
                  foregroundDecoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25)),
                  ),
                  width: double.maxFinite,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25)),
                      image: DecorationImage(
                          image: AssetImage(
                            MyImgs.ourJourney2,
                          ),
                          fit: BoxFit.cover)),
                ),
                Positioned(
                  // bottom: 16,
                  top: 35,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Icon(
                          Icons.arrow_back,
                          size: 25,
                          color: MyColors.iconColor1,
                        ),
                      ),
                      SizedBox(
                        height: 100,
                      ),
                      Text(
                        'Know\nOUR JOURNEY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('5000+',
                        style: textTheme.headlineMedium!.copyWith(
                            color: MyColors.primaryGradient1,
                            fontWeight: FontWeight.w600)),
                    Text('Clients',
                        style: textTheme.titleLarge!
                            .copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                Column(
                  children: [
                    Text('3000+',
                        style: textTheme.headlineMedium!.copyWith(
                            color: MyColors.primaryGradient1,
                            fontWeight: FontWeight.w600)),
                    Text('Transformations',
                        style: textTheme.titleLarge!
                            .copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Fit Her began its journey in 2022 with a vision to empower women through fitness, making health and wellness accessible to those who need it the most. In just a few years, we\'ve grown exponentially, now proudly serving over 10,000 clients from Pakistan, India, and Dubai.',
                      style: textTheme.titleLarge!
                          .copyWith(fontWeight: FontWeight.w400, height: 1.5)),
                  const SizedBox(
                    height: 20,
                  ),
                  Text('Our Mission',
                      style: textTheme.bodyLarge!
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Text(
                      'At Fit Her, our mission is to break down the barriers that prevent women from accessing the health and fitness resources they need. We believe that every woman, regardless of her location or circumstances, should have the opportunity to lead a healthy and active life.',
                      style: textTheme.titleLarge!
                          .copyWith(fontWeight: FontWeight.w400, height: 1.5)),
                  const SizedBox(height: 10),
                  Text(
                      'We cater specifically to women dealing with health issues such as',
                      style: textTheme.titleLarge!
                          .copyWith(fontWeight: FontWeight.w400, height: 1.5)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      _buildChip('PCOS'),
                      _buildChip('Arthritis'),
                      _buildChip('Hypothyroidism'),
                      _buildChip('Stuck Weight'),
                    ],
                  ),
                  // const SizedBox(height: 20),
                  // Row(
                  //   children: [
                  //     Image.asset(
                  //       MyImgs.ourJourney6,
                  //       width: 111,
                  //     ),
                  //     SizedBox(
                  //       width: 10,
                  //     ),
                  //     Expanded(
                  //       child: Image.asset(
                  //         MyImgs.ourJourney5,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 10),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: Image.asset(
                  //         MyImgs.ourJourney4,
                  //       ),
                  //     ),
                  //     const SizedBox(
                  //       width: 10,
                  //     ),
                  //     Image.asset(
                  //       MyImgs.ourJourney3,
                  //       width: 111,
                  //     ),
                  //
                  //
                  //   ],
                  // ),
                  const SizedBox(height: 20),
                  Text('Overcoming Cultural Barriers to Women\'s Health',
                      style: textTheme.bodyLarge!
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Text(
                      'In many parts of the world, especially in South Asia and the Middle East, cultural norms and societal expectations often limit women\'s access to health and fitness resources. Traditional beliefs may discourage women from attending gyms, participating in public exercise.',
                      style: textTheme.titleLarge!
                          .copyWith(fontWeight: FontWeight.w400, height: 1.5)),
                  const SizedBox(height: 10),
                  Text(
                      'Fit Her is designed to break through these cultural barriers by providing a platform that allows women to prioritize their health without stepping outside the boundaries of their societal norms. We provide:',
                      style: textTheme.titleLarge!
                          .copyWith(fontWeight: FontWeight.w400, height: 1.5)),
                  const SizedBox(height: 10),
                  BulletList(const [
                    'Home-based Solutions',
                    'Cultural Sensitivity',
                    'Affordability',
                    'Accessibility',
                  ], textTheme),
                  const SizedBox(height: 20),
                  // CarouselSlider(
                  //     options: CarouselOptions(
                  //         height: 175,
                  //         autoPlay: true,
                  //         viewportFraction: 0.7,
                  //         enlargeFactor: 0.3,
                  //         enlargeCenterPage: true,
                  //         enlargeStrategy: CenterPageEnlargeStrategy.scale),
                  //     items: [
                  //       Builder(
                  //         builder: (BuildContext context) {
                  //           return Row(
                  //             children: [
                  //               Image.asset(
                  //                 MyImgs.before,
                  //                 scale: 4,
                  //               ),
                  //               Image.asset(
                  //                 MyImgs.after,
                  //                 scale: 4,
                  //               ),
                  //             ],
                  //           );
                  //         },
                  //       )
                  //     ]),
                  // SizedBox(height: 20),
                  Text('Success Stories',
                      style: textTheme.bodyLarge!
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Text(
                      'Since our inception in 2022, Fit Her has proudly helped over 3,000 women achieve remarkable transformations in their health and fitness journeys. These transformations are more than just numbers; they represent real stories of women who have overcome cultural barriers, health challenges, and personal obstacles to reach their goals.',
                      style: textTheme.titleLarge!
                          .copyWith(fontWeight: FontWeight.w400, height: 1.5)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildImage(String assetPath, {String? label}) {
    return Column(
      children: [
        Image.asset(
          assetPath,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
        if (label != null)
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}

class BulletList extends StatelessWidget {
  final List<String> strings;
  final TextTheme textTheme;
  BulletList(
    this.strings,
    this.textTheme,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: strings.map((str) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("• ", style: TextStyle(fontSize: 16)),
            Expanded(
              child: Text(str,
                  style: textTheme.titleLarge!
                      .copyWith(fontWeight: FontWeight.w400, height: 1.5)),
            ),
          ],
        );
      }).toList(),
    );
  }
}

import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/material.dart';

import '../../data/models/nutrition_model.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen(
      {Key? key, required this.nutritionModel, required this.url})
      : super(key: key);
  final NutritionModel nutritionModel;
  final String url;
  @override
  State<NutritionScreen> createState() => _BurgerNutritionScreenState();
}

class _BurgerNutritionScreenState extends State<NutritionScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    NutritionModel data = widget.nutritionModel;

    return Scaffold(
      body: Stack(
        children: [
          // Burger Image
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.60,
            width: double.infinity,
            child: Image.network(
              widget.url,
              fit: BoxFit.cover,
            ),
          ),

          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back,color: Colors.black,),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // Bottom Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title and Quantity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data.category?.name ?? "N/A",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      // Row(
                      //   children: [
                      //     _buildQtyButton(Icons.remove, () {
                      //       if (quantity > 1) {
                      //         setState(() => quantity--);
                      //       }
                      //     }),
                      //     Padding(
                      //       padding: const EdgeInsets.symmetric(horizontal: 12),
                      //       child: Text(
                      //         '$quantity',
                      //         style: const TextStyle(fontSize: 18),
                      //       ),
                      //     ),
                      //     _buildQtyButton(Icons.add, () {
                      //       setState(() => quantity++);
                      //     }),
                      //   ],
                      // ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Calories
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.black),
                        SizedBox(width: 10),
                        Text('Calories', style: TextStyle(fontSize: 16)),
                        Spacer(),
                        Text("${data.nutrition?.calories?.value ?? "N/A"} ${data.nutrition?.calories?.unit??""}",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Nutrients
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _NutrientTile(
                          label: 'Protien',
                          value: "${data.nutrition?.protein?.value ?? "N/A"}${data.nutrition?.protein?.unit??""}"),
                      _NutrientTile(
                          label: 'Fat',
                          value: '${"${data.nutrition?.fat?.value ?? "N/A"}${data.nutrition?.fat?.unit??""}" }'),
                      _NutrientTile(
                          label: 'Carbs',
                          value: "${data.nutrition?.carbs?.value ?? "N/A"}${data.nutrition?.carbs?.unit??""}"),
                      // _NutrientTile(
                      //     label: 'Fiber',
                      //     value: "${data.nutrition?.?.value ?? "N/A"}"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Done Button
                  CustomButton(
                      text: "Done",
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _NutrientTile extends StatelessWidget {
  final String label;
  final String value;

  const _NutrientTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

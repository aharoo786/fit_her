import 'package:flutter/material.dart';

import 'generic_screening_intro.dart';
import 'pcos_config.dart';

/// Entry point for PCOS screening — uses the generic screening system.
class PcosIntroScreen extends StatelessWidget {
  const PcosIntroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GenericScreeningIntro(config: pcosConfig);
  }
}

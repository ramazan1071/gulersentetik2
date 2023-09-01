import 'package:flutter/material.dart';

import '../contans/app_color.dart';


class StandartCircularProgress extends StatelessWidget {
  const StandartCircularProgress({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
          color: AppColors.profilBackground,
        ));
  }
}

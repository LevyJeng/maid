import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/shared/tiles/slider_grid_tile.dart';
import 'package:provider/provider.dart';

class MirostatParameter extends StatelessWidget {
  const MirostatParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AppData, int>(
      selector: (context, appData) => appData.model.mirostat,
      builder: mirostatBuilder,
    );
  }

  Widget mirostatBuilder(BuildContext context, int mirostat, Widget? child) {
    return SliderGridTile(
      labelText: 'Mirostat',
      inputValue: mirostat,
      sliderMin: 0.0,
      sliderMax: 128.0,
      sliderDivisions: 127,
      onValueChanged: (value) {
        LargeLanguageModel.of(context).mirostat = value.round();
      }
    );
  }
}

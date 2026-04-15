// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flex_color_picker/flex_color_picker.dart';

Future<Color?> customcolorPickerAction(
  BuildContext context,
  Future Function() rebuilpage,
  String? textheading,
  String? textSubHeading,
  double? width,
  double? height,
  double? borderRadius,
  double? spacing,
  double? runSpacing,
  double? wheelDiameter,
  double? wheelWidth,
  bool? enableprimary,
  bool? enableaccent,
  bool? enablebw,
  bool? enablecustom,
  bool? enablewheel,
  Color? initialColor,
  bool? isBottomSheet,
  Color? designColor,
) async {
  Color selectedColor = initialColor ?? const Color(0xFF4B39EF);
  bool isConfirmed = false;

  Widget buildColorPicker() {
    return ColorPicker(
      color: selectedColor,
      onColorChanged: (Color color) {
        selectedColor = color;
        rebuilpage(); // Atualiza a cor em tempo real enquanto o usuário mexe!
      },

      // Tamanho e aparência das amostras de cor
      width: width ?? 46,
      height: height ?? 46,
      borderRadius: borderRadius ?? 23,
      spacing: spacing ?? 12,
      runSpacing: runSpacing ?? 12,
      elevation: 3,
      hasBorder: false,

      // Cabeçalho da janela de seleção
      heading: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            textheading ?? 'Escolha a Cor',
            textAlign: TextAlign.center, // Centralizando texto
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  // Fonte um pouco menor
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
          ),
        ),
      ),

      // Subtítulo descritivo do seletor
      subheading: Padding(
        padding: const EdgeInsets.only(bottom: 12.0, top: 12.0),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            textSubHeading ?? 'Selecione uma cor para personalizar o visual',
            textAlign: TextAlign.center, // Centralizando texto
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  // Fonte menor
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.color
                      ?.withOpacity(0.7),
                ),
          ),
        ),
      ),

      // Roda de cor moderna (Color Wheel)
      wheelDiameter: wheelDiameter ?? 240,
      wheelWidth: wheelWidth ?? 24,
      wheelSubheading: Padding(
        padding: const EdgeInsets.only(bottom: 12.0, top: 16.0),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            'Variações de Tom',
            textAlign: TextAlign.center, // Centralizando texto
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.color
                      ?.withOpacity(0.7),
                ),
          ),
        ),
      ),
      wheelHasBorder: false,

      // Nomes das abas (Traduzidos para excelente UX)
      pickerTypeLabels: const <ColorPickerType, String>{
        ColorPickerType.primary: 'Principal',
        ColorPickerType.accent: 'Destaque',
        ColorPickerType.bw: 'P&B',
        ColorPickerType.custom: 'Custom',
        ColorPickerType.wheel: 'Livre',
      },

      // Controla quais abas aparecem
      pickersEnabled: <ColorPickerType, bool>{
        ColorPickerType.primary: enableprimary ?? true,
        ColorPickerType.accent: enableaccent ?? true,
        ColorPickerType.bw: enablebw ?? false,
        ColorPickerType.custom: enablecustom ?? false,
        ColorPickerType.wheel: enablewheel ?? true,
      },

      // Informações da cor e exibição amigável
      showColorCode: true,
      colorCodeReadOnly: false,
      colorCodeHasColor: true,
      showColorName: true,
      showMaterialName: false, // Ocultar formato nativo em inglês

      // Tradução Nativa Absoluta: Mapeando todas as cores famosas para o Português
      customColorSwatchesAndNames: <ColorSwatch<Object>, String>{
        Colors.red: 'Vermelho',
        Colors.pink: 'Rosa',
        Colors.purple: 'Roxo',
        Colors.deepPurple: 'Roxo Escuro',
        Colors.indigo: 'Índigo',
        Colors.blue: 'Azul',
        Colors.lightBlue: 'Azul Claro',
        Colors.cyan: 'Ciano',
        Colors.teal: 'Verde Petróleo',
        Colors.green: 'Verde',
        Colors.lightGreen: 'Verde Claro',
        Colors.lime: 'Lima',
        Colors.yellow: 'Amarelo',
        Colors.amber: 'Âmbar',
        Colors.orange: 'Laranja',
        Colors.deepOrange: 'Laranja Escuro',
        Colors.brown: 'Marrom',
        Colors.grey: 'Cinza',
        Colors.blueGrey: 'Cinza Metálico',
      },

      // Copiar e colar cor rápido e intuitivo
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
        copyButton:
            false, // << REMOVER ESTE BOTÃO E O PASTE FORÇA O TEXTO HEX A FICAR 100% CENTRALIZADO!
        pasteButton: false,
        copyFormat: ColorPickerCopyFormat.hexRRGGBB,
      ),

      // Estilos atualizados para os textos e códigos auxiliares
      materialNameTextStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: designColor ?? Theme.of(context).primaryColor,
          ),
      colorNameTextStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
      colorCodeTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),

      // Removemos os Actions do componente base para usarmos os nossos próprios super elaborados
      actionButtons: const ColorPickerActionButtons(dialogActionButtons: false),
    );
  }

  if (isBottomSheet ?? false) {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: designColor ?? Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    buildColorPicker(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: designColor ??
                                initialColor ??
                                const Color(0xFF4B39EF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 2,
                          ),
                          onPressed: () {
                            isConfirmed = true;
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Confirmar',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  } else {
    // Current General Dialog
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (context, a1, a2, child) {
        final double curve = Curves.easeOutBack.transform(a1.value);
        return Transform.scale(
          scale: 0.85 + (0.15 * curve), // Cresce suavemente
          child: Opacity(
            opacity: a1.value, // Fade na entrada
            child: child,
          ),
        );
      },
      pageBuilder: (context, a1, a2) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          titlePadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          elevation: 8,
          content: SizedBox(
            width: 320,
            child: SingleChildScrollView(
              child: buildColorPicker(),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                    width: 16), // Espaço entre os botões para respirar
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: designColor ??
                          initialColor ??
                          const Color(
                              0xFF4B39EF), // << COR INICIAL APLICADA AQUI ELEGANTEMENTE!
                      foregroundColor:
                          Colors.white, // Texto branco sobre o Color inicial
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    onPressed: () {
                      isConfirmed = true;
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Confirmar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Se o usuário clicar em Cancelar ou arrastar para baixo/fechar o pop-up por fora, nós revertemos a cor na interface pro valor inicial.
  if (!isConfirmed) {
    selectedColor = initialColor ?? const Color(0xFF4B39EF);
    rebuilpage();
  }

  return selectedColor;
}
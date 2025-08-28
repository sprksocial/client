import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/glass_text_button.dart';

class _BackgroundWrapper extends StatelessWidget {
  final Widget? child;
  final Widget background;

  const _BackgroundWrapper({this.child, required this.background});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: background),
          Align(alignment: Alignment.bottomCenter, child: child),
        ],
      ),
    );
  }
}

@UseCase(name: 'on_image_background', type: GlassTextButton)
Widget buildGlassTextButtonOnImageBackgroundUseCase(BuildContext context) {
  return _BackgroundWrapper(
    background: Image.network(
      'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&q=80',
      fit: BoxFit.cover,
      // Add a loading builder for a better user experience in Widgetbook
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.red.shade100,
          alignment: Alignment.center,
          child: const Text('Failed to load image'),
        );
      },
    ),
    child: Center(
      child: GlassTextButton(
        label: context.knobs.string(label: 'Label', initialValue: 'Continue'),
        onTap: context.knobs.boolean(label: 'Focus', initialValue: true)
            ? () => print('GlassTextButton tapped!')
            : null,
      ),
    ),
  );
}

@UseCase(name: 'on_gradient_background', type: GlassTextButton)
Widget buildGlassTextButtonOnGradientBackgroundUseCase(BuildContext context) {
  return _BackgroundWrapper(
    background: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.pinkAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
    child: Center(
      child: GlassTextButton(
        label: context.knobs.string(label: 'Label', initialValue: 'Continue'),
        onTap: context.knobs.boolean(label: 'Focus', initialValue: true)
            ? () => print('GlassTextButton tapped!')
            : null,
      ),
    ),
  );
}

@UseCase(name: 'on_solid_color_background', type: GlassTextButton)
Widget buildGlassTextButtonOnSolidColorBackgroundUseCase(BuildContext context) {
  return _BackgroundWrapper(
    background: Container(
      color: context.knobs.color(
        label: 'Background Color',
        initialValue: const Color(0xFF1A1A2E),
      ),
    ),
    child: Center(
      child: GlassTextButton(
        label: context.knobs.string(label: 'Label', initialValue: 'Continue'),
        onTap: context.knobs.boolean(label: 'Focus', initialValue: true)
            ? () => print('GlassTextButton tapped!')
            : null,
      ),
    ),
  );
}

@UseCase(name: 'on_complex_ui', type: GlassTextButton)
Widget buildGlassTextButtonOnComplexUiUseCase(BuildContext context) {
  return _BackgroundWrapper(
    background: Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Container(
          width: 300,
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Join Our Community',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Tap the button below to sign up and get started.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 16),
              GlassTextButton(
                label: context.knobs.string(
                  label: 'Label',
                  initialValue: 'Continue',
                ),
                onTap: context.knobs.boolean(label: 'Focus', initialValue: true)
                    ? () => print('GlassTextButton tapped!')
                    : null,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

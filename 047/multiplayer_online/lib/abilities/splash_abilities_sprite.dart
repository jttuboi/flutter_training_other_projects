import 'package:bonfire/bonfire.dart';

class SlashAbilitySprite {
  const SlashAbilitySprite._();

  static Future<SpriteAnimation> get right => _sequenceImage('atack_effect_right.png');
  // static Future<SpriteAnimation> get left => _sequenceImage('atack_effect_left.png');
  // static Future<SpriteAnimation> get up => _sequenceImage('atack_effect_top.png');
  // static Future<SpriteAnimation> get down => _sequenceImage('atack_effect_bottom.png');

  static Future<SpriteAnimation> _sequenceImage(String filename) {
    return SpriteAnimation.load(
        'abilities/$filename',
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.15,
          textureSize: Vector2(16, 16),
          texturePosition: Vector2(0, 0),
        ));
  }
}

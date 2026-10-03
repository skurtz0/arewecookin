import 'package:flutter/material.dart';

/// Cooking and Utensil vector icons using Material Icons
class CookingIcons {
  static const IconData chefHat = Icons.dinner_dining_rounded;
  static const IconData utensils = Icons.restaurant_rounded;
  static const IconData clock = Icons.access_time_rounded;
  static const IconData users = Icons.people_outline_rounded;
  static const IconData gauge = Icons.speed_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData filter = Icons.filter_list_rounded;
  static const IconData fire = Icons.local_fire_department_rounded;
  static const IconData timer = Icons.timer_outlined;
  static const IconData timerActive = Icons.timer_rounded;
  static const IconData checkCircle = Icons.check_circle_rounded;
  static const IconData checkCircleOutline = Icons.check_circle_outline_rounded;
  static const IconData proTip = Icons.lightbulb_rounded;
  static const IconData substitute = Icons.sync_alt_rounded;
  static const IconData play = Icons.play_arrow_rounded;
  static const IconData pause = Icons.pause_rounded;
  static const IconData replay = Icons.replay_rounded;
  static const IconData pantry = Icons.kitchen_rounded;
  static const IconData compass = Icons.explore_rounded;
  static const IconData info = Icons.info_outline_rounded;

  /// Map string tool identifiers from recipes to Material Icons
  static IconData getToolIcon(String toolKey) {
    switch (toolKey.toLowerCase().trim()) {
      case 'knife':
      case 'bicak':
        return Icons.restaurant_menu_rounded;
      case 'pan':
      case 'tava':
        return Icons.soup_kitchen_rounded;
      case 'pot':
      case 'tencere':
        return Icons.ramen_dining_rounded;
      case 'oven':
      case 'firin':
        return Icons.microwave_rounded;
      case 'whisk':
      case 'cirpici':
        return Icons.blender_rounded;
      case 'bowl':
      case 'kase':
        return Icons.rice_bowl_rounded;
      case 'plate':
      case 'tabak':
      case 'servis':
        return Icons.dinner_dining_rounded;
      case 'spoon':
      case 'kasik':
        return Icons.flatware_rounded;
      case 'microwave':
      case 'mikrodalga':
        return Icons.microwave_rounded;
      case 'blender':
        return Icons.blender_rounded;
      case 'grater':
      case 'rende':
        return Icons.grid_view_rounded;
      case 'scale':
      case 'terazi':
        return Icons.scale_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }

  /// Get localized tool name (Turkish or English fallback)
  static String getToolLabel(String toolKey, [String? locale]) {
    final isTr = locale == null || locale.toLowerCase().startsWith('tr');
    switch (toolKey.toLowerCase().trim()) {
      case 'knife':
      case 'bicak':
        return isTr ? 'Şef Bıçağı & Kesme Tahtası' : 'Chef Knife & Board';
      case 'pan':
      case 'tava':
        return isTr ? 'Tava / Wok' : 'Skillet / Pan';
      case 'pot':
      case 'tencere':
        return isTr ? 'Derin Tencere' : 'Deep Cooking Pot';
      case 'oven':
      case 'firin':
        return isTr ? 'Fırın & Tepsi' : 'Oven & Baking Sheet';
      case 'whisk':
      case 'cirpici':
        return isTr ? 'El Çırpıcısı / Mikser' : 'Whisk / Mixer';
      case 'bowl':
      case 'kase':
        return isTr ? 'Geniş Karıştırma Kabı' : 'Mixing Bowl';
      case 'plate':
      case 'tabak':
      case 'servis':
        return isTr ? 'Servis Tabağı & Sunum' : 'Serving Plate';
      case 'spoon':
      case 'kasik':
        return isTr ? 'Tahta Kaşık / Spatula' : 'Wooden Spoon / Spatula';
      case 'microwave':
      case 'mikrodalga':
        return isTr ? 'Mikrodalga' : 'Microwave';
      case 'blender':
        return isTr ? 'El Blenderı' : 'Immersion Blender';
      case 'grater':
      case 'rende':
        return isTr ? 'İnce / Kalın Rende' : 'Box Grater';
      case 'scale':
      case 'terazi':
        return isTr ? 'Mutfak Terazisi' : 'Kitchen Scale';
      default:
        return isTr ? 'Mutfak Gereci' : 'Kitchen Utensil';
    }
  }
}

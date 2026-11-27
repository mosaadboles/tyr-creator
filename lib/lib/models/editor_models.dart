import 'dart:io';
import 'package:flutter/material.dart';

enum MediaMode { imagePost, videoFrame }

enum TemplateType {
  quote('اقتباس'),
  article('مقال'),
  pressNews('خبر صحفي'),
  breaking('عاجل');

  final String label;
  const TemplateType(this.label);
}

enum AspectRatioPreset {
  ratio4x5('4:5', 4 / 5),
  ratio1x1('1:1', 1 / 1),
  ratio16x9('16:9', 16 / 9),
  ratio9x16('9:16', 9 / 16);

  final String label;
  final double ratio;
  const AspectRatioPreset(this.label, this.ratio);
}

class FontOption {
  final String family;
  final String displayName;
  final bool isArabicFriendly;

  const FontOption({
    required this.family,
    required this.displayName,
    this.isArabicFriendly = true,
  });
}

final List<FontOption> kAvailableFonts = [
  const FontOption(family: 'Amiri', displayName: 'Amiri'),
  const FontOption(family: 'Tajawal', displayName: 'Tajawal'),
  const FontOption(family: 'Cairo', displayName: 'Cairo'),
  const FontOption(
    family: 'Montserrat',
    displayName: 'Montserrat',
    isArabicFriendly: false,
  ),
];

class EditorStateData {
  MediaMode mode;
  TemplateType templateType;
  AspectRatioPreset aspectRatio;
  String headline;
  String subheadline;
  String footerLeftText;
  String footerRightText;
  String fontFamily;
  double fontSize;
  Color textColor;
  Color accentColor;
  File? customImageFile;
  File? customLogoFile;
  File? customVideoFile;
  bool showLogo;
  bool showQuotes;
  bool highlightText;
  Color highlightColor;

  EditorStateData({
    this.mode = MediaMode.imagePost,
    this.templateType = TemplateType.quote,
    this.aspectRatio = AspectRatioPreset.ratio4x5,
    this.headline =
        'تصميم ثوري جديد: قالب \'تيار\' المطوّر لرفع نسب المشاهدة والمشاركة عاليًا',
    this.subheadline = 'استلقط، والتهوع بنجال حدية السي',
    this.footerLeftText = 'www.tyrr.com',
    this.footerRightText = 'تيار | Tyr',
    this.fontFamily = 'Cairo',
    this.fontSize = 22.0,
    this.textColor = Colors.white,
    this.accentColor = const Color(0xFFD4AF37),
    this.customImageFile,
    this.customLogoFile,
    this.customVideoFile,
    this.showLogo = true,
    this.showQuotes = true,
    this.highlightText = false,
    this.highlightColor = const Color(0xFFFFD54F),
  });
}

class DraftItem {
  final String id;
  final String title;
  final DateTime savedAt;
  final TemplateType templateType;
  final AspectRatioPreset aspectRatio;
  final String headline;
  final String subheadline;
  final String fontFamily;
  final double fontSize;
  final int textColorValue;
  final bool highlightText;
  final int highlightColorValue;

  DraftItem({
    required this.id,
    required this.title,
    required this.savedAt,
    required this.templateType,
    required this.aspectRatio,
    required this.headline,
    required this.subheadline,
    required this.fontFamily,
    required this.fontSize,
    required this.textColorValue,
    required this.highlightText,
    required this.highlightColorValue,
  });
}

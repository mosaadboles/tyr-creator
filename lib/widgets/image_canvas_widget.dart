import 'package:flutter/material.dart';
import '../models/editor_models.dart';

class ImageCanvasWidget extends StatelessWidget {
  final EditorStateData state;

  const ImageCanvasWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final bool isBreaking = state.templateType == TemplateType.breaking;
    final bool isQuote = state.templateType == TemplateType.quote;

    return Container(
      decoration: BoxDecoration(
        color: isBreaking ? const Color(0xFF8E0E00) : const Color(0xFF14171F),
        border: Border.all(color: state.accentColor, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: isBreaking ? const Color(0xFFB71C1C) : const Color(0xFF1F2430),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: state.accentColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    state.templateType.label,
                    style: TextStyle(
                      fontFamily: state.fontFamily,
                      color: isBreaking ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (state.showLogo)
                  state.customLogoFile != null
                      ? Image.file(
                          state.customLogoFile!,
                          height: 24,
                          fit: BoxFit.contain,
                        )
                      : Text(
                          state.footerRightText,
                          style: TextStyle(
                            fontFamily: state.fontFamily,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Stack(
              fit: StackFit.expand,
              children: [
                state.customImageFile != null
                    ? Image.file(
                        state.customImageFile!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF2B3245),
                              Color(0xFF14171F),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 40,
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'اختر صورة من المعرض أو استخدم المعاينة',
                              style: TextStyle(
                                fontFamily: state.fontFamily,
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 36,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          isBreaking
                              ? const Color(0xFF8E0E00)
                              : const Color(0xFF14171F),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: _buildStyledHeadline(isQuote),
                    ),
                  ),
                  if (state.subheadline.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      state.subheadline,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: state.fontFamily,
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: (state.fontSize * 0.62).clamp(11.0, 16.0),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              border: Border(
                top: BorderSide(
                  color: state.accentColor.withValues(alpha: 0.45),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.footerLeftText,
                  style: TextStyle(
                    fontFamily: state.fontFamily,
                    color: state.accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  state.aspectRatio.label,
                  style: TextStyle(
                    fontFamily: state.fontFamily,
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledHeadline(bool isQuote) {
    final String rawText = isQuote && state.showQuotes
        ? '«${state.headline}»'
        : state.headline;

    final TextStyle baseStyle = TextStyle(
      fontFamily: state.fontFamily,
      fontSize: state.fontSize,
      fontWeight: FontWeight.bold,
      color: state.textColor,
      height: 1.3,
    );

    if (!state.highlightText) {
      return Text(
        rawText,
        textAlign: TextAlign.center,
        style: baseStyle,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: state.highlightColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        rawText,
        textAlign: TextAlign.center,
        style: baseStyle.copyWith(color: Colors.black),
      ),
    );
  }
}

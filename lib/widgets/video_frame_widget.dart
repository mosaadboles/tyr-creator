import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/editor_models.dart';

class VideoFrameWidget extends StatelessWidget {
  final EditorStateData state;
  final VideoPlayerController? videoController;

  const VideoFrameWidget({
    super.key,
    required this.state,
    required this.videoController,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBreaking = state.templateType == TemplateType.breaking;
    final bool hasVideo =
        videoController != null && videoController!.value.isInitialized;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0E1015),
        border: Border.all(color: state.accentColor, width: 2.0),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            color: isBreaking ? const Color(0xFFB71C1C) : const Color(0xFF1A1E28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                      fontSize: 11,
                    ),
                  ),
                ),
                if (state.showLogo)
                  state.customLogoFile != null
                      ? Image.file(
                          state.customLogoFile!,
                          height: 22,
                          fit: BoxFit.contain,
                        )
                      : Text(
                          state.footerRightText,
                          style: TextStyle(
                            fontFamily: state.fontFamily,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                hasVideo
                    ? FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: videoController!.value.size.width,
                          height: videoController!.value.size.height,
                          child: VideoPlayer(videoController!),
                        ),
                      )
                    : Container(
                        color: const Color(0xFF181C26),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.videocam_outlined,
                              size: 40,
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'اختر فيديو للمعاينة وإضافة الإطار',
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
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: state.highlightText
                          ? state.highlightColor
                          : Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: state.accentColor.withValues(alpha: 0.8),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      state.headline,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: state.fontFamily,
                        fontSize: (state.fontSize * 0.75).clamp(13.0, 20.0),
                        fontWeight: FontWeight.bold,
                        color: state.highlightText ? Colors.black : state.textColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: const Color(0xFF14171F),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.footerLeftText,
                  style: TextStyle(
                    fontFamily: state.fontFamily,
                    color: state.accentColor,
                    fontSize: 11,
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
}

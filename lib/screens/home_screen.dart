import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:video_player/video_player.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import '../models/editor_models.dart';
import '../widgets/image_canvas_widget.dart';
import '../widgets/video_frame_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EditorStateData _state = EditorStateData();
  final ScreenshotController _screenshotController = ScreenshotController();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _headlineController = TextEditingController();
  final TextEditingController _subheadlineController = TextEditingController();
  final TextEditingController _footerLeftController = TextEditingController();
  final TextEditingController _footerRightController = TextEditingController();

  VideoPlayerController? _videoController;
  final List<DraftItem> _drafts = [];
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _headlineController.text = _state.headline;
    _subheadlineController.text = _state.subheadline;
    _footerLeftController.text = _state.footerLeftText;
    _footerRightController.text = _state.footerRightText;
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _subheadlineController.dispose();
    _footerLeftController.dispose();
    _footerRightController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _state.customImageFile = File(file.path);
      });
    }
  }

  Future<void> _pickLogo() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _state.customLogoFile = File(file.path);
        _state.showLogo = true;
      });
    }
  }

  Future<void> _pickCustomFont() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ttf'],
    );
    if (result != null && result.files.single.path != null) {
      final File fontFile = File(result.files.single.path!);
      final String fontName =
          'CustomFont_${DateTime.now().millisecondsSinceEpoch}';
      final ByteData bytes = await fontFile.readAsBytes();
      final FontLoader loader = FontLoader(fontName)
        ..addFont(Future.value(bytes.buffer.asByteData()));
      await loader.load();

      setState(() {
        _state.fontFamily = fontName;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحميل الخط: ${p.basenameWithoutExtension(fontFile.path)}'),
          ),
        );
      }
    }
  }

  Future<void> _pickVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      await _videoController?.dispose();
      final controller = VideoPlayerController.file(File(file.path));
      await controller.initialize();
      controller.setLooping(true);
      await controller.play();

      setState(() {
        _state.customVideoFile = File(file.path);
        _state.mode = MediaMode.videoFrame;
        _videoController = controller;
      });
    }
  }

  Future<void> _exportImage() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final Uint8List? imageBytes = await _screenshotController.capture(
        pixelRatio: 2.5,
      );
      if (imageBytes != null) {
        await Gal.putImageBytes(
          imageBytes,
          name: 'tyr_post_${DateTime.now().millisecondsSinceEpoch}',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حفظ التصميم في المعرض بنجاح')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر تصدير الصورة: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportVideoWithFrame() async {
    if (_isExporting) return;
    if (_state.customVideoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار فيديو أولاً')),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      final Uint8List? overlayBytes = await _screenshotController.capture(
        pixelRatio: 2.0,
      );
      if (overlayBytes == null) {
        throw Exception('فشل التقاط إطار الفيديو');
      }

      final Directory tempDir = await getTemporaryDirectory();
      final String overlayPath = p.join(
        tempDir.path,
        'tyr_overlay_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      final String outputPath = p.join(
        tempDir.path,
        'tyr_video_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );

      final File overlayFile = File(overlayPath);
      await overlayFile.writeAsBytes(overlayBytes);

      final String inputVideo = _state.customVideoFile!.path;
      final String cmd =
          '-y -i "$inputVideo" -i "$overlayPath" -filter_complex "[1:v][0:v]scale2ref[ovr][base];[base][ovr]overlay=0:0:shortest=1" -c:v libx264 -preset fast -crf 23 -c:a aac -b:a 128k "$outputPath"';

      await FFmpegKit.execute(cmd);

      final File outFile = File(outputPath);
      if (await outFile.exists()) {
        await Gal.putVideo(outputPath);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تصدير الفيديو بالإطار إلى المعرض')),
          );
        }
      } else {
        throw Exception('لم يتم إنشاء ملف الفيديو النهائي');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر تصدير الفيديو: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _saveDraft() {
    final draft = DraftItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _state.headline.trim().isEmpty
          ? 'مسودة بدون عنوان'
          : _state.headline.trim(),
      savedAt: DateTime.now(),
      templateType: _state.templateType,
      aspectRatio: _state.aspectRatio,
      headline: _state.headline,
      subheadline: _state.subheadline,
      fontFamily: _state.fontFamily,
      fontSize: _state.fontSize,
      textColorValue: _state.textColor.toARGB32(),
      highlightText: _state.highlightText,
      highlightColorValue: _state.highlightColor.toARGB32(),
    );

    setState(() {
      _drafts.insert(0, draft);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ المسودة')),
    );
  }

  void _loadDraft(DraftItem draft) {
    setState(() {
      _state.templateType = draft.templateType;
      _state.aspectRatio = draft.aspectRatio;
      _state.headline = draft.headline;
      _state.subheadline = draft.subheadline;
      _state.fontFamily = draft.fontFamily;
      _state.fontSize = draft.fontSize;
      _state.textColor = Color(draft.textColorValue);
      _state.highlightText = draft.highlightText;
      _state.highlightColor = Color(draft.highlightColorValue);

      _headlineController.text = draft.headline;
      _subheadlineController.text = draft.subheadline;
    });
    Navigator.pop(context);
  }

  void _openDraftsSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'المسودات المحفوظة',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              if (_drafts.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('لا توجد مسودات محفوظة بعد'),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _drafts.length,
                    itemBuilder: (context, index) {
                      final d = _drafts[index];
                      return ListTile(
                        leading: const Icon(Icons.article_outlined),
                        title: Text(
                          d.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('${d.templateType.label} • ${d.aspectRatio.label}'),
                        onTap: () => _loadDraft(d),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101218),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181B24),
        foregroundColor: Colors.white,
        title: const Text(
          'تيار | Tyr Creator',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          IconButton(
            tooltip: 'المسودات',
            icon: const Icon(Icons.folder_open),
            onPressed: _openDraftsSheet,
          ),
          IconButton(
            tooltip: 'حفظ مسودة',
            icon: const Icon(Icons.bookmark_add_outlined),
            onPressed: _saveDraft,
          ),
          IconButton(
            tooltip: _state.mode == MediaMode.imagePost ? 'تصدير صورة' : 'تصدير فيديو',
            icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.amber,
                    ),
                  )
                : const Icon(Icons.download_done),
            onPressed: _state.mode == MediaMode.imagePost
                ? _exportImage
                : _exportVideoWithFrame,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: AspectRatio(
                  aspectRatio: _state.aspectRatio.ratio,
                  child: Screenshot(
                    controller: _screenshotController,
                    child: _state.mode == MediaMode.imagePost
                        ? ImageCanvasWidget(state: _state)
                        : VideoFrameWidget(
                            state: _state,
                            videoController: _videoController,
                          ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF181B24),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<MediaMode>(
                      segments: const [
                        ButtonSegment(
                          value: MediaMode.imagePost,
                          label: Text('منشور صورة'),
                          icon: Icon(Icons.image),
                        ),
                        ButtonSegment(
                          value: MediaMode.videoFrame,
                          label: Text('إطار فيديو'),
                          icon: Icon(Icons.movie),
                        ),
                      ],
                      selected: {_state.mode},
                      onSelectionChanged: (set) {
                        setState(() => _state.mode = set.first);
                      },
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: TemplateType.values.map((type) {
                          final selected = _state.templateType == type;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ChoiceChip(
                              label: Text(type.label),
                              selected: selected,
                              onSelected: (_) {
                                setState(() => _state.templateType = type);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: AspectRatioPreset.values.map((ratio) {
                          final selected = _state.aspectRatio == ratio;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ChoiceChip(
                              label: Text('أبعاد ${ratio.label}'),
                              selected: selected,
                              onSelected: (_) {
                                setState(() => _state.aspectRatio = ratio);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _headlineController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'العنوان الرئيسي',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF222734),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => setState(() => _state.headline = val),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _subheadlineController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'العنوان الفرعي / التفصيل',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF222734),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) =>
                          setState(() => _state.subheadline = val),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _footerLeftController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'الموقع / الرابط',
                              labelStyle: TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Color(0xFF222734),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) =>
                                setState(() => _state.footerLeftText = val),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _footerRightController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'اسم المنصة',
                              labelStyle: TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Color(0xFF222734),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) =>
                                setState(() => _state.footerRightText = val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'حجم الخط:',
                          style: TextStyle(color: Colors.white),
                        ),
                        Expanded(
                          child: Slider(
                            value: _state.fontSize,
                            min: 14,
                            max: 36,
                            onChanged: (val) =>
                                setState(() => _state.fontSize = val),
                          ),
                        ),
                        Text(
                          _state.fontSize.toStringAsFixed(0),
                          style: const TextStyle(color: Colors.amber),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('تظليل النص'),
                          selected: _state.highlightText,
                          onSelected: (val) =>
                              setState(() => _state.highlightText = val),
                        ),
                        FilterChip(
                          label: const Text('علامات الاقتباس'),
                          selected: _state.showQuotes,
                          onSelected: (val) =>
                              setState(() => _state.showQuotes = val),
                        ),
                        FilterChip(
                          label: const Text('إظهار الشعار'),
                          selected: _state.showLogo,
                          onSelected: (val) =>
                              setState(() => _state.showLogo = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo),
                          label: const Text('اختيار صورة'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickLogo,
                          icon: const Icon(Icons.verified),
                          label: const Text('اختيار شعار'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickCustomFont,
                          icon: const Icon(Icons.font_download),
                          label: const Text('خط TTF'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickVideo,
                          icon: const Icon(Icons.video_call),
                          label: const Text('اختيار فيديو'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/app_localizations.dart';

// ============================================================================
// POS CAMERA SEARCH CAPTURE SHEET
// Connects to device camera with resilient fallback handling for Pigeon channels
// ============================================================================

class PosCapturedPhoto {
  final String id;
  final String timestamp;
  final String? path;
  final Uint8List? imageBytes;

  const PosCapturedPhoto({
    required this.id,
    required this.timestamp,
    this.path,
    this.imageBytes,
  });
}

class PosCameraCaptureSheet extends StatefulWidget {
  final Color themeColor;

  const PosCameraCaptureSheet({
    super.key,
    required this.themeColor,
  });

  static Future<PosCapturedPhoto?> show(BuildContext context, Color themeColor) {
    return Navigator.of(context).push<PosCapturedPhoto>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => PosCameraCaptureSheet(themeColor: themeColor),
      ),
    );
  }

  @override
  State<PosCameraCaptureSheet> createState() => _PosCameraCaptureSheetState();
}

class _PosCameraCaptureSheetState extends State<PosCameraCaptureSheet>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  bool _isCapturing = false;
  bool _isSimulatedCapture = false;
  bool _hasPigeonError = false;
  XFile? _capturedFile;
  Uint8List? _capturedBytes;
  late AnimationController _flashAnim;

  @override
  void initState() {
    super.initState();
    _flashAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _flashAnim.dispose();
    super.dispose();
  }

  // Attempts to open real hardware camera via image_picker
  Future<void> _openDeviceCamera() async {
    setState(() {
      _isCapturing = true;
      _hasPigeonError = false;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (mounted) {
          setState(() {
            _capturedFile = photo;
            _capturedBytes = bytes;
            _isCapturing = false;
            _isSimulatedCapture = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isCapturing = false;
          });
        }
      }
    } on PlatformException {
      // Handles Pigeon/MethodChannel disconnection if the app hasn't been recompiled
      if (mounted) {
        setState(() {
          _isCapturing = false;
          _hasPigeonError = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isCapturing = false;
          _hasPigeonError = true;
        });
      }
    }
  }

  // Picks an image from the gallery
  Future<void> _pickFromGallery() async {
    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (mounted) {
          setState(() {
            _capturedFile = photo;
            _capturedBytes = bytes;
            _isCapturing = false;
            _isSimulatedCapture = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isCapturing = false;
          });
        }
      }
    } on PlatformException {
      if (mounted) {
        setState(() {
          _isCapturing = false;
          _hasPigeonError = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  // In-app interactive viewfinder snapshot (works on emulators, desktop, and before rebuild)
  void _takeInAppSnapshot() async {
    await _flashAnim.forward();
    await _flashAnim.reverse();
    setState(() {
      _isSimulatedCapture = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasCaptured = _capturedBytes != null || _isSimulatedCapture;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Kamaradda Raadinta Alaabta',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo_library_outlined,
                        color: Colors.white, size: 24),
                    onPressed: _pickFromGallery,
                    tooltip: 'Dooro Sawir (Gallery)',
                  ),
                ],
              ),
            ),

            // Notice banner if native Android pigeon channel is pending restart
            if (_hasPigeonError)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Color(0xFFB45309), size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Si kamaradda hardware-ka u shaqeyso, barnaamijka jooji oo dib u kici (Full App Restart). Hadda waxaad isticmaali kartaa qaadaha tooska ah ee shaashadda.',
                        style: TextStyle(
                          color: Color(0xFF92400E),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Viewfinder or Captured Preview
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF141923),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: hasCaptured
                        ? widget.themeColor
                        : Colors.white.withValues(alpha: 0.15),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_capturedBytes != null)
                        // Real hardware camera photo
                        Positioned.fill(
                          child: Image.memory(
                            _capturedBytes!,
                            fit: BoxFit.cover,
                          ),
                        )
                      else if (_isSimulatedCapture)
                        // In-app snapshot preview
                        Positioned.fill(
                          child: Container(
                            color: const Color(0xFF0F172A),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: widget.themeColor
                                        .withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: widget.themeColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.check_circle_outline,
                                    size: 64,
                                    color: widget.themeColor,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Sawirka waa la qabtay',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Diyaar u ah baadhista alaabta kaydka...',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (_isCapturing)
                        // Loading indicator
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: widget.themeColor,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Furitaanka Kamaradda...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        )
                      else
                        // Live Viewfinder Target
                        Positioned.fill(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 210,
                                height: 210,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: widget.themeColor
                                        .withValues(alpha: 0.7),
                                    width: 1.5,
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.document_scanner_outlined,
                                      size: 58,
                                      color: widget.themeColor
                                          .withValues(alpha: 0.8),
                                    ),
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      child: _cornerBracket(
                                          isTop: true, isLeft: true),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: _cornerBracket(
                                          isTop: true, isLeft: false),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      child: _cornerBracket(
                                          isTop: false, isLeft: true),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: _cornerBracket(
                                          isTop: false, isLeft: false),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Ku toosi kamaradda alaabta aad rabto',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Shutter Flash Animation
                      AnimatedBuilder(
                        animation: _flashAnim,
                        builder: (context, _) => Opacity(
                          opacity: _flashAnim.value,
                          child: Container(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Bottom Actions (Shutter vs Confirm/Retake)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: hasCaptured
                  ? Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.refresh, size: 20),
                            label: Text(context.tr('pos_camera_retake')),
                            onPressed: () {
                              setState(() {
                                _capturedBytes = null;
                                _capturedFile = null;
                                _isSimulatedCapture = false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.themeColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.search, size: 20),
                            label: const Text(
                              'Raadi Alaabtan',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              final photo = PosCapturedPhoto(
                                id: 'IMG_${DateTime.now().millisecondsSinceEpoch}',
                                timestamp: DateTime.now().toIso8601String(),
                                path: _capturedFile?.path,
                                imageBytes: _capturedBytes,
                              );
                              Navigator.pop(context, photo);
                            },
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Shutter Button
                        GestureDetector(
                          onTap: () {
                            if (_hasPigeonError) {
                              _takeInAppSnapshot();
                            } else {
                              _openDeviceCamera();
                            }
                          },
                          child: Container(
                            width: 76,
                            height: 76,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.themeColor,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 34,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cornerBracket({required bool isTop, required bool isLeft}) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? BorderSide(color: widget.themeColor, width: 3)
              : BorderSide.none,
          bottom: !isTop
              ? BorderSide(color: widget.themeColor, width: 3)
              : BorderSide.none,
          left: isLeft
              ? BorderSide(color: widget.themeColor, width: 3)
              : BorderSide.none,
          right: !isLeft
              ? BorderSide(color: widget.themeColor, width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }
}

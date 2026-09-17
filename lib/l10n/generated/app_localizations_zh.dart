// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Artboard';

  @override
  String get play => '播放';

  @override
  String get pause => '暂停';

  @override
  String get penTool => '画笔';

  @override
  String get eraserTool => '橡皮擦';

  @override
  String get undo => '撤销';

  @override
  String get clearCanvas => '清空画布';

  @override
  String get surpriseMe => '随机灵感';

  @override
  String get exportLoop => '导出循环为 WAV';

  @override
  String get exportStarted => '正在渲染循环…';

  @override
  String get exportDone => '循环已导出';

  @override
  String get tempo => '速度';

  @override
  String get decreaseTempo => '减慢速度';

  @override
  String get increaseTempo => '加快速度';

  @override
  String get chooseScale => '选择音阶';

  @override
  String get chooseTimbre => '选择音色';

  @override
  String get scaleMajor => '大调';

  @override
  String get scaleMinor => '小调';

  @override
  String get scalePentatonicMajor => '大调五声音阶';

  @override
  String get scalePentatonicMinor => '小调五声音阶';

  @override
  String get scaleDorian => '多利亚调式';

  @override
  String get scaleBlues => '布鲁斯音阶';

  @override
  String get timbreSine => '正弦波';

  @override
  String get timbreTriangle => '三角波';

  @override
  String get timbreSquare => '方波';

  @override
  String get timbreSawtooth => '锯齿波';

  @override
  String get octaveUp => '升高八度';

  @override
  String get octaveDown => '降低八度';

  @override
  String layerLabel(int number) {
    return '第 $number 层';
  }

  @override
  String get strokeThin => '细笔画';

  @override
  String get strokeMedium => '中等笔画';

  @override
  String get strokeThick => '粗笔画';

  @override
  String get saveDrawing => '保存画作';

  @override
  String get restoreDrawing => '恢复已保存的画作';

  @override
  String get drawingSaved => '画作已保存';

  @override
  String get drawingRestored => '画作已恢复';

  @override
  String get nothingToRestore => '还没有保存过画作';

  @override
  String get helpTooltip => '玩法说明';

  @override
  String get helpBody => '在画纸上作画，然后按播放。扫描线会把你的画变成音乐：高度决定音高，颜色决定乐器。';

  @override
  String get close => '关闭';
}

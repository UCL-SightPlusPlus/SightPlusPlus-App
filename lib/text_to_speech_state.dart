import 'package:text_to_speech/text_to_speech.dart';
import 'package:translator/translator.dart';

class TextToSpeechState{
  final TextToSpeech _tts = TextToSpeech();
  var languages = [];
  String _languageCode = '';
  List<String> languageCodes = [];
  String? voice;


  void initTextToSpeech({String languageCode = "en"}) async{
    // get voice
    if(languageCode == 'zh'){
      languageCode = 'zh-cn';
    }
    _languageCode = languageCode;
    voice = await getVoiceByLang(_languageCode);
  }

  void start(String message) {
    String after = '';
    _tts.setVolume(1.0);
    GoogleTranslator().translate(message, to:'zh-cn').then((value){
      after = '$value';
      _tts.speak(after);
    });
  }

  void stop(){
    _tts.stop();
  }

  Future<String?> getVoiceByLang(String lang) async {
    List<String> voices = await _tts.getVoiceByLang(_languageCode);
    if (voices.isNotEmpty) {
      return voices.first;
    }
    return null;
  }
}
import 'dart:io';

import 'package:ctue_app/features/speech/business/entities/voice_entity.dart';

class GetVoiceParams {
  // final String speechRegion;
  // final String speechKey;
  GetVoiceParams();
}

class TTSParams {
  final VoiceEntity voice;
  final String text;
  final double? rate;

  TTSParams({required this.voice, required this.text, this.rate = 1.0});
}

class EvaluateSpeechPronunParams {
  final File audio;
  final String text;
  final String accessToken;

  EvaluateSpeechPronunParams(
      {required this.audio, required this.text, required this.accessToken});
}

class GetUserProStatisticParams {
  final String accessToken;

  GetUserProStatisticParams({required this.accessToken});
}

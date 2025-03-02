import 'package:ctue_app/core/constants/response.dart';
import 'package:ctue_app/core/params/speech_params.dart';
import 'package:ctue_app/features/speech/business/repositories/speech_repository.dart';
import 'package:ctue_app/features/speech/data/datasources/speech_local_data_source.dart';
import 'package:ctue_app/features/speech/data/datasources/speech_remote_data_source.dart';
import 'package:ctue_app/features/speech/data/models/pronuc_statistics_model.dart';
import 'package:ctue_app/features/speech/data/models/pronunc_assessment_model.dart';
import 'package:ctue_app/features/speech/data/models/voice_model.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/connection/network_info.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failure.dart';

class SpeechRepositoryImpl implements SpeechRepository {
  final SpeechRemoteDataSource remoteDataSource;
  final SpeechLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  SpeechRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ResponseDataModel<List<VoiceModel>>>> getVoices(
      {required GetVoiceParams getVoiceParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        ResponseDataModel<List<VoiceModel>> remoteSpeech =
            await remoteDataSource.getVoices(getVoiceParams: getVoiceParams);

        localDataSource.cacheVoices(pronuncStatisticModel: remoteSpeech);

        return Right(remoteSpeech);
      } on ServerException catch (e) {
        return Left(ServerFailure(
            errorMessage: e.errorMessage, statusCode: e.statusCode));
      }
    } else {
      try {
        ResponseDataModel<List<VoiceModel>> localVoices =
            await localDataSource.getLastVoices();
        return Right(localVoices);
      } on CacheException {
        return Left(
            CacheFailure(errorMessage: 'Không thể kết nối với máy chủ'));
      }
    }
  }

  @override
  Future<Either<Failure, ResponseDataModel<List<int>>>> textToSpeech(
      {required TTSParams ttsParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        ResponseDataModel<List<int>> remoteSpeech =
            await remoteDataSource.tts(ttsParams: ttsParams);

        localDataSource.cacheTextToSpeech(audioData: remoteSpeech);

        return Right(remoteSpeech);
      } on ServerException catch (e) {
        return Left(ServerFailure(
            errorMessage: e.errorMessage, statusCode: e.statusCode));
      }
    } else {
      try {
        ResponseDataModel<List<int>> localTextToSpeech =
            await localDataSource.getLastTextToSpeech();
        return Right(localTextToSpeech);
      } on CacheException {
        return Left(
            CacheFailure(errorMessage: 'Không thể kết nối với máy chủ'));
      }
    }
  }

  @override
  Future<Either<Failure, ResponseDataModel<PronuncAssessmentModel?>>>
      evaluateSpeechPronun(
          {required EvaluateSpeechPronunParams
              evaluateSpeechPronunParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        ResponseDataModel<PronuncAssessmentModel?> remoteSpeech =
            await remoteDataSource.evaluateSpeechPronunc(
                evaluateSpeechPronunParams: evaluateSpeechPronunParams);

        // localDataSource.cacheAuth(AuthToCache: remoteSpeech);

        return Right(remoteSpeech);
      } on ServerException catch (e) {
        return Left(ServerFailure(
            errorMessage: e.errorMessage, statusCode: e.statusCode));
      }
    } else {
      return Left(CacheFailure(errorMessage: 'Không thể kết nối với máy chủ'));
    }
  }

  @override
  Future<Either<Failure, ResponseDataModel<PronuncStatisticModel>>>
      getUserProStatistics(
          {required GetUserProStatisticParams
              getUserProStatisticParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        ResponseDataModel<PronuncStatisticModel> remoteSpeech =
            await remoteDataSource.getUserProStatistics(
                getUserProStatisticParams: getUserProStatisticParams);

        localDataSource.cacheUserPronuncStatistics(
            pronuncStatisticModel: remoteSpeech);

        return Right(remoteSpeech);
      } on ServerException catch (e) {
        return Left(ServerFailure(
            errorMessage: e.errorMessage, statusCode: e.statusCode));
      }
    } else {
      try {
        ResponseDataModel<PronuncStatisticModel> localUserPronuncStatistics =
            await localDataSource.getLastUserPronuncStatistics();
        return Right(localUserPronuncStatistics);
      } on CacheException {
        return Left(
            CacheFailure(errorMessage: 'Không thể kết nối với máy chủ'));
      }
    }
  }
}

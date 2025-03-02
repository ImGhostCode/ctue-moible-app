import 'package:ctue_app/core/constants/response.dart';
import 'package:ctue_app/core/params/contribution_params.dart';
import 'package:ctue_app/features/contribute/business/entities/contri_response_entity.dart';
import 'package:ctue_app/features/contribute/business/entities/contribution_entity.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';

abstract class ContributionRepository {
  Future<Either<Failure, ResponseDataModel<ContributionEntity>>>
      createWordContribution({
    required CreateWordConParams createWordConParams,
  });
  Future<Either<Failure, ResponseDataModel<ContributionEntity>>>
      createSenContribution({
    required CreateSenConParams createSenConParams,
  });
  Future<Either<Failure, ResponseDataModel<ContributionResEntity>>>
      getAllContributions({
    required GetAllConParams getAllConParams,
  });
  Future<Either<Failure, ResponseDataModel<ContributionResEntity>>>
      getAllConByUser({
    required GetAllConByUserParams getAllConByUserParams,
  });

  Future<Either<Failure, ResponseDataModel<void>>> verifyContribution({
    required VerifyConParams verifyConParams,
  });
}

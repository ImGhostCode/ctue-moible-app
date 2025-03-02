import 'package:ctue_app/core/constants/response.dart';
import 'package:ctue_app/core/params/contribution_params.dart';
import 'package:ctue_app/features/contribute/business/entities/contri_response_entity.dart';
import 'package:ctue_app/features/contribute/business/repositories/contribution_repositoty.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failure.dart';

class GetAllConUsecase {
  final ContributionRepository contributionRepository;

  GetAllConUsecase({required this.contributionRepository});

  Future<Either<Failure, ResponseDataModel<ContributionResEntity>>> call({
    required GetAllConParams getAllConParams,
  }) async {
    return await contributionRepository.getAllContributions(
        getAllConParams: getAllConParams);
  }
}

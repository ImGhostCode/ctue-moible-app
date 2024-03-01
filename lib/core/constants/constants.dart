String kTemplate = 'template';

// String kName = 'name';
// String kId = 'id';
String kSprites = 'sprites';
String kTypes = 'types';
String kType = 'type';
String kOther = 'other';
String kOfficialArtwork = 'official-artwork';
String kFrontDefault = 'front_default';
String kFrontShiny = 'front_shiny';

String kAccessToken = 'accessToken';
String kData = 'data';
String kMessage = 'message';
String kEmail = 'email';
String kUserId = 'userId';
String kAuthType = 'authType';
String kAccountType = 'accountType';
String kIsBan = 'isBan';
String kFeedback = 'feedback';
String kIsDeleted = 'isDeleted';

String kId = 'id';
String kName = 'name';
String kAvt = 'avt';
String kCreatedAt = 'createdAt';
String kUpdatedAt = 'updatedAt';
String kisWord = 'isWord';

String kTypeId = 'typeId';
String kContent = 'content';
String kMean = 'mean';

String kNote = 'note';

String kTopics = 'topics';
String kMeanings = 'meanings';
String kLevelId = 'levelId';
String kSpecializationId = 'specializationId';
String kPhonetic = 'phonetic';
String kPictures = 'pictures';
String kExamples = 'examples';
String kSynonyms = 'synonyms';
String kAntonyms = 'antonyms';

String kMeaning = 'meaning';
String kWordId = 'wordId';

String kV1 = 'v1';
String kV2 = 'v2';
String kV3 = 'v3';
String kWords = 'words';
String kWord = 'Word';
String kStatus = 'status';
String kUser = 'User';
String kContriType = 'type';

enum ResponseData { data, message, statusCode }

int maxPokemonId = 1008;

class VocabularySetArguments {
  final int id;

  VocabularySetArguments({required this.id});
}

String accNotFound = 'Tài khoản không tồn tại';
String accBaned = 'Tài khoản đã bị khóa';
String pwdErrorMessage = 'Mật khẩu không chính xác';

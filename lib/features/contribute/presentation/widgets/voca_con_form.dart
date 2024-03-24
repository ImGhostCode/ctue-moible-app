import 'dart:io';

import 'package:ctue_app/core/constants/constants.dart';
import 'package:ctue_app/core/errors/failure.dart';
import 'package:ctue_app/core/params/contribution_params.dart';
import 'package:ctue_app/features/contribute/presentation/providers/contribution_provider.dart';
import 'package:ctue_app/features/contribute/presentation/widgets/ipa_keyboard.dart';
import 'package:ctue_app/features/level/business/entities/level_entity.dart';
import 'package:ctue_app/features/level/presentation/providers/level_provider.dart';
import 'package:ctue_app/features/specialization/business/entities/specialization_entity.dart';
import 'package:ctue_app/features/specialization/presentation/providers/spec_provider.dart';
import 'package:ctue_app/features/topic/business/entities/topic_entity.dart';
import 'package:ctue_app/features/topic/presentation/providers/topic_provider.dart';
import 'package:ctue_app/features/type/business/entities/type_entity.dart';
import 'package:ctue_app/features/type/presentation/providers/type_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class WordDefinition {
  int? wordTypeId;
  String? meaning;

  WordDefinition({this.wordTypeId, this.meaning});
}

class VocaConForm extends StatefulWidget {
  const VocaConForm({Key? key}) : super(key: key);

  @override
  _VocaConFormState createState() => _VocaConFormState();
}

class _VocaConFormState extends State<VocaConForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _pronunciationController =
      TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  // final TextEditingController _meaningController = TextEditingController();
  final TextEditingController _synonymController = TextEditingController();
  final TextEditingController _antonymController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final List<WordDefinition> _wordDefinitions = [];
  final List<String> _examples = [];
  List<XFile> _selectedImages = [];

  int? _selectedLevel;
  int? _selectedSpecializaiton;
  bool _isExpanded = false;

  String? _wordDefinitionError = '';
  String? _levelError = '';
  String? _specError = '';
  String? _topicError = '';

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickMultiImage();

    if (pickedFile.isNotEmpty) {
      setState(() {
        _selectedImages = pickedFile;
        // print(_selectedImages);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _handleButtonPress(String label) {
    if (label == 'Backspace') {
      if (_pronunciationController.text.isNotEmpty) {
        _pronunciationController.text = _pronunciationController.text
            .substring(0, _pronunciationController.text.length - 1);
      }
    } else {
      _pronunciationController.text += label;
    }
  }

  @override
  void initState() {
    Provider.of<TypeProvider>(context, listen: false)
        .eitherFailureOrGetTypes(true);
    Provider.of<SpecializationProvider>(context, listen: false)
        .eitherFailureOrGetSpecializations();
    Provider.of<LevelProvider>(context, listen: false)
        .eitherFailureOrGetLevels();
    Provider.of<TopicProvider>(context, listen: false)
        .eitherFailureOrTopics(null, true, null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Từ mới',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(
                height: 4,
              ),
              TextFormField(
                controller: _contentController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng điền vào chỗ trống';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Phiên âm',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(
                height: 4,
              ),
              TextFormField(
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontFamily: 'DoulosSIL',
                    ),
                readOnly: true,
                // showCursor: true,
                controller: _pronunciationController,
                onTap: () {
                  _showPronunciationDialog(context);
                },
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng điền vào chỗ trống';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'Loại từ',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(
                height: 5,
              ),
              _buildWordDefinitionList(),
              const SizedBox(
                height: 4,
              ),
              SizedBox(
                height: 40,
                child: IconButton(
                  color: Theme.of(context).colorScheme.primary,
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _addWordDefinition();
                  },
                ),
              ),
              _wordDefinitionError != null
                  ? Text(
                      _wordDefinitionError!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Colors.red),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(
                height: 4,
              ),
              Text(
                'Bậc của từ',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(
                height: 4,
              ),
              _buildLevels(context),
              _levelError != null
                  ? Text(
                      _levelError!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Colors.red),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(
                height: 4,
              ),
              Text(
                'Chuyên ngành',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(
                height: 4,
              ),
              _buildSpecializaitons(context),
              _specError != null
                  ? Text(
                      _specError!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Colors.red),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(
                height: 4,
              ),
              Text(
                'Các câu ví dụ',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(
                height: 4,
              ),
              _buildExampleList(),
              const SizedBox(
                height: 4,
              ),
              SizedBox(
                height: 40,
                child: IconButton(
                  color: Theme.of(context).colorScheme.primary,
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _addExample();
                  },
                ),
              ),
              Text(
                'Các từ đồng nghĩa',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(
                height: 4,
              ),
              TextFormField(
                controller: _synonymController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  helperText: 'Viết cách nhau bởi dấy phẩy',
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Các từ trái nghĩa',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(
                height: 4,
              ),
              TextFormField(
                controller: _antonymController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  helperText: 'Viết cách nhau bởi dấy phẩy',
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Ghi chú',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(
                height: 4,
              ),
              TextFormField(
                maxLines: 4,
                controller: _noteController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Thêm ảnh minh họa',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 40,
                width: 125,
                child: ElevatedButton(
                  onPressed: _pickImage,
                  child: const Row(
                    children: [
                      Icon(Icons.upload),
                      SizedBox(
                        width: 5,
                      ),
                      Text('Tải lên')
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.teal),
                        ),
                        child: Stack(
                          children: [
                            Image.file(
                              File(_selectedImages[index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.fill,
                            ),
                            Positioned(
                              top: -10,
                              right: -10,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () => _removeImage(index),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(
                height: 5,
              ),
              _buildTopics(context),
              const SizedBox(
                height: 8,
              ),
              _topicError != null
                  ? Text(
                      _topicError!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Colors.red),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 45,
                    width: 150,
                    child: ElevatedButton(
                        onPressed: Provider.of<ContributionProvider>(context,
                                    listen: true)
                                .isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _wordDefinitionError = null;
                                  _levelError = null;
                                  _specError = null;
                                  _topicError = null;
                                });

                                // print(_contentController.text);
                                // print(_pronunciationController.text);
                                // print(_wordDefinitions);
                                // print(_selectedLevel);
                                // print(_selectedSpecializaiton);
                                // print(_examples);
                                // print(_synonymController.text);
                                // print(_antonymController.text);
                                // print(_noteController.text);
                                // print(_selectedImages);
                                // print(
                                //     Provider.of<TopicProvider>(context, listen: false)
                                //         .getSelectedTopics());

                                List<dynamic> selectedTopics =
                                    Provider.of<TopicProvider>(context,
                                            listen: false)
                                        .getSelectedTopics();

                                Content content = Content(
                                    topicId: selectedTopics,
                                    levelId: _selectedLevel!,
                                    specializationId: _selectedSpecializaiton!,
                                    content: _contentController.text,
                                    meanings: _wordDefinitions
                                        .map((item) => WordMeaning(
                                            typeId: item.wordTypeId!,
                                            meaning: item.meaning!))
                                        .toList(),
                                    phonetic: _pronunciationController.text,
                                    examples: _examples,
                                    antonyms: _antonymController.text.isNotEmpty
                                        ? _antonymController.text.split(',')
                                        : [],
                                    synonyms: _synonymController.text.isNotEmpty
                                        ? _synonymController.text.split(',')
                                        : [],
                                    note: _noteController.text.isNotEmpty
                                        ? _noteController.text
                                        : null,
                                    pictures: _selectedImages);

                                if (_formKey.currentState!.validate() &&
                                    _validateForm()) {
                                  await Provider.of<ContributionProvider>(
                                          context,
                                          listen: false)
                                      .eitherFailureOrCreWordCon(
                                          typeConWord, content);

                                  if (Provider.of<ContributionProvider>(context,
                                              listen: false)
                                          .contributionEntity !=
                                      null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration: const Duration(seconds: 1),
                                        content: Text(
                                          Provider.of<ContributionProvider>(
                                                  context,
                                                  listen: false)
                                              .message!,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        backgroundColor: Colors
                                            .green, // You can customize the color
                                      ),
                                    );
                                  } else if (Provider.of<ContributionProvider>(
                                              context,
                                              listen: false)
                                          .failure !=
                                      null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration: const Duration(seconds: 1),
                                        content: Text(
                                          Provider.of<ContributionProvider>(
                                                  context,
                                                  listen: false)
                                              .message!,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        backgroundColor: Colors
                                            .red, // You can customize the color
                                      ),
                                    );
                                  }
                                  Navigator.of(context).pop();
                                }
                              },
                        child: Provider.of<ContributionProvider>(context,
                                    listen: true)
                                .isLoading
                            ? const SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                ),
                              )
                            : Text(
                                'Gửi đóng góp',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: Colors.white),
                              )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ExpansionPanelList _buildTopics(BuildContext context) {
    return ExpansionPanelList(
      elevation: 2,
      expandedHeaderPadding: const EdgeInsets.all(0),
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _isExpanded = isExpanded;
        });
      },
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(
                'Thêm chủ đề',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.black),
              ),
            );
          },
          body: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade100),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(5),
            child: Consumer<TopicProvider>(builder: (context, provider, child) {
              List<TopicEntity> listTopics = provider.listTopicEntity;

              bool isLoading = provider.isLoading;

              // Access the failure from the provider
              Failure? failure = provider.failure;

              if (failure != null) {
                return Text(failure.errorMessage);
              } else if (isLoading) {
                return const Center(
                    child:
                        CircularProgressIndicator()); // or show an empty state message
              } else if (listTopics.isEmpty) {
                // Handle the case where topics are empty
                return const Center(child: Text('Không có dữ liệu'));
              } else {
                return Wrap(
                  spacing: 8.0, // Khoảng cách giữa các Chip
                  children: listTopics.map((topic) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ActionChip(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                25.0), // Set the border radius here
                          ),
                          side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.7),
                              width: 2),
                          backgroundColor: topic.isSelected
                              ? Colors.green.shade500
                              : Colors.grey.shade100,
                          avatar: ClipOval(
                            child: topic.image.isNotEmpty
                                ? Image.network(
                                    topic.image,
                                    fit: BoxFit.fill,
                                    width: 60.0,
                                    height: 60.0,
                                  )
                                : Container(),
                          ),
                          label: Text(
                            topic.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    fontWeight: FontWeight.normal,
                                    color: topic.isSelected
                                        ? Colors.white
                                        : Colors.black),
                          ),
                          onPressed: () {
                            setState(() {
                              topic.isSelected = !topic.isSelected;
                            });
                          }),
                    );
                  }).toList(),
                );
              }
            }),
          ),
          isExpanded: _isExpanded,
        ),
      ],
    );
  }

  Container _buildLevels(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Consumer<LevelProvider>(builder: (context, provider, child) {
        return DropdownButtonFormField<int>(
          style: Theme.of(context).textTheme.bodyMedium,
          value: _selectedLevel =
              provider.listLevels.isNotEmpty ? provider.listLevels[0].id : null,
          validator: (int? value) {
            if (value == null) {
              return "Vui lòng chọn bậc của từ";
            }
            return null;
          },
          items: provider.listLevels
              .map<DropdownMenuItem<int>>(
                  (LevelEntity levelEntity) => DropdownMenuItem(
                        value: levelEntity.id,
                        child: Text(levelEntity.name),
                      ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedLevel = value;
            });
          },
          decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              )),
        );
      }),
    );
  }

  Container _buildSpecializaitons(BuildContext context) {
    return Container(
      color: Colors.white,
      child:
          Consumer<SpecializationProvider>(builder: (context, provider, child) {
        return DropdownButtonFormField<int>(
          style: Theme.of(context).textTheme.bodyMedium,
          value: _selectedSpecializaiton =
              provider.listSpecializations.isNotEmpty
                  ? provider.listSpecializations[0].id
                  : null,
          validator: (int? value) {
            if (value == null) {
              return "Vui lòng chọn chuyên ngành";
            }
            return null;
          },
          items: provider.listSpecializations
              .map<DropdownMenuItem<int>>(
                  (SpecializationEntity specialization) => DropdownMenuItem(
                        value: specialization.id,
                        child: Text(specialization.name),
                      ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedSpecializaiton = value;
            });
          },
          decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              )),
        );
      }),
    );
  }

  void _showPronunciationDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          // Add your pronunciation input UI here
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Nhập phiên âm',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: Colors.teal),
              ),
              const SizedBox(
                height: 5,
              ),
              TextFormField(
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontFamily: 'DoulosSIL',
                    ),
                readOnly: true,
                showCursor: true,
                controller: _pronunciationController,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập phiên âm';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: IPAKeyboard(
                  onTap: _handleButtonPress,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Add logic when user submits pronunciation
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Xác nhận',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildExampleList() {
    return Column(
      children: _examples.asMap().entries.map((example) {
        final index = example.key;
        return _buildExampleRow(index);
      }).toList(),
    );
  }

  Widget _buildExampleRow(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              child: TextFormField(
            // controller: TextEditingController(text: wordDefinition.meaning),
            style: Theme.of(context).textTheme.bodyMedium,

            decoration: InputDecoration(
              // hintText: 'Cau vi du',
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade400)),
            ),
            onChanged: (value) {
              setState(() {
                _examples[index] = value;
              });
            },
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng điền vào chỗ trống';
              }
              return null;
            },
          )),
          IconButton(
              onPressed: () {
                _removeExample(index);
              },
              color: Colors.red,
              icon: const Icon(
                Icons.remove,
                color: Colors.red,
              )),
        ],
      ),
    );
  }

  Widget _buildWordDefinitionList() {
    return Column(
      children: _wordDefinitions.asMap().entries.map((entry) {
        final index = entry.key;
        final wordDefinition = entry.value;
        return _buildWordDefinitionRow(index, wordDefinition);
      }).toList(),
    );
  }

  Widget _buildWordDefinitionRow(int index, WordDefinition wordDefinition) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Consumer<TypeProvider>(builder: (context, provider, child) {
            return DropdownButton<int>(
              alignment: Alignment.center,
              focusColor: Colors.white,
              style: Theme.of(context).textTheme.bodyMedium!,
              value: wordDefinition.wordTypeId = provider.listTypes.isNotEmpty
                  ? provider.listTypes[0].id
                  : null,
              items: provider.listTypes
                  .map<DropdownMenuItem<int>>(
                      (TypeEntity type) => DropdownMenuItem<int>(
                            value: type.id,
                            child: Text(type.name),
                          ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _wordDefinitions[index].wordTypeId = value;
                });
              },
              hint: const Text('Loại từ'),
            );
          }),
          const SizedBox(width: 10),
          Expanded(
              child: TextFormField(
            // controller: TextEditingController(text: wordDefinition.meaning),
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              // hintText: 'Nhập nghĩa của từ',
              // helperText: 'Nghĩa của từ',
              hintText: 'Nghĩa của từ',
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade400)),
            ),
            onChanged: (value) {
              setState(() {
                _wordDefinitions[index].meaning = value;
              });
            },
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng điền vào chỗ trống';
              }
              return null;
            },
          )),
          IconButton(
              onPressed: () {
                _removeWordDefinition(index);
              },
              color: Colors.red,
              icon: const Icon(
                Icons.remove,
                color: Colors.red,
              ))
        ],
      ),
    );
  }

  bool _validateForm() {
    bool isValid = true;

    if (_wordDefinitions.isEmpty) {
      setState(() {
        _wordDefinitionError = 'Vui lòng nhập nghĩa của từ';
      });
      isValid = false;
    }

    if (_selectedLevel == null) {
      setState(() {
        _levelError = 'Vui lòng chọn cập độ của từ';
      });
      isValid = false;
    }
    if (_selectedSpecializaiton == null) {
      setState(() {
        _specError = 'Vui lòng chọn chuyên ngành của từ';
      });
      isValid = false;
    }

    if (Provider.of<TopicProvider>(context, listen: false)
        .getSelectedTopics()
        .isEmpty) {
      setState(() {
        _topicError = 'Vui lòng chọn ít nhất 1 chủ đề';
      });
      isValid = false;
    }
    return isValid;
  }

  void _removeWordDefinition(int index) {
    setState(() {
      _wordDefinitions.removeAt(index);
    });
  }

  void _addWordDefinition() {
    setState(() {
      _wordDefinitions.add(WordDefinition());
    });
  }

  void _addExample() {
    setState(() {
      _examples.add('');
    });
  }

  void _removeExample(int index) {
    setState(() {
      _examples.removeAt(index);
    });
  }
}

class Topic {
  int id;
  String image;
  String name;
  bool isSeleted;
  Topic(
      {required this.id,
      required this.image,
      required this.name,
      required this.isSeleted});
}

import 'answer.dart';

class Question {
  final String id;
  final String text;
  final String explanation;
  final String bibleReference;
  final List<Answer> answers;

  Question({
    required this.id,
    required this.text,
    required this.explanation,
    required this.bibleReference,
    required this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    var rawAnswers = json['answers'] as List? ?? [];
    List<Answer> parsedAnswers = rawAnswers
        .map((a) => Answer.fromJson(a as Map<String, dynamic>))
        .toList();

    return Question(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      bibleReference: json['bibleReference'] as String? ?? '',
      answers: parsedAnswers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'explanation': explanation,
      'bibleReference': bibleReference,
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }
}

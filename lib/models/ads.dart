class Ads {
  final int? sequence;
  final String? id;
  final String? title;
  final String? content;
  final String? description;

  Ads({
    this.sequence,
    this.id,
    this.title,
    this.content,
    this.description,
  });

  factory Ads.fromJson(Map<String, dynamic> json) {
    return Ads(
      sequence: json['sequence'],
      id: json['id'],
      title: json['title'],
      content: json['content'],
      description: json['description'],
    );
  }
}
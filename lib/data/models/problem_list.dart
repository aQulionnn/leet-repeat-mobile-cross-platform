class ProblemList {
  int? id;
  String name;

  ProblemList({this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory ProblemList.fromJson(Map<String, dynamic> json) =>
      ProblemList(id: json['id'], name: json['name']);
}
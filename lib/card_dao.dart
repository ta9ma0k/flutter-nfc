import 'package:nfc_sample/database.dart';

const _tableName = 'cards';

class CardDao extends SqliteDao<CardDto> {
  CardDao() : super(_tableName, CardDto.fromJson);
}

class CardDto extends SqliteEntity {
  final String id;
  final String owner;

  CardDto({required this.id, required this.owner});

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner': owner,
    };
  }

  factory CardDto.fromJson(Map<String, dynamic> json) {
    return CardDto(
      id: json['id'],
      owner: json['owner'],
    );
  }
}

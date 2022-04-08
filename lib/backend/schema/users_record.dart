import 'dart:async';

import 'index.dart';
import 'serializers.dart';
import 'package:built_value/built_value.dart';

part 'users_record.g.dart';

abstract class UsersRecord implements Built<UsersRecord, UsersRecordBuilder> {
  static Serializer<UsersRecord> get serializer => _$usersRecordSerializer;

  @nullable
  @BuiltValueField(wireName: 'created_time')
  DateTime get createdTime;

  @nullable
  @BuiltValueField(wireName: 'display_name')
  String get displayName;

  @nullable
  String get email;

  @nullable
  @BuiltValueField(wireName: 'global_score')
  int get globalScore;

  @nullable
  int get level;

  @nullable
  @BuiltValueField(wireName: 'phone_number')
  String get phoneNumber;

  @nullable
  String get uid;

  @nullable
  @BuiltValueField(wireName: 'photo_url')
  String get photoUrl;

  @nullable
  int get activity;

  @nullable
  int get rank;

  @nullable
  @BuiltValueField(wireName: 'rank_size')
  int get rankSize;

  @nullable
  String get primer;

  @nullable
  int get co2target;

  @nullable
  @BuiltValueField(wireName: kDocumentReferenceField)
  DocumentReference get reference;

  static void _initializeBuilder(UsersRecordBuilder builder) => builder
    ..displayName = ''
    ..email = ''
    ..globalScore = 0
    ..level = 0
    ..phoneNumber = ''
    ..uid = ''
    ..photoUrl = ''
    ..activity = 0
    ..rank = 0
    ..rankSize = 0
    ..primer = ''
    ..co2target = 0;

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) => ref
      .snapshots()
      .map((s) => serializers.deserializeWith(serializer, serializedData(s)));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) => ref
      .get()
      .then((s) => serializers.deserializeWith(serializer, serializedData(s)));

  UsersRecord._();
  factory UsersRecord([void Function(UsersRecordBuilder) updates]) =
      _$UsersRecord;

  static UsersRecord getDocumentFromData(
          Map<String, dynamic> data, DocumentReference reference) =>
      serializers.deserializeWith(serializer,
          {...mapFromFirestore(data), kDocumentReferenceField: reference});
}

Map<String, dynamic> createUsersRecordData({
  DateTime createdTime,
  String displayName,
  String email,
  int globalScore,
  int level,
  String phoneNumber,
  String uid,
  String photoUrl,
  int activity,
  int rank,
  int rankSize,
  String primer,
  int co2target,
}) =>
    serializers.toFirestore(
        UsersRecord.serializer,
        UsersRecord((u) => u
          ..createdTime = createdTime
          ..displayName = displayName
          ..email = email
          ..globalScore = globalScore
          ..level = level
          ..phoneNumber = phoneNumber
          ..uid = uid
          ..photoUrl = photoUrl
          ..activity = activity
          ..rank = rank
          ..rankSize = rankSize
          ..primer = primer
          ..co2target = co2target));

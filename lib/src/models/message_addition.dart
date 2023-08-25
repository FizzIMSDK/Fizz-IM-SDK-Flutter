import 'dart:core';

import 'package:fixnum/fixnum.dart' show Int64;
//消息撤回 消息艾特
class MessageAddition {
  final bool isMentioned;
  //提到的用户ids
  final Set<Int64> mentionedUserIds;
  //撤回的消息ids
  final Set<Int64> recalledMessageIds;

  MessageAddition(
      this.isMentioned, this.mentionedUserIds, this.recalledMessageIds);

  @override
  int get hashCode =>
      isMentioned.hashCode ^
      mentionedUserIds.hashCode ^
      recalledMessageIds.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAddition &&
          isMentioned == other.isMentioned &&
          mentionedUserIds == other.mentionedUserIds &&
          recalledMessageIds == other.recalledMessageIds;

  @override
  String toString() =>
      'MessageAddition{isMentioned: $isMentioned, mentionedUserIds: $mentionedUserIds, recalledMessageIds: $recalledMessageIds}';
}

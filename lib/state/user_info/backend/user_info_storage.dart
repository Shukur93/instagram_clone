import 'package:flutter/foundation.dart' show immutable;
import 'package:instagram_clone/state/constants/firebase_field_name.dart';
import 'package:instagram_clone/state/posts/typedefs/user_id.dart';

// FirebseFirestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/state/constants/firebase_collection_name.dart';
import 'package:instagram_clone/state/user_info/models/user_info_payload.dart';

@immutable
class UserInfoStorage {
  const UserInfoStorage();

  Future<bool> saveUserInfo({
    required UserId userId,
    required String dispalyName,
    required String? email,
  }) async {
    try {
      // first check if we have this user's info from before
      final userInfo = await FirebaseFirestore.instance
          .collection(
            FirebaseCollectionName.users,
          )
          .where(
            FirebaseFieldName.userId,
            isEqualTo: userId,
          )
          .limit(1)
          .get();

      if (userInfo.docs.isNotEmpty) {
        // we already have this user's info
        await userInfo.docs.first.reference.update({
          FirebaseFieldName.displayName: dispalyName,
          FirebaseFieldName.email: email ?? '',
        });
        return true;
      }

      // we don't have this user's info from before, create a new user
      final payload = UserInfoPayload(
        userId: userId,
        dispalyName: dispalyName,
        email: email,
      );

      await FirebaseFirestore.instance
          .collection(
            FirebaseCollectionName.users,
          )
          .add(payload);
      return true;
    } catch (e) {
      return false;
    }
  }
}

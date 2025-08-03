import 'dart:convert';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/local_storage.dart';
import '../models/user_profile_dto.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileDto> getCachedUserProfile(String userId);
  Future<void> cacheUserProfile(UserProfileDto profileDto);
  Future<void> clearCachedUserProfile(String userId);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final LocalStorage localStorage;
  static const String _profileCacheKey = 'cached_user_profile_';

  ProfileLocalDataSourceImpl({required this.localStorage});

  @override
  Future<UserProfileDto> getCachedUserProfile(String userId) async {
    try {
      final cachedData = await localStorage.getString('$_profileCacheKey$userId');
      
      if (cachedData != null) {
        final jsonData = json.decode(cachedData);
        return UserProfileDto.fromJson(jsonData);
      } else {
        throw CacheException('No cached profile found');
      }
    } catch (e) {
      throw CacheException('Failed to get cached profile: $e');
    }
  }

  @override
  Future<void> cacheUserProfile(UserProfileDto profileDto) async {
    try {
      final jsonString = json.encode(profileDto.toJson());
      await localStorage.setString('$_profileCacheKey${profileDto.id}', jsonString);
    } catch (e) {
      throw CacheException('Failed to cache profile: $e');
    }
  }

  @override
  Future<void> clearCachedUserProfile(String userId) async {
    try {
      await localStorage.remove('$_profileCacheKey$userId');
    } catch (e) {
      throw CacheException('Failed to clear cached profile: $e');
    }
  }
}
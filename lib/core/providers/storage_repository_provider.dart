import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

final storageRepositoryProvider = Provider(
  (ref) => StorageRepository(),
);

class StorageRepository {
  Future<String> uploadFile(
      File file, String srcId, String category, String contentType) async {
    try {
      String resId = Uuid().v4();
      final extension = p.extension(file.path);
      final fileName = resId;
      final filePath = "$category/$srcId/$fileName$extension";

      final options = StorageUploadFileOptions(
        metadata: {'contentType': contentType},
      );

      final awsFile = AWSFile.fromPath(file.path);
      final path = StoragePath.fromString(filePath);

      final result = await Amplify.Storage.uploadFile(
        localFile: awsFile,
        path: path,
        options: options,
        onProgress: (progress) {
          print('Upload progress: ${progress.fractionCompleted}');
        },
      ).result;
      debugPrint(result.uploadedItem.toString());
      return result.uploadedItem.path.toString();
    } catch (e) {
      debugPrint(e.toString());
      throw Exception("Errore durante l'upload: $e");
    }
  }

  // Esempio di utilizzo per diversi tipi di file:
  Future<String> uploadImage(File file, String srcId) {
    return uploadFile(
      file,
      srcId,
      'images',
      'image/jpeg',
    );
  }

  Future<String> uploadDocument(File file, String srcId) {
    return uploadFile(
      file,
      srcId,
      'documents',
      'application/pdf', // o altro tipo di documento
    );
  }

  Future<String> uploadVideo(File file, String srcId) {
    return uploadFile(
      file,
      srcId,
      'videos',
      'video/mp4',
    );
  }

  Future<String> getDownloadUrl(String filePath) async {
    try {
      final path = StoragePath.fromString(filePath);
      final result = await Amplify.Storage.getUrl(path: path).result;
      return result.url.toString();
    } catch (e) {
      throw Exception("Errore nel recupero del file: $e");
    }
  }

  Future<void> deleteFile(String filePath) async {
    try {
      final path = StoragePath.fromString(filePath);
      await Amplify.Storage.remove(path: path);
    } catch (e) {
      throw Exception("Errore durante l'eliminazione: $e");
    }
  }

  Future<String> editFile(
      File file, String srcId, String category, String fileName,
      {required String contentType}) async {
    try {
      // Prima carica il nuovo file
      final newFilePath = await uploadFile(
        file,
        srcId,
        category,
        contentType,
      );

      // Poi elimina il vecchio file
      await deleteFile("$category/$srcId/$fileName");

      return newFilePath;
    } catch (e) {
      throw Exception("Errore durante l'edit: $e");
    }
  }
}

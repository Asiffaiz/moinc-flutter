import 'package:equatable/equatable.dart';

class DocumentModel extends Equatable {
  final String id;
  final String title;
  final String fileName;
  final String fileType;
  final String fileSize;
  final DateTime uploadDate;
  final String? description;
  final String? url;
  final bool isProcessed;
  final bool isTraining;
  final bool isError;
  final String? errorMessage;

  const DocumentModel({
    required this.id,
    required this.title,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.uploadDate,
    this.description,
    this.url,
    this.isProcessed = false,
    this.isTraining = false,
    this.isError = false,
    this.errorMessage,
  });

  DocumentModel copyWith({
    String? id,
    String? title,
    String? fileName,
    String? fileType,
    String? fileSize,
    DateTime? uploadDate,
    String? description,
    String? url,
    bool? isProcessed,
    bool? isTraining,
    bool? isError,
    String? errorMessage,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      uploadDate: uploadDate ?? this.uploadDate,
      description: description ?? this.description,
      url: url ?? this.url,
      isProcessed: isProcessed ?? this.isProcessed,
      isTraining: isTraining ?? this.isTraining,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      fileName: json['fileName'] as String,
      fileType: json['fileType'] as String,
      fileSize: json['fileSize'] as String,
      uploadDate: DateTime.parse(json['uploadDate'] as String),
      description: json['description'] as String?,
      url: json['url'] as String?,
      isProcessed: json['isProcessed'] as bool? ?? false,
      isTraining: json['isTraining'] as bool? ?? false,
      isError: json['isError'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      'uploadDate': uploadDate.toIso8601String(),
      'description': description,
      'url': url,
      'isProcessed': isProcessed,
      'isTraining': isTraining,
      'isError': isError,
      'errorMessage': errorMessage,
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    fileName,
    fileType,
    fileSize,
    uploadDate,
    description,
    url,
    isProcessed,
    isTraining,
    isError,
    errorMessage,
  ];
}

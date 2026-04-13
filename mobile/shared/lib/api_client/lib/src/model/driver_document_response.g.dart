// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_document_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DriverDocumentResponse extends DriverDocumentResponse {
  @override
  final String id;
  @override
  final String driverId;
  @override
  final DocumentType documentType;
  @override
  final String documentNumber;
  @override
  final String imageUrl;
  @override
  final Date? expiryDate;
  @override
  final UploadStatus uploadStatus;
  @override
  final String? rejectionReason;
  @override
  final DateTime uploadedAt;
  @override
  final DateTime? reviewedAt;

  factory _$DriverDocumentResponse([
    void Function(DriverDocumentResponseBuilder)? updates,
  ]) => (DriverDocumentResponseBuilder()..update(updates))._build();

  _$DriverDocumentResponse._({
    required this.id,
    required this.driverId,
    required this.documentType,
    required this.documentNumber,
    required this.imageUrl,
    this.expiryDate,
    required this.uploadStatus,
    this.rejectionReason,
    required this.uploadedAt,
    this.reviewedAt,
  }) : super._();
  @override
  DriverDocumentResponse rebuild(
    void Function(DriverDocumentResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DriverDocumentResponseBuilder toBuilder() =>
      DriverDocumentResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverDocumentResponse &&
        id == other.id &&
        driverId == other.driverId &&
        documentType == other.documentType &&
        documentNumber == other.documentNumber &&
        imageUrl == other.imageUrl &&
        expiryDate == other.expiryDate &&
        uploadStatus == other.uploadStatus &&
        rejectionReason == other.rejectionReason &&
        uploadedAt == other.uploadedAt &&
        reviewedAt == other.reviewedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, documentType.hashCode);
    _$hash = $jc(_$hash, documentNumber.hashCode);
    _$hash = $jc(_$hash, imageUrl.hashCode);
    _$hash = $jc(_$hash, expiryDate.hashCode);
    _$hash = $jc(_$hash, uploadStatus.hashCode);
    _$hash = $jc(_$hash, rejectionReason.hashCode);
    _$hash = $jc(_$hash, uploadedAt.hashCode);
    _$hash = $jc(_$hash, reviewedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DriverDocumentResponse')
          ..add('id', id)
          ..add('driverId', driverId)
          ..add('documentType', documentType)
          ..add('documentNumber', documentNumber)
          ..add('imageUrl', imageUrl)
          ..add('expiryDate', expiryDate)
          ..add('uploadStatus', uploadStatus)
          ..add('rejectionReason', rejectionReason)
          ..add('uploadedAt', uploadedAt)
          ..add('reviewedAt', reviewedAt))
        .toString();
  }
}

class DriverDocumentResponseBuilder
    implements Builder<DriverDocumentResponse, DriverDocumentResponseBuilder> {
  _$DriverDocumentResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  DocumentType? _documentType;
  DocumentType? get documentType => _$this._documentType;
  set documentType(DocumentType? documentType) =>
      _$this._documentType = documentType;

  String? _documentNumber;
  String? get documentNumber => _$this._documentNumber;
  set documentNumber(String? documentNumber) =>
      _$this._documentNumber = documentNumber;

  String? _imageUrl;
  String? get imageUrl => _$this._imageUrl;
  set imageUrl(String? imageUrl) => _$this._imageUrl = imageUrl;

  Date? _expiryDate;
  Date? get expiryDate => _$this._expiryDate;
  set expiryDate(Date? expiryDate) => _$this._expiryDate = expiryDate;

  UploadStatus? _uploadStatus;
  UploadStatus? get uploadStatus => _$this._uploadStatus;
  set uploadStatus(UploadStatus? uploadStatus) =>
      _$this._uploadStatus = uploadStatus;

  String? _rejectionReason;
  String? get rejectionReason => _$this._rejectionReason;
  set rejectionReason(String? rejectionReason) =>
      _$this._rejectionReason = rejectionReason;

  DateTime? _uploadedAt;
  DateTime? get uploadedAt => _$this._uploadedAt;
  set uploadedAt(DateTime? uploadedAt) => _$this._uploadedAt = uploadedAt;

  DateTime? _reviewedAt;
  DateTime? get reviewedAt => _$this._reviewedAt;
  set reviewedAt(DateTime? reviewedAt) => _$this._reviewedAt = reviewedAt;

  DriverDocumentResponseBuilder() {
    DriverDocumentResponse._defaults(this);
  }

  DriverDocumentResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _driverId = $v.driverId;
      _documentType = $v.documentType;
      _documentNumber = $v.documentNumber;
      _imageUrl = $v.imageUrl;
      _expiryDate = $v.expiryDate;
      _uploadStatus = $v.uploadStatus;
      _rejectionReason = $v.rejectionReason;
      _uploadedAt = $v.uploadedAt;
      _reviewedAt = $v.reviewedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverDocumentResponse other) {
    _$v = other as _$DriverDocumentResponse;
  }

  @override
  void update(void Function(DriverDocumentResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverDocumentResponse build() => _build();

  _$DriverDocumentResponse _build() {
    final _$result =
        _$v ??
        _$DriverDocumentResponse._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'DriverDocumentResponse',
            'id',
          ),
          driverId: BuiltValueNullFieldError.checkNotNull(
            driverId,
            r'DriverDocumentResponse',
            'driverId',
          ),
          documentType: BuiltValueNullFieldError.checkNotNull(
            documentType,
            r'DriverDocumentResponse',
            'documentType',
          ),
          documentNumber: BuiltValueNullFieldError.checkNotNull(
            documentNumber,
            r'DriverDocumentResponse',
            'documentNumber',
          ),
          imageUrl: BuiltValueNullFieldError.checkNotNull(
            imageUrl,
            r'DriverDocumentResponse',
            'imageUrl',
          ),
          expiryDate: expiryDate,
          uploadStatus: BuiltValueNullFieldError.checkNotNull(
            uploadStatus,
            r'DriverDocumentResponse',
            'uploadStatus',
          ),
          rejectionReason: rejectionReason,
          uploadedAt: BuiltValueNullFieldError.checkNotNull(
            uploadedAt,
            r'DriverDocumentResponse',
            'uploadedAt',
          ),
          reviewedAt: reviewedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

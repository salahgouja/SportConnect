// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VehicleModel {

 String get id; String get ownerId; String get make; String get model; int get year; String get color; String get licensePlate; int get capacity; FuelType get fuelType; String? get imageUrl; List<String> get imageUrls; bool get isActive; VehicleVerificationStatus get verificationStatus; String? get verificationNote;// Vehicle documents
 String? get registrationDocUrl; String? get insuranceDocUrl;@TimestampConverter() DateTime? get insuranceExpiry;// Vehicle features/amenities
 bool get hasAC; bool get hasCharger; bool get hasWifi; bool get petsAllowed; bool get smokingAllowed; bool get hasLuggage;// Stats
 int get totalRides; double get averageRating;// Timestamps
@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;
/// Create a copy of VehicleModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleModelCopyWith<VehicleModel> get copyWith => _$VehicleModelCopyWithImpl<VehicleModel>(this as VehicleModel, _$identity);

  /// Serializes this VehicleModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VehicleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.make, make) || other.make == make)&&(identical(other.model, model) || other.model == model)&&(identical(other.year, year) || other.year == year)&&(identical(other.color, color) || other.color == color)&&(identical(other.licensePlate, licensePlate) || other.licensePlate == licensePlate)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.fuelType, fuelType) || other.fuelType == fuelType)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.verificationNote, verificationNote) || other.verificationNote == verificationNote)&&(identical(other.registrationDocUrl, registrationDocUrl) || other.registrationDocUrl == registrationDocUrl)&&(identical(other.insuranceDocUrl, insuranceDocUrl) || other.insuranceDocUrl == insuranceDocUrl)&&(identical(other.insuranceExpiry, insuranceExpiry) || other.insuranceExpiry == insuranceExpiry)&&(identical(other.hasAC, hasAC) || other.hasAC == hasAC)&&(identical(other.hasCharger, hasCharger) || other.hasCharger == hasCharger)&&(identical(other.hasWifi, hasWifi) || other.hasWifi == hasWifi)&&(identical(other.petsAllowed, petsAllowed) || other.petsAllowed == petsAllowed)&&(identical(other.smokingAllowed, smokingAllowed) || other.smokingAllowed == smokingAllowed)&&(identical(other.hasLuggage, hasLuggage) || other.hasLuggage == hasLuggage)&&(identical(other.totalRides, totalRides) || other.totalRides == totalRides)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,ownerId,make,model,year,color,licensePlate,capacity,fuelType,imageUrl,const DeepCollectionEquality().hash(imageUrls),isActive,verificationStatus,verificationNote,registrationDocUrl,insuranceDocUrl,insuranceExpiry,hasAC,hasCharger,hasWifi,petsAllowed,smokingAllowed,hasLuggage,totalRides,averageRating,createdAt,updatedAt]);

@override
String toString() {
  return 'VehicleModel(id: $id, ownerId: $ownerId, make: $make, model: $model, year: $year, color: $color, licensePlate: $licensePlate, capacity: $capacity, fuelType: $fuelType, imageUrl: $imageUrl, imageUrls: $imageUrls, isActive: $isActive, verificationStatus: $verificationStatus, verificationNote: $verificationNote, registrationDocUrl: $registrationDocUrl, insuranceDocUrl: $insuranceDocUrl, insuranceExpiry: $insuranceExpiry, hasAC: $hasAC, hasCharger: $hasCharger, hasWifi: $hasWifi, petsAllowed: $petsAllowed, smokingAllowed: $smokingAllowed, hasLuggage: $hasLuggage, totalRides: $totalRides, averageRating: $averageRating, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $VehicleModelCopyWith<$Res>  {
  factory $VehicleModelCopyWith(VehicleModel value, $Res Function(VehicleModel) _then) = _$VehicleModelCopyWithImpl;
@useResult
$Res call({
 String id, String ownerId, String make, String model, int year, String color, String licensePlate, int capacity, FuelType fuelType, String? imageUrl, List<String> imageUrls, bool isActive, VehicleVerificationStatus verificationStatus, String? verificationNote, String? registrationDocUrl, String? insuranceDocUrl,@TimestampConverter() DateTime? insuranceExpiry, bool hasAC, bool hasCharger, bool hasWifi, bool petsAllowed, bool smokingAllowed, bool hasLuggage, int totalRides, double averageRating,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$VehicleModelCopyWithImpl<$Res>
    implements $VehicleModelCopyWith<$Res> {
  _$VehicleModelCopyWithImpl(this._self, this._then);

  final VehicleModel _self;
  final $Res Function(VehicleModel) _then;

/// Create a copy of VehicleModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? make = null,Object? model = null,Object? year = null,Object? color = null,Object? licensePlate = null,Object? capacity = null,Object? fuelType = null,Object? imageUrl = freezed,Object? imageUrls = null,Object? isActive = null,Object? verificationStatus = null,Object? verificationNote = freezed,Object? registrationDocUrl = freezed,Object? insuranceDocUrl = freezed,Object? insuranceExpiry = freezed,Object? hasAC = null,Object? hasCharger = null,Object? hasWifi = null,Object? petsAllowed = null,Object? smokingAllowed = null,Object? hasLuggage = null,Object? totalRides = null,Object? averageRating = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,make: null == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,licensePlate: null == licensePlate ? _self.licensePlate : licensePlate // ignore: cast_nullable_to_non_nullable
as String,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,fuelType: null == fuelType ? _self.fuelType : fuelType // ignore: cast_nullable_to_non_nullable
as FuelType,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VehicleVerificationStatus,verificationNote: freezed == verificationNote ? _self.verificationNote : verificationNote // ignore: cast_nullable_to_non_nullable
as String?,registrationDocUrl: freezed == registrationDocUrl ? _self.registrationDocUrl : registrationDocUrl // ignore: cast_nullable_to_non_nullable
as String?,insuranceDocUrl: freezed == insuranceDocUrl ? _self.insuranceDocUrl : insuranceDocUrl // ignore: cast_nullable_to_non_nullable
as String?,insuranceExpiry: freezed == insuranceExpiry ? _self.insuranceExpiry : insuranceExpiry // ignore: cast_nullable_to_non_nullable
as DateTime?,hasAC: null == hasAC ? _self.hasAC : hasAC // ignore: cast_nullable_to_non_nullable
as bool,hasCharger: null == hasCharger ? _self.hasCharger : hasCharger // ignore: cast_nullable_to_non_nullable
as bool,hasWifi: null == hasWifi ? _self.hasWifi : hasWifi // ignore: cast_nullable_to_non_nullable
as bool,petsAllowed: null == petsAllowed ? _self.petsAllowed : petsAllowed // ignore: cast_nullable_to_non_nullable
as bool,smokingAllowed: null == smokingAllowed ? _self.smokingAllowed : smokingAllowed // ignore: cast_nullable_to_non_nullable
as bool,hasLuggage: null == hasLuggage ? _self.hasLuggage : hasLuggage // ignore: cast_nullable_to_non_nullable
as bool,totalRides: null == totalRides ? _self.totalRides : totalRides // ignore: cast_nullable_to_non_nullable
as int,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [VehicleModel].
extension VehicleModelPatterns on VehicleModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VehicleModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VehicleModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VehicleModel value)  $default,){
final _that = this;
switch (_that) {
case _VehicleModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VehicleModel value)?  $default,){
final _that = this;
switch (_that) {
case _VehicleModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ownerId,  String make,  String model,  int year,  String color,  String licensePlate,  int capacity,  FuelType fuelType,  String? imageUrl,  List<String> imageUrls,  bool isActive,  VehicleVerificationStatus verificationStatus,  String? verificationNote,  String? registrationDocUrl,  String? insuranceDocUrl, @TimestampConverter()  DateTime? insuranceExpiry,  bool hasAC,  bool hasCharger,  bool hasWifi,  bool petsAllowed,  bool smokingAllowed,  bool hasLuggage,  int totalRides,  double averageRating, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VehicleModel() when $default != null:
return $default(_that.id,_that.ownerId,_that.make,_that.model,_that.year,_that.color,_that.licensePlate,_that.capacity,_that.fuelType,_that.imageUrl,_that.imageUrls,_that.isActive,_that.verificationStatus,_that.verificationNote,_that.registrationDocUrl,_that.insuranceDocUrl,_that.insuranceExpiry,_that.hasAC,_that.hasCharger,_that.hasWifi,_that.petsAllowed,_that.smokingAllowed,_that.hasLuggage,_that.totalRides,_that.averageRating,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ownerId,  String make,  String model,  int year,  String color,  String licensePlate,  int capacity,  FuelType fuelType,  String? imageUrl,  List<String> imageUrls,  bool isActive,  VehicleVerificationStatus verificationStatus,  String? verificationNote,  String? registrationDocUrl,  String? insuranceDocUrl, @TimestampConverter()  DateTime? insuranceExpiry,  bool hasAC,  bool hasCharger,  bool hasWifi,  bool petsAllowed,  bool smokingAllowed,  bool hasLuggage,  int totalRides,  double averageRating, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _VehicleModel():
return $default(_that.id,_that.ownerId,_that.make,_that.model,_that.year,_that.color,_that.licensePlate,_that.capacity,_that.fuelType,_that.imageUrl,_that.imageUrls,_that.isActive,_that.verificationStatus,_that.verificationNote,_that.registrationDocUrl,_that.insuranceDocUrl,_that.insuranceExpiry,_that.hasAC,_that.hasCharger,_that.hasWifi,_that.petsAllowed,_that.smokingAllowed,_that.hasLuggage,_that.totalRides,_that.averageRating,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ownerId,  String make,  String model,  int year,  String color,  String licensePlate,  int capacity,  FuelType fuelType,  String? imageUrl,  List<String> imageUrls,  bool isActive,  VehicleVerificationStatus verificationStatus,  String? verificationNote,  String? registrationDocUrl,  String? insuranceDocUrl, @TimestampConverter()  DateTime? insuranceExpiry,  bool hasAC,  bool hasCharger,  bool hasWifi,  bool petsAllowed,  bool smokingAllowed,  bool hasLuggage,  int totalRides,  double averageRating, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _VehicleModel() when $default != null:
return $default(_that.id,_that.ownerId,_that.make,_that.model,_that.year,_that.color,_that.licensePlate,_that.capacity,_that.fuelType,_that.imageUrl,_that.imageUrls,_that.isActive,_that.verificationStatus,_that.verificationNote,_that.registrationDocUrl,_that.insuranceDocUrl,_that.insuranceExpiry,_that.hasAC,_that.hasCharger,_that.hasWifi,_that.petsAllowed,_that.smokingAllowed,_that.hasLuggage,_that.totalRides,_that.averageRating,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VehicleModel extends VehicleModel {
  const _VehicleModel({required this.id, required this.ownerId, required this.make, required this.model, required this.year, required this.color, required this.licensePlate, this.capacity = 4, this.fuelType = FuelType.gasoline, this.imageUrl, final  List<String> imageUrls = const [], this.isActive = false, this.verificationStatus = VehicleVerificationStatus.pending, this.verificationNote, this.registrationDocUrl, this.insuranceDocUrl, @TimestampConverter() this.insuranceExpiry, this.hasAC = false, this.hasCharger = false, this.hasWifi = false, this.petsAllowed = false, this.smokingAllowed = false, this.hasLuggage = false, this.totalRides = 0, this.averageRating = 0.0, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt}): _imageUrls = imageUrls,super._();
  factory _VehicleModel.fromJson(Map<String, dynamic> json) => _$VehicleModelFromJson(json);

@override final  String id;
@override final  String ownerId;
@override final  String make;
@override final  String model;
@override final  int year;
@override final  String color;
@override final  String licensePlate;
@override@JsonKey() final  int capacity;
@override@JsonKey() final  FuelType fuelType;
@override final  String? imageUrl;
 final  List<String> _imageUrls;
@override@JsonKey() List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

@override@JsonKey() final  bool isActive;
@override@JsonKey() final  VehicleVerificationStatus verificationStatus;
@override final  String? verificationNote;
// Vehicle documents
@override final  String? registrationDocUrl;
@override final  String? insuranceDocUrl;
@override@TimestampConverter() final  DateTime? insuranceExpiry;
// Vehicle features/amenities
@override@JsonKey() final  bool hasAC;
@override@JsonKey() final  bool hasCharger;
@override@JsonKey() final  bool hasWifi;
@override@JsonKey() final  bool petsAllowed;
@override@JsonKey() final  bool smokingAllowed;
@override@JsonKey() final  bool hasLuggage;
// Stats
@override@JsonKey() final  int totalRides;
@override@JsonKey() final  double averageRating;
// Timestamps
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;

/// Create a copy of VehicleModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleModelCopyWith<_VehicleModel> get copyWith => __$VehicleModelCopyWithImpl<_VehicleModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VehicleModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VehicleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.make, make) || other.make == make)&&(identical(other.model, model) || other.model == model)&&(identical(other.year, year) || other.year == year)&&(identical(other.color, color) || other.color == color)&&(identical(other.licensePlate, licensePlate) || other.licensePlate == licensePlate)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.fuelType, fuelType) || other.fuelType == fuelType)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.verificationNote, verificationNote) || other.verificationNote == verificationNote)&&(identical(other.registrationDocUrl, registrationDocUrl) || other.registrationDocUrl == registrationDocUrl)&&(identical(other.insuranceDocUrl, insuranceDocUrl) || other.insuranceDocUrl == insuranceDocUrl)&&(identical(other.insuranceExpiry, insuranceExpiry) || other.insuranceExpiry == insuranceExpiry)&&(identical(other.hasAC, hasAC) || other.hasAC == hasAC)&&(identical(other.hasCharger, hasCharger) || other.hasCharger == hasCharger)&&(identical(other.hasWifi, hasWifi) || other.hasWifi == hasWifi)&&(identical(other.petsAllowed, petsAllowed) || other.petsAllowed == petsAllowed)&&(identical(other.smokingAllowed, smokingAllowed) || other.smokingAllowed == smokingAllowed)&&(identical(other.hasLuggage, hasLuggage) || other.hasLuggage == hasLuggage)&&(identical(other.totalRides, totalRides) || other.totalRides == totalRides)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,ownerId,make,model,year,color,licensePlate,capacity,fuelType,imageUrl,const DeepCollectionEquality().hash(_imageUrls),isActive,verificationStatus,verificationNote,registrationDocUrl,insuranceDocUrl,insuranceExpiry,hasAC,hasCharger,hasWifi,petsAllowed,smokingAllowed,hasLuggage,totalRides,averageRating,createdAt,updatedAt]);

@override
String toString() {
  return 'VehicleModel(id: $id, ownerId: $ownerId, make: $make, model: $model, year: $year, color: $color, licensePlate: $licensePlate, capacity: $capacity, fuelType: $fuelType, imageUrl: $imageUrl, imageUrls: $imageUrls, isActive: $isActive, verificationStatus: $verificationStatus, verificationNote: $verificationNote, registrationDocUrl: $registrationDocUrl, insuranceDocUrl: $insuranceDocUrl, insuranceExpiry: $insuranceExpiry, hasAC: $hasAC, hasCharger: $hasCharger, hasWifi: $hasWifi, petsAllowed: $petsAllowed, smokingAllowed: $smokingAllowed, hasLuggage: $hasLuggage, totalRides: $totalRides, averageRating: $averageRating, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$VehicleModelCopyWith<$Res> implements $VehicleModelCopyWith<$Res> {
  factory _$VehicleModelCopyWith(_VehicleModel value, $Res Function(_VehicleModel) _then) = __$VehicleModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String ownerId, String make, String model, int year, String color, String licensePlate, int capacity, FuelType fuelType, String? imageUrl, List<String> imageUrls, bool isActive, VehicleVerificationStatus verificationStatus, String? verificationNote, String? registrationDocUrl, String? insuranceDocUrl,@TimestampConverter() DateTime? insuranceExpiry, bool hasAC, bool hasCharger, bool hasWifi, bool petsAllowed, bool smokingAllowed, bool hasLuggage, int totalRides, double averageRating,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$VehicleModelCopyWithImpl<$Res>
    implements _$VehicleModelCopyWith<$Res> {
  __$VehicleModelCopyWithImpl(this._self, this._then);

  final _VehicleModel _self;
  final $Res Function(_VehicleModel) _then;

/// Create a copy of VehicleModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? make = null,Object? model = null,Object? year = null,Object? color = null,Object? licensePlate = null,Object? capacity = null,Object? fuelType = null,Object? imageUrl = freezed,Object? imageUrls = null,Object? isActive = null,Object? verificationStatus = null,Object? verificationNote = freezed,Object? registrationDocUrl = freezed,Object? insuranceDocUrl = freezed,Object? insuranceExpiry = freezed,Object? hasAC = null,Object? hasCharger = null,Object? hasWifi = null,Object? petsAllowed = null,Object? smokingAllowed = null,Object? hasLuggage = null,Object? totalRides = null,Object? averageRating = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_VehicleModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,make: null == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,licensePlate: null == licensePlate ? _self.licensePlate : licensePlate // ignore: cast_nullable_to_non_nullable
as String,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,fuelType: null == fuelType ? _self.fuelType : fuelType // ignore: cast_nullable_to_non_nullable
as FuelType,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VehicleVerificationStatus,verificationNote: freezed == verificationNote ? _self.verificationNote : verificationNote // ignore: cast_nullable_to_non_nullable
as String?,registrationDocUrl: freezed == registrationDocUrl ? _self.registrationDocUrl : registrationDocUrl // ignore: cast_nullable_to_non_nullable
as String?,insuranceDocUrl: freezed == insuranceDocUrl ? _self.insuranceDocUrl : insuranceDocUrl // ignore: cast_nullable_to_non_nullable
as String?,insuranceExpiry: freezed == insuranceExpiry ? _self.insuranceExpiry : insuranceExpiry // ignore: cast_nullable_to_non_nullable
as DateTime?,hasAC: null == hasAC ? _self.hasAC : hasAC // ignore: cast_nullable_to_non_nullable
as bool,hasCharger: null == hasCharger ? _self.hasCharger : hasCharger // ignore: cast_nullable_to_non_nullable
as bool,hasWifi: null == hasWifi ? _self.hasWifi : hasWifi // ignore: cast_nullable_to_non_nullable
as bool,petsAllowed: null == petsAllowed ? _self.petsAllowed : petsAllowed // ignore: cast_nullable_to_non_nullable
as bool,smokingAllowed: null == smokingAllowed ? _self.smokingAllowed : smokingAllowed // ignore: cast_nullable_to_non_nullable
as bool,hasLuggage: null == hasLuggage ? _self.hasLuggage : hasLuggage // ignore: cast_nullable_to_non_nullable
as bool,totalRides: null == totalRides ? _self.totalRides : totalRides // ignore: cast_nullable_to_non_nullable
as int,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$apiServiceHash() => r'73ad3c2e8c0d458c43bdd728c0f0fb75c5c2af98';

/// See also [apiService].
@ProviderFor(apiService)
final apiServiceProvider = AutoDisposeProvider<ApiService>.internal(
  apiService,
  name: r'apiServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$apiServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ApiServiceRef = AutoDisposeProviderRef<ApiService>;
String _$currentUserHash() => r'9d8500433c9ed6dd74d0f6a561b410eff2d370c1';

/// See also [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeFutureProvider<User?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeFutureProviderRef<User?>;
String _$isAuthenticatedHash() => r'8830e3287c642d4614d0c7566ca5bcaec01a440c';

/// See also [isAuthenticated].
@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = AutoDisposeFutureProvider<bool>.internal(
  isAuthenticated,
  name: r'isAuthenticatedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAuthenticatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAuthenticatedRef = AutoDisposeFutureProviderRef<bool>;
String _$userTeamsHash() => r'44fac212c79e498360a3e72f0b0c55e9cf611895';

/// See also [userTeams].
@ProviderFor(userTeams)
final userTeamsProvider = AutoDisposeFutureProvider<List<Team>>.internal(
  userTeams,
  name: r'userTeamsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userTeamsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserTeamsRef = AutoDisposeFutureProviderRef<List<Team>>;
String _$userTeamsDetailedHash() => r'bff62806e8f036f524ea26fad4a82a0110da96f6';

/// See also [userTeamsDetailed].
@ProviderFor(userTeamsDetailed)
final userTeamsDetailedProvider =
    AutoDisposeFutureProvider<UserTeamsDetailed>.internal(
      userTeamsDetailed,
      name: r'userTeamsDetailedProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userTeamsDetailedHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserTeamsDetailedRef = AutoDisposeFutureProviderRef<UserTeamsDetailed>;
String _$userDonationsHash() => r'0a3656828e6d41f191853f855e426d4121e7d764';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [userDonations].
@ProviderFor(userDonations)
const userDonationsProvider = UserDonationsFamily();

/// See also [userDonations].
class UserDonationsFamily extends Family<AsyncValue<DonationsResponse>> {
  /// See also [userDonations].
  const UserDonationsFamily();

  /// See also [userDonations].
  UserDonationsProvider call({int pageNumber = 1, int pageSize = 5}) {
    return UserDonationsProvider(pageNumber: pageNumber, pageSize: pageSize);
  }

  @override
  UserDonationsProvider getProviderOverride(
    covariant UserDonationsProvider provider,
  ) {
    return call(pageNumber: provider.pageNumber, pageSize: provider.pageSize);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userDonationsProvider';
}

/// See also [userDonations].
class UserDonationsProvider
    extends AutoDisposeFutureProvider<DonationsResponse> {
  /// See also [userDonations].
  UserDonationsProvider({int pageNumber = 1, int pageSize = 5})
    : this._internal(
        (ref) => userDonations(
          ref as UserDonationsRef,
          pageNumber: pageNumber,
          pageSize: pageSize,
        ),
        from: userDonationsProvider,
        name: r'userDonationsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userDonationsHash,
        dependencies: UserDonationsFamily._dependencies,
        allTransitiveDependencies:
            UserDonationsFamily._allTransitiveDependencies,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

  UserDonationsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pageNumber,
    required this.pageSize,
  }) : super.internal();

  final int pageNumber;
  final int pageSize;

  @override
  Override overrideWith(
    FutureOr<DonationsResponse> Function(UserDonationsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserDonationsProvider._internal(
        (ref) => create(ref as UserDonationsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DonationsResponse> createElement() {
    return _UserDonationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserDonationsProvider &&
        other.pageNumber == pageNumber &&
        other.pageSize == pageSize;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pageNumber.hashCode);
    hash = _SystemHash.combine(hash, pageSize.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserDonationsRef on AutoDisposeFutureProviderRef<DonationsResponse> {
  /// The parameter `pageNumber` of this provider.
  int get pageNumber;

  /// The parameter `pageSize` of this provider.
  int get pageSize;
}

class _UserDonationsProviderElement
    extends AutoDisposeFutureProviderElement<DonationsResponse>
    with UserDonationsRef {
  _UserDonationsProviderElement(super.provider);

  @override
  int get pageNumber => (origin as UserDonationsProvider).pageNumber;
  @override
  int get pageSize => (origin as UserDonationsProvider).pageSize;
}

String _$userTargetsHash() => r'1b0632b6232027b3dfe741631f0cab0892505c9a';

/// See also [userTargets].
@ProviderFor(userTargets)
const userTargetsProvider = UserTargetsFamily();

/// See also [userTargets].
class UserTargetsFamily extends Family<AsyncValue<dynamic>> {
  /// See also [userTargets].
  const UserTargetsFamily();

  /// See also [userTargets].
  UserTargetsProvider call({int pageNumber = 1, int pageSize = 10}) {
    return UserTargetsProvider(pageNumber: pageNumber, pageSize: pageSize);
  }

  @override
  UserTargetsProvider getProviderOverride(
    covariant UserTargetsProvider provider,
  ) {
    return call(pageNumber: provider.pageNumber, pageSize: provider.pageSize);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userTargetsProvider';
}

/// See also [userTargets].
class UserTargetsProvider extends AutoDisposeFutureProvider<dynamic> {
  /// See also [userTargets].
  UserTargetsProvider({int pageNumber = 1, int pageSize = 10})
    : this._internal(
        (ref) => userTargets(
          ref as UserTargetsRef,
          pageNumber: pageNumber,
          pageSize: pageSize,
        ),
        from: userTargetsProvider,
        name: r'userTargetsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userTargetsHash,
        dependencies: UserTargetsFamily._dependencies,
        allTransitiveDependencies: UserTargetsFamily._allTransitiveDependencies,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

  UserTargetsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pageNumber,
    required this.pageSize,
  }) : super.internal();

  final int pageNumber;
  final int pageSize;

  @override
  Override overrideWith(
    FutureOr<dynamic> Function(UserTargetsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserTargetsProvider._internal(
        (ref) => create(ref as UserTargetsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<dynamic> createElement() {
    return _UserTargetsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserTargetsProvider &&
        other.pageNumber == pageNumber &&
        other.pageSize == pageSize;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pageNumber.hashCode);
    hash = _SystemHash.combine(hash, pageSize.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserTargetsRef on AutoDisposeFutureProviderRef<dynamic> {
  /// The parameter `pageNumber` of this provider.
  int get pageNumber;

  /// The parameter `pageSize` of this provider.
  int get pageSize;
}

class _UserTargetsProviderElement
    extends AutoDisposeFutureProviderElement<dynamic>
    with UserTargetsRef {
  _UserTargetsProviderElement(super.provider);

  @override
  int get pageNumber => (origin as UserTargetsProvider).pageNumber;
  @override
  int get pageSize => (origin as UserTargetsProvider).pageSize;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$databaseHelperHash() => r'd9a91b257d3ed9a4f2d87bd829e17dc900678685';

/// See also [databaseHelper].
@ProviderFor(databaseHelper)
final databaseHelperProvider = AutoDisposeProvider<DatabaseHelper>.internal(
  databaseHelper,
  name: r'databaseHelperProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$databaseHelperHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseHelperRef = AutoDisposeProviderRef<DatabaseHelper>;
String _$spicesBoardServiceHash() =>
    r'2a2bd48fb2f9b3f9b49f6b53a7af04fbffa90587';

/// See also [spicesBoardService].
@ProviderFor(spicesBoardService)
final spicesBoardServiceProvider =
    AutoDisposeProvider<SpicesBoardService>.internal(
      spicesBoardService,
      name: r'spicesBoardServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$spicesBoardServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SpicesBoardServiceRef = AutoDisposeProviderRef<SpicesBoardService>;
String _$syncServiceHash() => r'ddc8d5b94448e36ec880773d3dba17237e503c2f';

/// See also [syncService].
@ProviderFor(syncService)
final syncServiceProvider = AutoDisposeProvider<SyncService>.internal(
  syncService,
  name: r'syncServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncServiceRef = AutoDisposeProviderRef<SyncService>;
String _$dataSeederServiceHash() => r'de04cefd64cba5369ff575dcac668ae98f094b82';

/// See also [dataSeederService].
@ProviderFor(dataSeederService)
final dataSeederServiceProvider =
    AutoDisposeProvider<DataSeederService>.internal(
      dataSeederService,
      name: r'dataSeederServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dataSeederServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DataSeederServiceRef = AutoDisposeProviderRef<DataSeederService>;
String _$priceAnalyticsServiceHash() =>
    r'e79dc74c77117009184f80ca9e6527e90d8778dc';

/// See also [priceAnalyticsService].
@ProviderFor(priceAnalyticsService)
final priceAnalyticsServiceProvider =
    AutoDisposeProvider<PriceAnalyticsService>.internal(
      priceAnalyticsService,
      name: r'priceAnalyticsServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$priceAnalyticsServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PriceAnalyticsServiceRef =
    AutoDisposeProviderRef<PriceAnalyticsService>;
String _$historicalFullPricesHash() =>
    r'4cbc4d1801994c8c6a63e72d5a45358df172c430';

/// See also [historicalFullPrices].
@ProviderFor(historicalFullPrices)
final historicalFullPricesProvider =
    AutoDisposeFutureProvider<List<AuctionData>>.internal(
      historicalFullPrices,
      name: r'historicalFullPricesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$historicalFullPricesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HistoricalFullPricesRef =
    AutoDisposeFutureProviderRef<List<AuctionData>>;
String _$dailyPricesHash() => r'75ed0e75b99135da9773af5a1e9607f887f4380d';

/// See also [dailyPrices].
@ProviderFor(dailyPrices)
final dailyPricesProvider =
    AutoDisposeFutureProvider<List<AuctionData>>.internal(
      dailyPrices,
      name: r'dailyPricesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dailyPricesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DailyPricesRef = AutoDisposeFutureProviderRef<List<AuctionData>>;
String _$historicalPricesHash() => r'75c019c3d7fe06bffa011f151f7745503ab19ee6';

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

/// See also [historicalPrices].
@ProviderFor(historicalPrices)
const historicalPricesProvider = HistoricalPricesFamily();

/// See also [historicalPrices].
class HistoricalPricesFamily extends Family<AsyncValue<List<AuctionData>>> {
  /// See also [historicalPrices].
  const HistoricalPricesFamily();

  /// See also [historicalPrices].
  HistoricalPricesProvider call({DateTime? fromDate, DateTime? toDate}) {
    return HistoricalPricesProvider(fromDate: fromDate, toDate: toDate);
  }

  @override
  HistoricalPricesProvider getProviderOverride(
    covariant HistoricalPricesProvider provider,
  ) {
    return call(fromDate: provider.fromDate, toDate: provider.toDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'historicalPricesProvider';
}

/// See also [historicalPrices].
class HistoricalPricesProvider
    extends AutoDisposeFutureProvider<List<AuctionData>> {
  /// See also [historicalPrices].
  HistoricalPricesProvider({DateTime? fromDate, DateTime? toDate})
    : this._internal(
        (ref) => historicalPrices(
          ref as HistoricalPricesRef,
          fromDate: fromDate,
          toDate: toDate,
        ),
        from: historicalPricesProvider,
        name: r'historicalPricesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$historicalPricesHash,
        dependencies: HistoricalPricesFamily._dependencies,
        allTransitiveDependencies:
            HistoricalPricesFamily._allTransitiveDependencies,
        fromDate: fromDate,
        toDate: toDate,
      );

  HistoricalPricesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.fromDate,
    required this.toDate,
  }) : super.internal();

  final DateTime? fromDate;
  final DateTime? toDate;

  @override
  Override overrideWith(
    FutureOr<List<AuctionData>> Function(HistoricalPricesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HistoricalPricesProvider._internal(
        (ref) => create(ref as HistoricalPricesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        fromDate: fromDate,
        toDate: toDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<AuctionData>> createElement() {
    return _HistoricalPricesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HistoricalPricesProvider &&
        other.fromDate == fromDate &&
        other.toDate == toDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, fromDate.hashCode);
    hash = _SystemHash.combine(hash, toDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HistoricalPricesRef on AutoDisposeFutureProviderRef<List<AuctionData>> {
  /// The parameter `fromDate` of this provider.
  DateTime? get fromDate;

  /// The parameter `toDate` of this provider.
  DateTime? get toDate;
}

class _HistoricalPricesProviderElement
    extends AutoDisposeFutureProviderElement<List<AuctionData>>
    with HistoricalPricesRef {
  _HistoricalPricesProviderElement(super.provider);

  @override
  DateTime? get fromDate => (origin as HistoricalPricesProvider).fromDate;
  @override
  DateTime? get toDate => (origin as HistoricalPricesProvider).toDate;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

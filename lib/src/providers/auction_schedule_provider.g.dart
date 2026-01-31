// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auction_schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$auctionScheduleServiceHash() =>
    r'cdc861e18517cd02208981aa2c8d9f3123050a1c';

/// See also [auctionScheduleService].
@ProviderFor(auctionScheduleService)
final auctionScheduleServiceProvider =
    AutoDisposeProvider<AuctionScheduleService>.internal(
      auctionScheduleService,
      name: r'auctionScheduleServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$auctionScheduleServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuctionScheduleServiceRef =
    AutoDisposeProviderRef<AuctionScheduleService>;
String _$upcomingAuctionsHash() => r'5b10953518d3133c732cfb60f745a9d563cd7b9f';

/// See also [upcomingAuctions].
@ProviderFor(upcomingAuctions)
final upcomingAuctionsProvider = FutureProvider<List<AuctionSchedule>>.internal(
  upcomingAuctions,
  name: r'upcomingAuctionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$upcomingAuctionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpcomingAuctionsRef = FutureProviderRef<List<AuctionSchedule>>;
String _$isAuctionLiveNowHash() => r'4dd7a393f53b4ada5d0770649ec28576bcc3631f';

/// See also [isAuctionLiveNow].
@ProviderFor(isAuctionLiveNow)
final isAuctionLiveNowProvider = FutureProvider<bool>.internal(
  isAuctionLiveNow,
  name: r'isAuctionLiveNowProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAuctionLiveNowHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAuctionLiveNowRef = FutureProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

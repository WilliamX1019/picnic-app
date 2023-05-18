import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:picnic_app/core/domain/model/basic_public_profile.dart';
import 'package:picnic_app/core/domain/model/cursor.dart';
import 'package:picnic_app/core/utils/bloc_extensions.dart';
import 'package:picnic_app/core/utils/either_extensions.dart';
import 'package:picnic_app/features/analytics/domain/model/analytics_event.dart';
import 'package:picnic_app/features/analytics/domain/model/tap/analytics_tap_target.dart';
import 'package:picnic_app/features/analytics/domain/use_cases/log_analytics_event_use_case.dart';
import 'package:picnic_app/features/chat/domain/model/id.dart';
import 'package:picnic_app/features/circles/add_circle_pod/add_circle_pod_initial_params.dart';
import 'package:picnic_app/features/circles/circle_details/circle_details_initial_params.dart';
import 'package:picnic_app/features/circles/domain/use_cases/get_pods_use_case.dart';
import 'package:picnic_app/features/discover/discover_explore/discover_explore_navigator.dart';
import 'package:picnic_app/features/discover/discover_explore/discover_explore_presentation_model.dart';
import 'package:picnic_app/features/discover/discover_search_results/discover_search_results_initial_params.dart';
import 'package:picnic_app/features/discover/domain/use_cases/discover_use_case.dart';
import 'package:picnic_app/features/feed/domain/model/get_popular_feed_failure.dart';
import 'package:picnic_app/features/feed/domain/use_cases/get_popular_feed_use_case.dart';
import 'package:picnic_app/features/posts/domain/model/posts/post.dart';
import 'package:picnic_app/features/posts/single_feed/single_feed_initial_params.dart';
import 'package:picnic_app/features/profile/public_profile/public_profile_initial_params.dart';

class DiscoverExplorePresenter extends Cubit<DiscoverExploreViewModel> {
  DiscoverExplorePresenter(
    DiscoverExplorePresentationModel model,
    this.navigator,
    this._discoverUseCase,
    this._popularFeedUseCase,
    this._getPodsUseCase,
    this._logAnalyticsEventUseCase,
  ) : super(model);

  final DiscoverExploreNavigator navigator;
  final DiscoverUseCase _discoverUseCase;
  final GetPopularFeedUseCase _popularFeedUseCase;
  final GetPodsUseCase _getPodsUseCase;
  final LogAnalyticsEventUseCase _logAnalyticsEventUseCase;

  DiscoverExplorePresentationModel get _model => state as DiscoverExplorePresentationModel;

  Future<void> init() {
    return Future.wait(
      [
        _discoverUseCase.execute().doOn(
              success: (result) => tryEmit(_model.copyWith(feedGroups: result)),
            ),
        _loadPosts(),
      ],
    );
  }

  Future<void> loadMore({bool fromScratch = false}) async {
    await _getPodsUseCase
        .execute(
          circleId: const Id.empty(),
          cursor: fromScratch ? const Cursor.firstPage() : _model.pods.nextPageCursor(),
        )
        .doOn(
          success: (pods) {
            tryEmit(
              fromScratch ? _model.copyWith(pods: pods) : _model.byAppendingPodsList(newList: pods),
            );
          },
          fail: (fail) => navigator.showError(fail.displayableFailure()),
        );
  }

  void onTapSearchBar() => navigator.openDiscoverSearchResults(const DiscoverSearchResultsInitialParams());

  void onTapViewPost(Post post) => navigator.openSingleFeed(
        SingleFeedInitialParams.noPagination(
          posts: _model.popularFeedPosts,
          initialIndex: _model.popularFeedPosts.indexOf(post),
          onPostsListUpdated: (posts) => tryEmit(_model.copyWith(popularFeedPosts: posts)),
          refresh: () => _loadPosts().mapFailure((f) => f.displayableFailure()),
        ),
      );

  void onTapViewCircle(Id circleId) => navigator.openCircleDetails(CircleDetailsInitialParams(circleId: circleId));

  void onTapProfile(BasicPublicProfile value) => navigator.openPublicProfile(
        PublicProfileInitialParams(userId: value.id),
      );

  void onTapViewProfile(Id id) {
    navigator.openProfile(userId: id);
  }

  void onTapViewPod(Id podId) {
    _logAnalyticsEventUseCase.execute(
      AnalyticsEvent.tap(
        target: AnalyticsTapTarget.circlePod,
        targetValue: podId.value,
      ),
    );
    navigator.openAddCirclePod(AddCirclePodInitialParams(podId: podId));
  }

  Future<Either<GetPopularFeedFailure, List<Post>>> _loadPosts() => _popularFeedUseCase.execute().doOn(
        success: (result) => tryEmit(_model.copyWith(popularFeedPosts: result.items)),
      );
}

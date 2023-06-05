import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:picnic_app/core/domain/model/basic_public_profile.dart';
import 'package:picnic_app/core/domain/model/circle.dart';
import 'package:picnic_app/core/utils/bloc_extensions.dart';
import 'package:picnic_app/core/utils/either_extensions.dart';
import 'package:picnic_app/features/chat/circle_chat/circle_chat_initial_params.dart';
import 'package:picnic_app/features/chat/domain/model/id.dart';
import 'package:picnic_app/features/chat/domain/use_cases/get_chat_use_case.dart';
import 'package:picnic_app/features/circles/circle_details/circle_details_initial_params.dart';
import 'package:picnic_app/features/discover/discover_circles/discover_circles_navigator.dart';
import 'package:picnic_app/features/discover/discover_circles/discover_circles_presentation_model.dart';
import 'package:picnic_app/features/discover/discover_search_results/discover_search_results_initial_params.dart';
import 'package:picnic_app/features/discover/domain/use_cases/discover_use_case.dart';
import 'package:picnic_app/features/feed/domain/model/get_popular_feed_failure.dart';
import 'package:picnic_app/features/feed/domain/use_cases/get_popular_feed_use_case.dart';
import 'package:picnic_app/features/posts/domain/model/posts/post.dart';
import 'package:picnic_app/features/posts/single_feed/single_feed_initial_params.dart';
import 'package:picnic_app/features/profile/public_profile/public_profile_initial_params.dart';

class DiscoverCirclesPresenter extends Cubit<DiscoverCirclesViewModel> {
  DiscoverCirclesPresenter(
    DiscoverCirclesPresentationModel model,
    this.navigator,
    this._discoverUseCase,
    this._popularFeedUseCase,
    this._getChatUseCase,
  ) : super(model);

  final DiscoverCirclesNavigator navigator;
  final DiscoverUseCase _discoverUseCase;
  final GetPopularFeedUseCase _popularFeedUseCase;
  final GetChatUseCase _getChatUseCase;

  DiscoverCirclesPresentationModel get _model => state as DiscoverCirclesPresentationModel;

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

  void onTapShareCircle(Circle circle) => navigator.shareText(text: circle.shareLink);

  Future<void> onTapCircleChat(Circle circle) async {
    await _getChatUseCase
        .execute(
          chatId: circle.chat.id,
        )
        .doOnSuccessWait(
          (chat) => navigator.openCircleChat(
            CircleChatInitialParams(
              chat: chat,
            ),
          ),
        );
  }

  void onTapProfile(BasicPublicProfile value) => navigator.openPublicProfile(
        PublicProfileInitialParams(userId: value.id),
      );

  void onTapViewProfile(Id id) {
    navigator.openProfile(userId: id);
  }

  Future<Either<GetPopularFeedFailure, List<Post>>> _loadPosts() => _popularFeedUseCase.execute().doOn(
        success: (result) => tryEmit(_model.copyWith(popularFeedPosts: result.items)),
      );
}

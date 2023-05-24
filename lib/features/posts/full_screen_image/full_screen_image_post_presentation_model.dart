import 'package:picnic_app/core/domain/model/basic_circle.dart';
import 'package:picnic_app/core/domain/model/private_profile.dart';
import 'package:picnic_app/core/domain/stores/user_store.dart';
import 'package:picnic_app/features/posts/domain/model/post_contents/image_post_content.dart';
import 'package:picnic_app/features/posts/domain/model/posts/post.dart';
import 'package:picnic_app/features/posts/full_screen_image/full_screen_image_post_initial_params.dart';

/// Model used by presenter, contains fields that are relevant to presenters and implements ViewModel to expose data to view (page)
class FullScreenImagePostPresentationModel implements FullScreenImagePostViewModel {
  /// Creates the initial state
  FullScreenImagePostPresentationModel.initial(
    // ignore: avoid_unused_constructor_parameters
    FullScreenImagePostInitialParams initialParams,
    UserStore userStore,
  )   : privateProfile = userStore.privateProfile,
        post = initialParams.post;

  /// Used for the copyWith method
  FullScreenImagePostPresentationModel._({
    required this.post,
    required this.privateProfile,
  });

  @override
  final Post post;

  final PrivateProfile privateProfile;

  @override
  ImagePostContent get imagePostContent => post.content as ImagePostContent;

  @override
  bool get canDeletePost => isAuthor || circle.permissions.canManagePosts;

  @override
  bool get canReportPost => !isAuthor;

  @override
  bool get isAuthor => privateProfile.user.id == post.author.id;

  @override
  BasicCircle get circle => post.circle;

  FullScreenImagePostPresentationModel copyWith({
    Post? post,
    PrivateProfile? privateProfile,
  }) {
    return FullScreenImagePostPresentationModel._(
      post: post ?? this.post,
      privateProfile: privateProfile ?? this.privateProfile,
    );
  }
}

/// Interface to expose fields used by the view (page).
abstract class FullScreenImagePostViewModel {
  ImagePostContent get imagePostContent;

  BasicCircle get circle;

  Post get post;

  bool get canDeletePost;

  bool get isAuthor;

  bool get canReportPost;
}

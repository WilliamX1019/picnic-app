import 'package:picnic_app/core/data/graphql/templates/gql_template.dart';

extension GqlTemplateComment on GqlTemplate {
  String get comment => '''
  id
  text
  author {
    id
    username
    profileImage
    isVerified
  }
  repliesCount
  reactions
  iReacted
  postId
  createdAt
  deletedAt
  context {
    reaction
  }
''';
}

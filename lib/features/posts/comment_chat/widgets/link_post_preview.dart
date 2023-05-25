import 'package:flutter/material.dart';
import 'package:picnic_app/core/domain/model/link_url.dart';
import 'package:picnic_app/features/posts/domain/model/link_metadata.dart';
import 'package:picnic_app/ui/widgets/picnic_link_post.dart';

class LinkPostPreview extends StatelessWidget {
  const LinkPostPreview({
    Key? key,
    required this.linkMetadata,
    required this.linkUrl,
    required this.onTapLink,
  }) : super(key: key);

  final LinkMetadata linkMetadata;
  final LinkUrl linkUrl;
  final Function(LinkUrl) onTapLink;

  static const _radius = 8.0;

  @override
  Widget build(BuildContext context) {
    final postHeight = MediaQuery.of(context).size.height / 4.9;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: PicnicLinkPost(
        radius: BorderRadius.circular(_radius),
        height: postHeight,
        onTap: onTapLink,
        withRoundedCorners: false,
        linkUrl: linkUrl,
        linkMetadata: linkMetadata,
      ),
    );
  }
}

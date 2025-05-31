import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:scribblr/components/text_styles.dart';

import '../models/article_model.dart';
import '../screens/article_detail.dart';
import '../utils/colors.dart';

class ArticleComponent extends StatefulWidget {
  final ArticleModel articleResponseData;
  final double? width;
  final double? height;

  ArticleComponent(
      {required this.articleResponseData, this.width, this.height});

  @override
  State<ArticleComponent> createState() => _ArticleComponentState();
}

class _ArticleComponentState extends State<ArticleComponent> {
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.articleResponseData.imageAsset.validate();

    bool isNetworkImage = imageUrl.isNotEmpty &&
        (imageUrl.startsWith("http") || imageUrl.startsWith("https"));

    return GestureDetector(
      onTap: () {
        ArticleDetail(articleData: widget.articleResponseData).launch(context);
      },
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 1),
        width: widget.width ?? context.width() / 2 - 70,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: isNetworkImage
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          height: widget.height ?? context.width() / 2 - 70,
                          width: widget.width ?? context.width() / 2 - 70,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              "assets/images/placeholder.jpg",
                              height: widget.height ?? context.width() / 2 - 70,
                              width: widget.width ?? context.width() / 2 - 70,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          imageUrl.isNotEmpty
                              ? imageUrl
                              : "assets/images/placeholder.jpg",
                          fit: BoxFit.cover,
                          height: widget.height ?? context.width() / 2 - 70,
                          width: widget.width ?? context.width() / 2 - 70,
                        ),
                ),
              ],
            ),
            5.height,
            Text(
              widget.articleResponseData.title.validate(),
              style: articletextStyle(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            5.height,
            Row(
              children: [
                Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: AssetImage(
                            widget.articleResponseData.authorImage.validate()),
                        fit: BoxFit.cover),
                  ),
                ),
                3.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.articleResponseData.authorName.validate(),
                      style: usertextStyle(),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(widget.articleResponseData.time.validate(),
                        style: timetextStyle()),
                  ],
                ).expand(),
              ],
            ).paddingSymmetric(horizontal: 2),
          ],
        ),
      ).paddingSymmetric(horizontal: 6),
    );
  }
}

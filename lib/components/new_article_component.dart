import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:scribblr/components/text_styles.dart';

import '../models/article_model.dart';
import '../screens/article_detail.dart';

class NewArticleComponent extends StatefulWidget {
  final ArticleModel newArticleResponseData;

  const NewArticleComponent({required this.newArticleResponseData});

  @override
  State<NewArticleComponent> createState() => _NewArticleComponentState();
}

class _NewArticleComponentState extends State<NewArticleComponent> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ArticleDetail(articleData: widget.newArticleResponseData)
            .launch(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image at the top
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.asset(
                widget.newArticleResponseData.imageAsset.validate(),
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200, // You can adjust the height as needed
              ),
            ),
            12.height, // Space between image and content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Article Title
                  Text(
                    widget.newArticleResponseData.title.validate(),
                    style: notifiTitleTextStyle(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  8.height, // Space between title and author
                  // Author and time row
                  Row(
                    children: [
                      // Author Image
                      Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(
                              widget.newArticleResponseData.authorImage
                                  .validate(),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      8.width, // Space between image and name
                      // Author Name
                      Text(
                        widget.newArticleResponseData.authorName.validate(),
                        style: usertextStyle(),
                        overflow: TextOverflow.ellipsis,
                      ),
                      16.width, // Space between author and time
                      // Article Time
                      Text(
                        widget.newArticleResponseData.time.validate(),
                        style: secondarytextStyle(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ).paddingSymmetric(horizontal: 12, vertical: 8),
    );
  }
}

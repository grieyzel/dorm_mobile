import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:scribblr/components/text_styles.dart';
import 'package:scribblr/screens/articles.dart';

import '../../screens/events/event_list.dart';
import '../main.dart';
import '../models/article_model.dart';
import '../utils/colors.dart';
import 'article_component.dart';

class ArticleWidget extends StatefulWidget {
  final ArticleResponse articleResponseData;

  ArticleWidget({required this.articleResponseData});

  @override
  State<ArticleWidget> createState() => _ArticleWidgetState();
}

class _ArticleWidgetState extends State<ArticleWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.articleResponseData.title.validate(),
              style: primarytextStyle(
                color: appStore.isDarkMode
                    ? scaffoldLightColor
                    : scaffoldDarkColor,
              ),
            ).expand(),
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => EventListScreen()));
              },
              icon: Icon(Icons.arrow_forward_outlined,
                  color: scribblrPrimaryColor),
            ),
          ],
        ).paddingOnly(left: 5, right: 5, top: 5),
        HorizontalList(
          spacing: 0,
          itemCount: widget.articleResponseData.articleList.validate().length,
          itemBuilder: (context, index) {
            return ArticleComponent(
                articleResponseData:
                    widget.articleResponseData.articleList.validate()[index]);
          },
        ),
      ],
    );
  }
}

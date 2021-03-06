import 'package:flutter/material.dart';
import 'package:pixivic/data/common.dart';

import 'package:provider/provider.dart';
import 'package:flutter_screenutil/screenutil.dart';

import 'package:pixivic/provider/favorite_animation_model.dart';
import 'package:pixivic/provider/pic_page_model.dart';
import 'package:pixivic/function/dio_client.dart';

class MarkHeart extends StatelessWidget {
  MarkHeart(
      {@required this.picItem,
      @required this.index,
      @required this.getPageProvider});

  final Map picItem;
  final int index;

  final PicPageModel getPageProvider;

  @override
  Widget build(BuildContext context) {
    // print('Build MarkHeart $index');
    bool isLikedLocalState = getPageProvider != null
        ? getPageProvider.picList[index]['isLiked']
        : picItem['isLiked'];
    Color color = isLikedLocalState ? Colors.redAccent : Colors.grey[300];
    String picId = picItem['id'].toString();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FavoriteAnimationModel>(
          create: (_) => FavoriteAnimationModel(),
        )
      ],
      child: Consumer<FavoriteAnimationModel>(
        builder: (context, FavoriteAnimationModel favProvider, child) {
          return IconButton(
            color: color,
            padding: EdgeInsets.all(0),
            iconSize: ScreenUtil().setHeight(favProvider.iconSize),
            icon: Icon(Icons.favorite),
            onPressed: () async {
              //点击动画
              favProvider.clickFunc();
              String url = '/users/bookmarked';
              var response;
              Map<String, String> body = {
                'userId': prefs.getInt('id').toString(),
                'illustId': picId.toString(),
                'username': prefs.getString('name')
              };
              if (isLikedLocalState) {
                response = await dioPixivic.delete(
                  url,
                  data: body,
                );
              } else {
                response = await dioPixivic.post(
                  url,
                  data: body,
                );
              }
              if (response.runtimeType != bool) {
                Future.delayed(Duration(milliseconds: 400), () {
                  getPageProvider != null
                      ? getPageProvider.flipLikeState(index)
                      : picItem['isLiked'] = !picItem['isLiked'];
                  isLikedLocalState = !isLikedLocalState;
                  color =
                      isLikedLocalState ? Colors.redAccent : Colors.grey[300];
                });
              }
            },
          );
        },
      ),
    );
  }
}

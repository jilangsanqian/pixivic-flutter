import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:pixivic/data/common.dart';
import 'package:pixivic/data/texts.dart';

class CommentListModel with ChangeNotifier {
  CommentListModel(
      int illustId, int replyToId, String replyToName, int replyParentId) {
    scrollController = ScrollController()..addListener(_altLoading);
    textEditingController = TextEditingController();
    replyFocus = FocusNode()..addListener(replyFocusListener);

    this.hintText = texts.addCommentHint;
    this.replyToId = replyToId;
    this.replyToName = replyToName;
    this.replyParentId = replyParentId;
    this.illustId = illustId;

    //首次进入页面进行数据刷新
    loadComments(this.illustId).then((value) {
      commentList = value;
      notifyListeners();
    });
  }

  int illustId;
  List commentList;
  List jsonList;
  ScrollController scrollController;
  bool loadMoreAble = true;
  int currentPage = 1;
  String hintText;
  TextEditingController textEditingController;
  FocusNode replyFocus;
  int replyToId;
  String replyToName;
  int replyParentId;
  TextZhCommentCell texts = TextZhCommentCell();

//TODO 使用select缩小hintText的刷新范围
  replyFocusListener() {
    if (replyFocus.hasFocus && replyToName != '') {
      print('on focus');

      hintText = '@$replyToName:';
      notifyListeners();
    } else if (!replyFocus.hasFocus) {
      print('focus released');

      replyToId = 0;
      replyToName = '';
      replyParentId = 0;
      hintText = texts.addCommentHint;
      // print(textEditingController.text);
      notifyListeners();
    }
    print('replyParentId now is $replyParentId');
  }

  reply() async {
    if (prefs.getString('auth') == '') {
      BotToast.showSimpleNotification(title: texts.pleaseLogin);
      return false;
    }

    if (textEditingController.text == '') {
      BotToast.showSimpleNotification(title: texts.commentCannotBeBlank);
      return false;
    }

    String url = 'https://api.pixivic.com/illusts/${illustId}/comments';
    CancelFunc cancelLoading;
    var dio = Dio();
    Map<String, dynamic> payload = {
      'content': textEditingController.text,
      'parentId': replyParentId.toString(),
      'replyFromName': prefs.getString('name'),
      'replyTo': replyToId.toString(),
      'replyToName': replyToName
    };
    Map<String, dynamic> headers = {'authorization': prefs.getString('auth')};
    Response response = await dio.post(
      url,
      data: payload,
      options: Options(headers: headers),
      onReceiveProgress: (count, total) {
        cancelLoading = BotToast.showLoading();
      },
    );
    cancelLoading();
    BotToast.showSimpleNotification(title: response.data['message']);

    if (response.statusCode == 200) {
      textEditingController.text = '';
      replyToId = 0;
      replyToName = '';
      replyParentId = 0;
//TODO 考虑在回复后 请求码为200的情况下直接在commentList.Add(payload),避免再请请求数据
      //      commentList.add(payload);
      loadComments(illustId).then((value) {
        commentList = value;
        notifyListeners();
      });
      return true;
    } else {
      return false;
    }
  }

  //自动加载数据
  _altLoading() {
    if ((scrollController.position.extentAfter < 500) && loadMoreAble) {
      print(" Load Comment");
      loadMoreAble = false;
      this.currentPage++;
      print('current page is $currentPage');
      try {
        loadComments(illustId, page: this.currentPage).then((value) {
          print("自动加载");
          if (value.length != 0) {
            commentList = commentList + value;
            notifyListeners();
            loadMoreAble = true;
          }
        });
      } catch (err) {
        print('=========getJsonList==========');
        print(err);
        print('==============================');
        if (err.toString().contains('SocketException'))
          BotToast.showSimpleNotification(title: '网络异常，请检查网络(´·_·`)');
        loadMoreAble = true;
      }
    }
  }

//请求数据
  loadComments(int illustId, {int page = 1}) async {
    String url =
        'https://api.pixivic.com/illusts/$illustId/comments?page=$page&pageSize=10';
    var dio = Dio();
    Response response = await dio.get(url);
    if (response.statusCode == 200 && response.data['data'] != null) {
      // print(response.data);
      jsonList = response.data['data'];
      return jsonList;
    } else if (response.statusCode == 200 && response.data['data'] == null) {
      print('comments: null but 200');
      return jsonList = [];
    } else {
      BotToast.showSimpleNotification(title: response.data['message']);
    }
  }

  @override
  void dispose() {
    commentList = null;
    textEditingController.dispose();
    replyFocus.dispose();
    super.dispose();
  }
}
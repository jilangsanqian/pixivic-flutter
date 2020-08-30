/* 
fxt0706 2020-08-20
description: 文件封装了与画集有关的相关功能
*/
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../data/common.dart';
import '../data/texts.dart';

// 获取当前登录用户的画集列表
getAlbumList() async {
  List albumList;
  String url =
      'https://api.pixivic.com/users/${prefs.getInt('id')}/collections';
  Map<String, String> headers = {'authorization': prefs.getString('auth')};
  try {
    Response response =
        await Dio().get(url, options: Options(headers: headers));
    // print(response.data['data']);
    albumList = response.data['data'];
    // print('The user album list:\n$albumList');
    return albumList;
  } on DioError catch (e) {
    if (e.response != null) {
      BotToast.showSimpleNotification(title: e.response.data['message']);
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request);
      return null;
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      BotToast.showSimpleNotification(title: e.message);
      print(e.request);
      print(e.message);
      return null;
    }
  }
}

// 将选中画作添加到指定的画集中
addIllustToAlbumn(int illustId, int albumnId) async {
  String url = 'https://api.pixivic.com/collections/$albumnId/illustrations';
  Map<String, String> headers = {'authorization': prefs.getString('auth')};
  Map<String, String> data = {'illust_id': illustId.toString()};
  try {
    Response response = await Dio().post(url,
        options: Options(
          headers: headers,
        ),
        data: data);
    BotToast.showSimpleNotification(title: response.data['message']);
  } on DioError catch (e) {
    if (e.response != null) {
      BotToast.showSimpleNotification(title: e.response.data['message']);
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request);
      return null;
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      BotToast.showSimpleNotification(title: e.message);
      print(e.request);
      print(e.message);
      return null;
    }
  }
}

showAddNewAlbumnDialog(BuildContext context) async {
  TextEditingController title = TextEditingController();
  TextEditingController caption = TextEditingController();
  TextZhAlbumn texts = TextZhAlbumn();

  await showDialog(
      context: context,
      builder: (BuildContext context) {
        Provider.of<NewAlbumnParameterModel>(context, listen: false)
            .cleanTags();
        return Consumer<NewAlbumnParameterModel>(
          builder: (context, NewAlbumnParameterModel newAlbumnParameterModel,
                  child) =>
              AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: EdgeInsets.all(0),
            content: Container(
              alignment: Alignment.topCenter,
              width: ScreenUtil().setWidth(250),
              height: ScreenUtil().setHeight(280),
              child: Stack(
                children: [
                  Positioned(
                    top: ScreenUtil().setHeight(0),
                    child: Column(
                      children: [
                        Container(
                            width: ScreenUtil().setWidth(250),
                            height: ScreenUtil().setHeight(30),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0)),
                              color: Colors.orange[300],
                            ),
                            alignment: Alignment.center,
                            // padding: EdgeInsets.only(
                            //     bottom: ScreenUtil().setHeight(8)),
                            child: Text(
                              texts.newAlbumnTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            )),
                        Container(
                          width: ScreenUtil().setWidth(250),
                          height: ScreenUtil().setHeight(30),
                          child: TextField(
                            cursorColor: Colors.orange,
                            controller: title,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.orangeAccent)),
                              isDense: true,
                              focusColor: Colors.orange,
                              hintText: texts.inputAlbumnTitle,
                              hintStyle: TextStyle(
                                  fontSize: 16, color: Colors.grey[400]),
                            ),
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(250),
                          child: TextField(
                            cursorColor: Colors.orange,
                            controller: caption,
                            maxLines: 3,
                            minLines: 1,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.orangeAccent)),
                              isDense: true,
                              hintText: texts.inputAlbumnCaption,
                              hintStyle: TextStyle(
                                  fontSize: 16, color: Colors.grey[400]),
                            ),
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(200),
                          height: ScreenUtil().setHeight(30),
                          child: SwitchListTile(
                            value: newAlbumnParameterModel.isPublic,
                            dense: true,
                            onChanged: (value) {
                              newAlbumnParameterModel.public(value);
                            },
                            activeColor: Colors.orangeAccent,
                            title: Text(
                              texts.isPulic,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(200),
                          height: ScreenUtil().setHeight(30),
                          child: SwitchListTile(
                            value: newAlbumnParameterModel.isSexy,
                            dense: true,
                            onChanged: (value) {
                              newAlbumnParameterModel.sexy(value);
                            },
                            activeColor: Colors.orangeAccent,
                            title: Text(texts.isSexy,
                                style: TextStyle(fontSize: 14)),
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(200),
                          height: ScreenUtil().setHeight(30),
                          child: SwitchListTile(
                            value: newAlbumnParameterModel.allowComment,
                            dense: true,
                            onChanged: (value) {
                              newAlbumnParameterModel.comment(value);
                            },
                            activeColor: Colors.orangeAccent,
                            title: Text(texts.allowComment,
                                style: TextStyle(fontSize: 14)),
                          ),
                        ),
                        FlatButton(
                          shape: StadiumBorder(),
                          onPressed: () {
                            showTagSelector(context);
                          },
                          child: Text(texts.addTag),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: ScreenUtil().setHeight(0),
                    child: Container(
                      width: ScreenUtil().setWidth(250),
                      height: ScreenUtil().setHeight(30),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.orange[300],
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: FlatButton(
                        child: Text(
                          texts.submit,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        color: Colors.orange[300],
                        shape: StadiumBorder(),
                        onPressed: () {
                          Map<String, dynamic> payload = {
                            'title': title.text,
                            'caption': caption.text,
                            'isPublic':
                                newAlbumnParameterModel.isPublic ? 1 : 0,
                            'pornWarning':
                                newAlbumnParameterModel.isSexy ? 1 : 0,
                            'forbidComment':
                                newAlbumnParameterModel.allowComment ? 1 : 0,
                            'tagList': newAlbumnParameterModel.tags
                          };
                          postNewAlbumn(payload);
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }).then((value) {});
}

showTagSelector(context) async {
  TextZhAlbumn texts = TextZhAlbumn();
  await showDialog(
      context: context,
      builder: (context) {
        TextEditingController tagInput = TextEditingController();
        return Consumer<NewAlbumnParameterModel>(
            builder: (context, NewAlbumnParameterModel newAlbumnParameterModel,
                    child) =>
                AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  contentPadding: EdgeInsets.all(0),
                  content: Container(
                      width: ScreenUtil().setWidth(250),
                      height: ScreenUtil().setWidth(400),
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          Container(
                            width: ScreenUtil().setWidth(250),
                            height: ScreenUtil().setHeight(30),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0)),
                              color: Colors.orange[300],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              texts.addTag,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ),
                          Container(
                            width: ScreenUtil().setWidth(250),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: newAlbumnParameterModel.tags
                                  .map(
                                      (item) => singleTag(context, item['tagName'], false))
                                  .toList(),
                            ),
                          ),
                          Container(
                            width: ScreenUtil().setWidth(200),
                            child: TextField(
                                controller: tagInput,
                                decoration: InputDecoration(
                                  hintText: '输入你想要添加的标签',
                                  isDense: true,
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey)),
                                ),
                                onEditingComplete: () {
                                  newAlbumnParameterModel
                                      .getTagAdvice(tagInput.text);
                                }),
                          ),
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: newAlbumnParameterModel.tagsAdvice
                                .map((item) =>
                                    singleTag(context, item['tagName'], true))
                                .toList(),
                          )
                        ],
                      )),
                ));
      }).then((value) {
    Provider.of<NewAlbumnParameterModel>(context, listen: false)
        .clearTagAdvice();
  });
}

postNewAlbumn(Map<String, dynamic> payload) async {
  
  String url = 'https://api.pixivic.com/collections';
  Map<String, String> headers = {'authorization': prefs.getString('auth')};

  try {
    if(payload['tagList'] != null) {
      Response response =
    await Dio().post(url,data: payload,options: Options(headers: headers));
    BotToast.showSimpleNotification(title: response.data['message']);
    }
      
    } on DioError catch (e) {
      if (e.response != null) {
        BotToast.showSimpleNotification(title: e.response.data['message']);
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        BotToast.showSimpleNotification(title: e.message);
        print(e.request);
        print(e.message);
      }
    }
}

Widget singleTag(context, String label, bool advice) {
  return Container(
    padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(1.5),
        right: ScreenUtil().setWidth(1.5),
        top: ScreenUtil().setWidth(4)),
    child: ButtonTheme(
      materialTapTargetSize:
          MaterialTapTargetSize.shrinkWrap, //set _InputPadding to zero
      height: ScreenUtil().setHeight(20),
      minWidth: ScreenUtil().setWidth(1),
      buttonColor: Colors.grey[100],
      splashColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13.0)),
      child: OutlineButton(
        padding: EdgeInsets.only(
            left: ScreenUtil().setWidth(5),
            right: ScreenUtil().setWidth(5),
            top: ScreenUtil().setWidth(3),
            bottom: ScreenUtil().setWidth(3)),
        onPressed: () {
          if (advice)
            Provider.of<NewAlbumnParameterModel>(context, listen: false)
                .addTagToTagsList(label);
          else
            Provider.of<NewAlbumnParameterModel>(context, listen: false)
                .removeTagFromTagsList(label);
        },
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey),
            ),
            !advice
                ? Icon(
                    Icons.cancel,
                    color: Colors.grey,
                    size: ScreenUtil().setWidth(13),
                  )
                : SizedBox(width: 0)
          ],
        ),
      ),
    ),
  );
}

class NewAlbumnParameterModel with ChangeNotifier {
  bool _isPublic = true;
  bool _isSexy = false;
  bool _allowComment = true;
  List _tags = [];
  List _tagsAdvice = [];

  bool get isPublic => _isPublic;
  bool get isSexy => _isSexy;
  bool get allowComment => _allowComment;
  List get tags => _tags;
  List get tagsAdvice => _tagsAdvice;

  public(bool result) {
    _isPublic = result;
    notifyListeners();
  }

  sexy(bool result) {
    _isSexy = result;
    notifyListeners();
  }

  comment(bool result) {
    _allowComment = result;
    notifyListeners();
  }

  cleanTags() {
    _tags = [];
    notifyListeners();
  }

  clearTagAdvice() {
    _tagsAdvice = [];
    notifyListeners();
  }

  getTagAdvice(String keywords) async {
    _tagsAdvice = [
      {'tagName': keywords}
    ];
    notifyListeners();
    String url = 'https://api.pixivic.com/collections/tags?keyword=$keywords';
    Map<String, String> headers = {'authorization': prefs.getString('auth')};

    try {
      Response response =
          await Dio().get(url, options: Options(headers: headers));
      if (response.data['data'] != null)
        _tagsAdvice = _tagsAdvice + response.data['data'];
      print(_tagsAdvice);
      notifyListeners();
      // _tagsAdvice = [];
    } on DioError catch (e) {
      if (e.response != null) {
        BotToast.showSimpleNotification(title: e.response.data['message']);
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        BotToast.showSimpleNotification(title: e.message);
        print(e.request);
        print(e.message);
      }
    }
  }

  addTagToTagsList(String tag) {
    if (!_tags.contains({'tagName': tag})) _tags.add({'tagName': tag});
    notifyListeners();
  }

  removeTagFromTagsList(String tag) {
    _tags.removeWhere((element) => element['tagName'] == tag);
    notifyListeners();
  }
}

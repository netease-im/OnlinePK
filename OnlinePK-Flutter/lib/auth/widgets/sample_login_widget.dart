// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:livekit_sample/base/lifecycle_base_state.dart';
import 'package:livekit_sample/nav/nav_utils.dart';
import 'package:livekit_sample/nav/router_name.dart';
import 'package:livekit_sample/service/app_service.dart';
import 'package:livekit_sample/service/auth/auth_manager.dart';
import 'package:livekit_sample/service/auth/login_info.dart';
import 'package:livekit_sample/service/client/http_code.dart';
import 'package:livekit_sample/utils/live_log.dart';
import 'package:livekit_sample/utils/loading.dart';
import 'package:livekit_sample/utils/toast_utils.dart';
import 'package:livekit_sample/values/asset_name.dart';
import 'package:livekit_sample/values/colors.dart';
import 'package:livekit_sample/values/strings.dart';

class SampleLoginWidget extends StatefulWidget {
  final String mobile;

  const SampleLoginWidget(this.mobile, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SampleLoginState();
  }
}

class SampleLoginState extends LifecycleBaseState<SampleLoginWidget> {
  static const _tag = 'SampleLoginState';
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: const Color.fromRGBO(239, 241, 244, 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 200,
                    child: Image.asset(AssetName.launcher),
                  )),
              const Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 20,
                  child: Text(Strings.sampleLoginDesc),
                ),
              ),
              Container(
                height: 50,
                margin: const EdgeInsets.only(left: 30, top: 250, right: 30),
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.disabled)) {
                          return AppColors.blue_50_337eff;
                        }
                        return AppColors.blue_337eff;
                      }),
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 13)),
                      shape:
                          MaterialStateProperty.all(
                              const RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: AppColors.blue_337eff, width: 0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25))))),
                  onPressed: createAccountThenLogin,
                  child: const Text(
                    Strings.startExploring,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ));
  }

  void createAccountThenLogin() async {
    // 创建账号并登录
    LiveLog.i(tag, "createAccountThenLogin");
    LoadingUtil.showLoading();
    AppService().loginByNemo().then((result) {
      LiveLog.i(tag, "createAccountThenLogin result:$result");
      if (result.code == HttpCode.success && result.data != null) {
        LoginInfo loginInfo = LoginInfo(
          accountId: result.data!.userUuid ?? "",
          accountToken: result.data!.userToken ?? "",
          nickname: result.data!.userName,
          avatar: result.data!.icon,
        );

        AuthManager().loginLiveKitWithToken(loginInfo).then((result) {
          LiveLog.d(_tag, 'loginLiveKitWithToken result = ${result.code}');
          LoadingUtil.hideLoading();
          if (result.code == 0) {
            ToastUtils.showToast(context, Strings.loginSuccess);
            NavUtils.popAndPushNamed(context, RouterName.homePage);
          } else {
            ToastUtils.showToast(context,
                "${Strings.loginFailed} code = ${result.code}, msg = ${result.msg}");
          }
        });
      } else {
        ToastUtils.showToast(context,
            "create nemo account failed,code:${result.code},msg:${result.msg}");
      }
    });
  }
}

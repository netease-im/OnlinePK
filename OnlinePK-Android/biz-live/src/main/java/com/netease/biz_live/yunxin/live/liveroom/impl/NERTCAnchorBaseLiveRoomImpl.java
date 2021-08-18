/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.liveroom.impl;

import android.content.Context;
import android.graphics.Color;
import android.view.View;

import com.blankj.utilcode.util.ToastUtils;
import com.netease.biz_live.BuildConfig;
import com.netease.biz_live.yunxin.live.constant.LiveStreamParams;
import com.netease.biz_live.yunxin.live.liveroom.LiveRoomCallback;
import com.netease.biz_live.yunxin.live.liveroom.NERTCAnchorBaseLiveRoomDelegate;
import com.netease.biz_live.yunxin.live.liveroom.NERTCAnchorLiveRoom;
import com.netease.biz_live.yunxin.live.liveroom.model.LiveStreamTaskRecorder;
import com.netease.biz_live.yunxin.live.model.LiveInfo;
import com.netease.lava.nertc.impl.RtcCode;
import com.netease.lava.nertc.sdk.NERtcCallback;
import com.netease.lava.nertc.sdk.NERtcConstants;
import com.netease.lava.nertc.sdk.NERtcEx;
import com.netease.lava.nertc.sdk.NERtcOption;
import com.netease.lava.nertc.sdk.NERtcParameters;
import com.netease.lava.nertc.sdk.audio.NERtcCreateAudioEffectOption;
import com.netease.lava.nertc.sdk.audio.NERtcCreateAudioMixingOption;
import com.netease.lava.nertc.sdk.live.NERtcLiveStreamLayout;
import com.netease.lava.nertc.sdk.live.NERtcLiveStreamTaskInfo;
import com.netease.lava.nertc.sdk.live.NERtcLiveStreamUserTranscoding;
import com.netease.lava.nertc.sdk.video.NERtcVideoCallback;
import com.netease.lava.nertc.sdk.video.NERtcVideoConfig;
import com.netease.lava.nertc.sdk.video.NERtcVideoView;
import com.netease.yunxin.kit.alog.ALog;

import java.util.ArrayList;


public  class NERTCAnchorBaseLiveRoomImpl extends NERTCAnchorLiveRoom {
    private static final String LOG_TAG = "NERTCAnchorBaseLiveRoomImpl";

    protected static NERTCAnchorBaseLiveRoomImpl instance;

    protected NERTCAnchorBaseLiveRoomDelegate roomDelegate;


    //****************数据存储于标记start*******************


    LiveInfo singleLiveInfo;//单主播房间信息

    NERtcEx neRtcEx;

    protected String roomCid;//直播时音视频房间唯一标识

    //****************数据存储于标记end*******************


    /**
     * 音频设备{@link NERtcConstants.AudioDevice }
     */
    protected int audioDevice;


    @Override
    public void setDelegate(NERTCAnchorBaseLiveRoomDelegate delegate) {
        roomDelegate = delegate;
    }

    /**
     * 无服务，base的实例不可调用
     * @param tClass
     * @param <T>
     * @return
     */
    @Override
    public <T> T getService(Class<T> tClass) {
        return null;
    }

    protected NERTCAnchorBaseLiveRoomImpl() {

    }

    public static synchronized NERTCAnchorBaseLiveRoomImpl sharedInstance() {
        if (instance == null) {
            instance = new NERTCAnchorInteractionLiveRoomImpl();
        }
        return instance;
    }

    public static synchronized void destroySharedInstance() {
        if (instance != null) {
            instance.destroy();
            instance = null;
        }
    }

    private void destroy() {
        if(neRtcEx != null){
            neRtcEx.release();
        }

    }


    @Override
    public void init(Context context, String appKey,
                     NERtcOption option) {
        if (neRtcEx != null) {
            neRtcEx.release();
        }

        neRtcEx = NERtcEx.getInstance();
        NERtcVideoConfig videoConfig = new NERtcVideoConfig();
        videoConfig.frontCamera = true;//默认是前置摄像头
        neRtcEx.setLocalVideoConfig(videoConfig);
        if(option == null){
            option = new NERtcOption();
        }
        if(BuildConfig.DEBUG){
            option.logLevel = NERtcConstants.LogLevel.INFO;
        }else {
            option.logLevel = NERtcConstants.LogLevel.WARNING;
        }

        try {
            neRtcEx.init(context, appKey, initNERtcCallback(), option);
        } catch (Exception e) {
            ALog.w(LOG_TAG, "nertc init failed exception", e);
            ToastUtils.showLong("SDK 初始化失败");
            return;
        }
        initDetail();
    }

    /**
     * 设置rtc 回调，子类实现
     * @return
     */
    protected NERtcCallback initNERtcCallback(){
        return null;
    }

    /**
     * 初始化各种回调监听，子类实现
     */
    protected void initDetail(){

    }


    @Override
    public void createRoom(LiveInfo liveInfo,
                           int profile, NERtcVideoConfig.NERtcVideoFrameRate frameRate,
                           int mAudioScenario, boolean isFrontCam,
                           LiveRoomCallback callback) {
        ALog.i(LOG_TAG, "createRoom: liveCid = " + liveInfo.liveCid);
        singleLiveInfo = liveInfo;
        NERtcVideoConfig videoConfig = new NERtcVideoConfig();
        videoConfig.videoProfile = profile;
        videoConfig.frameRate = frameRate;
        videoConfig.frontCamera = isFrontCam;
        neRtcEx.setLocalVideoConfig(videoConfig);
        if (mAudioScenario == NERtcConstants.AudioScenario.MUSIC) {
            neRtcEx.setAudioProfile(NERtcConstants.AudioProfile.HIGH_QUALITY_STEREO, mAudioScenario);
        } else {
            neRtcEx.setAudioProfile(NERtcConstants.AudioProfile.HIGH_QUALITY, mAudioScenario);
        }
        neRtcEx.setChannelProfile(NERtcConstants.RTCChannelProfile.LIVE_BROADCASTING);
        neRtcEx.setClientRole(NERtcConstants.UserRole.CLIENT_ROLE_BROADCASTER);
        NERtcParameters parameters = new NERtcParameters();
        parameters.set(NERtcParameters.KEY_PUBLISH_SELF_STREAM, true);
        neRtcEx.setParameters(parameters);
        startSignalLive(liveInfo.liveConfig.pushUrl, callback);
    }


    /**
     * 开启单主播
     *
     * @param cdnURL
     * @param callback
     */
    private void startSignalLive(String cdnURL, LiveRoomCallback callback) {
        int rtcResult = -1;
        ALog.i(LOG_TAG, "startSignalLive");
        rtcResult = joinChannel(singleLiveInfo.avRoomCheckSum, singleLiveInfo.avRoomCName, singleLiveInfo.avRoomUid);
        if (rtcResult == 0) {
            callback.onSuccess(null);
        } else {
            callback.onError(rtcResult, "join rtcChannel failed!");
        }
    }

    /**
     * 添加推流任务
     *
     * @param liveRecoder
     * @return
     */
    protected int addLiveStreamTask(LiveStreamTaskRecorder liveRecoder) {
        // 初始化推流任务
        NERtcLiveStreamTaskInfo liveTask = new NERtcLiveStreamTaskInfo();
        //taskID 可选字母、数字，下划线，不超过64位
        liveTask.taskId = liveRecoder.taskId;
        // 一个推流地址对应一个推流任务
        liveTask.url = liveRecoder.pushUlr;
        // 不进行直播录制，请注意与音视频服务端录制区分。
        liveTask.serverRecordEnabled = false;
        // 设置推音视频流还是纯音频流
        liveTask.liveMode = NERtcLiveStreamTaskInfo.NERtcLiveStreamMode.kNERtcLsModeVideo;

        //设置整体布局
        NERtcLiveStreamLayout layout = new NERtcLiveStreamLayout();
        layout.userTranscodingList = new ArrayList<>();
        if (liveRecoder.isPk()) {
            layout.width = LiveStreamParams.SIGNAL_HOST_LIVE_WIDTH;//整体布局宽度
            layout.height = LiveStreamParams.PK_LIVE_HEIGHT;//整体布局高度
        } else {
            layout.width = LiveStreamParams.SIGNAL_HOST_LIVE_WIDTH;//整体布局宽度
            layout.height = LiveStreamParams.SIGNAL_HOST_LIVE_HEIGHT;//整体布局高度
        }
        layout.backgroundColor = Color.parseColor("#000000"); // 整体背景色
        liveTask.layout = layout;

        // 设置直播成员布局
        if (liveRecoder.anchorUid != 0) {
            NERtcLiveStreamUserTranscoding selfUser = new NERtcLiveStreamUserTranscoding();
            selfUser.uid = liveRecoder.anchorUid; // 用户id
            selfUser.audioPush = true; // 推流是否发布user1 的音频
            selfUser.videoPush = true; // 推流是否发布user1的视频

            // 如果发布视频，需要设置一下视频布局参数
            // user1 视频的缩放模式， 详情参考NERtcLiveStreamUserTranscoding 的API 文档
            selfUser.adaption = NERtcLiveStreamUserTranscoding.NERtcLiveStreamVideoScaleMode.kNERtcLsModeVideoScaleCropFill;
            //独自一个人填充满
            if (liveRecoder.isPk()) {
                selfUser.width = LiveStreamParams.PK_LIVE_WIDTH; // user1 的视频布局宽度
                selfUser.height = LiveStreamParams.PK_LIVE_HEIGHT; //user1 的视频布局高度
            } else {
                selfUser.width = LiveStreamParams.SIGNAL_HOST_LIVE_WIDTH; // user1 的视频布局宽度
                selfUser.height = LiveStreamParams.SIGNAL_HOST_LIVE_HEIGHT; //user1 的视频布局高度
            }

            layout.userTranscodingList.add(selfUser);
        }

        if (liveRecoder.isPk() && liveRecoder.pkAnchorUid != 0) {
            NERtcLiveStreamUserTranscoding pkUser = new NERtcLiveStreamUserTranscoding();
            pkUser.uid = liveRecoder.pkAnchorUid; // 用户id
            pkUser.audioPush = true; // 推流是否发布user1 的音频
            pkUser.videoPush = true; // 推流是否发布user1的视频

            // user1 视频的缩放模式， 详情参考NERtcLiveStreamUserTranscoding 的API 文档
            pkUser.adaption = NERtcLiveStreamUserTranscoding.NERtcLiveStreamVideoScaleMode.kNERtcLsModeVideoScaleCropFill;
            //独自一个人填充满
            pkUser.x = LiveStreamParams.PK_LIVE_WIDTH;
            pkUser.y = 0;
            pkUser.width = LiveStreamParams.PK_LIVE_WIDTH; // user1 的视频布局宽度
            pkUser.height = LiveStreamParams.PK_LIVE_HEIGHT; //user1 的视频布局高度

            layout.userTranscodingList.add(pkUser);
        }

        ALog.i(LOG_TAG, "addLiveStreamTask recoder = " + liveRecoder.toString());

        int ret = neRtcEx.addLiveStreamTask(liveTask, (s, code) -> {
            if (code == RtcCode.LiveCode.OK) {
                ALog.i(LOG_TAG, "addLiveStream success : taskId " + liveRecoder.taskId);
            } else {
                ALog.i(LOG_TAG, "addLiveStream failed : taskId " + liveRecoder.taskId + " , code : " + code);
            }
        });

        if (ret != 0) {
            ALog.i(LOG_TAG, "addLiveStream failed : taskId " + liveRecoder.taskId + " , ret : " + ret);
        }
        return ret;
    }


    /**
     * 加入rtc的房间
     *
     * @param token
     * @param channelName
     * @param channelUid
     * @return
     */
    protected int joinChannel(String token, String channelName, long channelUid) {
        ALog.i(LOG_TAG, "joinChannel channelName = " + channelName + " uid = " + channelUid);
        if (channelUid != 0) {
            return NERtcEx.getInstance().joinChannel(token, channelName, channelUid);
        }
        return -1;
    }


    @Override
    public void stopLive() {
        releaseObserve();
        if (neRtcEx != null) {
            neRtcEx.leaveChannel();
            neRtcEx.release();
            neRtcEx = null;
        }
    }

    /**
     * 释放各种监听，子类实现
     */
    protected void releaseObserve(){

    }

    @Override
    public void setupLocalView(NERtcVideoView videoRender) {
        if (neRtcEx == null) {
            return;
        }
        if (videoRender == null) {
            neRtcEx.setupLocalVideoCanvas(null);
            return;
        }
        neRtcEx.enableLocalAudio(true);
        neRtcEx.enableLocalVideo(true);
        videoRender.setScalingType(NERtcConstants.VideoScalingType.SCALE_ASPECT_BALANCED);
        int result = neRtcEx.setupLocalVideoCanvas(videoRender);
        ALog.i(LOG_TAG, "setupLocalView result = " + result);
    }

    @Override
    public void setupRemoteView(NERtcVideoView videoRender, long uid, boolean isTop) {
        if (neRtcEx == null) {
            return;
        }
        videoRender.setZOrderMediaOverlay(isTop);
        videoRender.setMirror(true);
        videoRender.setScalingType(NERtcConstants.VideoScalingType.SCALE_ASPECT_FIT);
        neRtcEx.setupRemoteVideoCanvas(videoRender, uid);
        videoRender.setVisibility(View.VISIBLE);
    }

    @Override
    public void setVideoCallback(NERtcVideoCallback callback, boolean needI420) {
        if (neRtcEx != null) {
            neRtcEx.setVideoCallback(callback, needI420);
        }
    }


    @Override
    public void joinRtcChannel(String checkSum, String channelName, long uid, String avRoomCid) {

    }


    @Override
    public void startVideoPreview() {
        neRtcEx.startVideoPreview();
    }

    @Override
    public void stopVideoPreview() {
        neRtcEx.stopVideoPreview();
    }

    @Override
    public void stopAudioMixing() {
        neRtcEx.stopAudioMixing();
    }

    @Override
    public void setAudioMixingSendVolume(int progress) {
        neRtcEx.setAudioMixingSendVolume(progress);
    }

    @Override
    public void setAudioMixingPlaybackVolume(int progress) {
        neRtcEx.setAudioMixingPlaybackVolume(progress);
    }

    @Override
    public void setEffectSendVolume(int id, int volume) {
        neRtcEx.setEffectSendVolume(id, volume);
    }

    @Override
    public void setEffectPlaybackVolume(int id, int volume) {
        neRtcEx.setEffectPlaybackVolume(id, volume);
    }

    @Override
    public boolean switchCamera() {
        return NERtcEx.getInstance().switchCamera() == 0;
    }

    @Override
    public boolean enableLocalVideo(boolean enable) {
        return NERtcEx.getInstance().enableLocalVideo(enable) == 0;
    }

    @Override
    public boolean muteLocalAudio(boolean isMute) {
        return NERtcEx.getInstance().muteLocalAudioStream(isMute) == 0;
    }

    @Override
    public boolean enableEarback(boolean enable, int volume) {
        if(audioDevice == NERtcConstants.AudioDevice.BLUETOOTH_HEADSET ||
            audioDevice == NERtcConstants.AudioDevice.WIRED_HEADSET){
            return NERtcEx.getInstance().enableEarback(enable, volume) == 0;
        } else {
            ToastUtils.showShort("打开耳返功能前，请先插入耳机！");
            return false;
        }

    }

    @Override
    public int stopEffect(int id) {
        return neRtcEx.stopEffect(id);
    }

    @Override
    public int playEffect(int id, NERtcCreateAudioEffectOption option) {
        return neRtcEx.playEffect(id, option);
    }

    @Override
    public int startAudioMixing(NERtcCreateAudioMixingOption option) {
        return neRtcEx.startAudioMixing(option);
    }

    @Override
    public void stopAllEffects() {
        neRtcEx.stopAllEffects();
    }

}

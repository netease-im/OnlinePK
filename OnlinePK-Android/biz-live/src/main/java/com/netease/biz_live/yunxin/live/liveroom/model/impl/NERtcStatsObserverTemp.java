package com.netease.biz_live.yunxin.live.liveroom.model.impl;

import com.netease.lava.nertc.sdk.stats.NERtcAudioRecvStats;
import com.netease.lava.nertc.sdk.stats.NERtcAudioSendStats;
import com.netease.lava.nertc.sdk.stats.NERtcNetworkQualityInfo;
import com.netease.lava.nertc.sdk.stats.NERtcStats;
import com.netease.lava.nertc.sdk.stats.NERtcStatsObserver;
import com.netease.lava.nertc.sdk.stats.NERtcVideoRecvStats;
import com.netease.lava.nertc.sdk.stats.NERtcVideoSendStats;

public class NERtcStatsObserverTemp implements NERtcStatsObserver {
    @Override
    public void onRtcStats(NERtcStats neRtcStats) {

    }

    @Override
    public void onLocalAudioStats(NERtcAudioSendStats neRtcAudioSendStats) {

    }

    @Override
    public void onRemoteAudioStats(NERtcAudioRecvStats[] neRtcAudioRecvStats) {

    }

    @Override
    public void onLocalVideoStats(NERtcVideoSendStats neRtcVideoSendStats) {

    }

    @Override
    public void onRemoteVideoStats(NERtcVideoRecvStats[] neRtcVideoRecvStats) {

    }

    @Override
    public void onNetworkQuality(NERtcNetworkQualityInfo[] neRtcNetworkQualityInfos) {

    }
}

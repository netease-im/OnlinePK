/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.ui.view

import android.annotation.SuppressLint
import android.content.Intent
import android.graphics.Color
import android.text.TextUtils
import android.view.*
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.blankj.utilcode.util.NetworkUtils
import com.blankj.utilcode.util.NetworkUtils.NetworkType
import com.blankj.utilcode.util.NetworkUtils.OnNetworkStatusChangedListener
import com.blankj.utilcode.util.ToastUtils
import com.netease.biz_live.R
import com.netease.biz_live.databinding.ViewIncludeRoomTopBinding
import com.netease.biz_live.databinding.ViewItemAudienceLiveRoomInfoBinding
import com.netease.biz_live.yunxin.live.audience.ui.dialog.GiftDialog
import com.netease.biz_live.yunxin.live.audience.ui.dialog.GiftDialog.GiftSendListener
import com.netease.biz_live.yunxin.live.audience.ui.view.AudienceErrorStateView.ClickButtonListener
import com.netease.biz_live.yunxin.live.audience.utils.*
import com.netease.biz_live.yunxin.live.audience.utils.InputUtils.InputParamHelper
import com.netease.biz_live.yunxin.live.chatroom.ChatRoomMsgCreator
import com.netease.biz_live.yunxin.live.constant.*
import com.netease.biz_live.yunxin.live.gift.GiftCache
import com.netease.biz_live.yunxin.live.gift.GiftRender
import com.netease.biz_live.yunxin.live.gift.ui.GifAnimationView
import com.netease.biz_live.yunxin.live.utils.SpUtils
import com.netease.biz_live.yunxin.live.utils.ViewUtils
import com.netease.yunxin.android.lib.picture.ImageLoader
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.lib_live_room_service.LiveRoomService
import com.netease.yunxin.lib_live_room_service.bean.LiveInfo
import com.netease.yunxin.lib_live_room_service.bean.LiveUser
import com.netease.yunxin.lib_live_room_service.chatroom.RewardMsg
import com.netease.yunxin.lib_live_room_service.chatroom.TextWithRoleAttachment
import com.netease.yunxin.lib_live_room_service.delegate.LiveRoomDelegate
import com.netease.yunxin.lib_live_room_service.param.ErrorInfo
import com.netease.yunxin.lib_network_kt.NetRequestCallback
import com.netease.yunxin.nertc.demo.basic.BaseActivity
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig
import com.netease.yunxin.nertc.demo.user.UserCenterService
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr

/**
 * Created by luc on 2020/11/19.
 *
 *
 * 观众端详细控制，继承自[FrameLayout] 添加了 [TextureView] 以及 [ExtraTransparentView] 作为页面主要元素
 *
 *
 * TextureView 用于页面视频播放；
 *
 *
 * ExtraTransparentView 用于页面信息展示，由于页面存在左右横滑状态所以自定义view 继承自 [RecyclerView] 用于页面左右横滑支持；
 * // * 实际页面布局见 R.layout.view_item_audience_live_room_info
 *
 *
 *
 * 此处 [.prepare] 方法依赖于recyclerView 子 view 的 [androidx.recyclerview.widget.RecyclerView.onChildAttachedToWindow],
 * [androidx.recyclerview.widget.RecyclerView.onChildDetachedFromWindow] 方法，
 * 方法，[.renderData] 依赖于 [androidx.recyclerview.widget.RecyclerView.Adapter.onBindViewHolder]
 * 此处使用 [androidx.recyclerview.widget.LinearLayoutManager] 从源码角度可以保障 renderData 调用时机早于 prepare 时机。
 *
 */
@SuppressLint("ViewConstructor")
abstract class BaseAudienceContentView(val activity: BaseActivity) : FrameLayout(activity) {

    /**
     * 用户服务
     */
    protected val userCenterService = ModuleServiceMgr.instance.getService(
        UserCenterService::class.java
    )

    protected val roomService by lazy { LiveRoomService.sharedInstance() }


    /**
     * 礼物渲染控制，完成礼物动画的播放，停止，顺序播放等
     */
    private val giftRender: GiftRender = GiftRender()

    /**
     * 直播播放View
     */
    protected var videoView: CDNStreamTextureView? = null

    /**
     * 信息浮层左右切换
     */
    private var horSwitchView: ExtraTransparentView? = null

    /**
     * 观众端信息浮层，viewbinding 官方文档:https://developer.android.com/topic/libraries/view-bindinghl=zh-cn#java
     */
    protected val infoBinding by lazy { ViewItemAudienceLiveRoomInfoBinding.inflate(
        LayoutInflater.from(
            context
        ), this, false
    ) }
    
    private val includeRoomTopBinding by lazy { ViewIncludeRoomTopBinding.bind(infoBinding.root) }

    /**
     * 直播间详细信息
     */
    protected var liveInfo: LiveInfo? = null

        /**
         * 主播错误状态展示（包含结束直播）
         */
    protected var errorStateView: AudienceErrorStateView? = null


    /**
     * 礼物弹窗
     */
    private var giftDialog: GiftDialog? = null

    /**
     * 依赖对象中回调，[.prepare] 状态设置为 true；
     * [.release] 状态设置为 false;
     */
    private var canRender = false

    private var joinRoomSuccess = false

    /**
     * 监听网络状态
     */
    private val onNetworkStatusChangedListener: OnNetworkStatusChangedListener =
        object : OnNetworkStatusChangedListener {
            override fun onDisconnected() {
                onNetworkDisconnected()
            }

            override fun onConnected(networkType: NetworkType) {
                onNetworkConnected(networkType)
            }
        }

    protected open fun onNetworkDisconnected() {
        ToastUtils.showLong(R.string.biz_live_network_error)
        ALog.d(LOG_TAG, "onDisconnected():" + System.currentTimeMillis())
        videoView?.visibility = GONE
        changeErrorState(true, AudienceErrorStateView.TYPE_ERROR)
        if (giftDialog?.isShowing == true) {
            giftDialog?.dismiss()
        }
    }

    protected open fun onNetworkConnected(networkType: NetworkType) {
        ALog.d(LOG_TAG, "onConnected():" + System.currentTimeMillis())
    }


    private val roomDelegate: LiveRoomDelegate =
        object : LiveRoomDelegate {

            override fun onError(errorInfo: ErrorInfo) {
                ALog.d(LOG_TAG, "onError $errorInfo")
                if (errorInfo.serious) {
                    if (!activity.isFinishing) {
                        activity.finish()
                    }
                } else {
                    if (!TextUtils.isEmpty(errorInfo.msg)) {
                        ToastUtils.showShort(errorInfo.msg)
                    }
                }
            }

            override fun onRoomDestroy() {
                if (!canRender) {
                    return
                }
                changeErrorState(true, AudienceErrorStateView.TYPE_FINISHED)
            }

            override fun onUserCountChange(userCount: Int) {
                includeRoomTopBinding.tvAudienceCount.text =
                    StringUtils.getAudienceCount(userCount)
            }

            override fun onRecvRoomTextMsg(nickname: String, attachment: TextWithRoleAttachment) {
                val content = attachment.msg
                val isAnchor = attachment.isAnchor
                ALog.d(LOG_TAG,"onRecvRoomTextMsg $content")
                onMsgArrived(ChatRoomMsgCreator.createText(isAnchor,nickname,content))
            }

            override fun onUserEntered(nickname: String) {
                if (!TextUtils.equals(nickname, liveInfo?.anchor?.nickname)) {
                    onMsgArrived(ChatRoomMsgCreator.createRoomEnter(nickname))
                }
            }

            override fun onUserLeft(nickname: String) {
                if (!TextUtils.equals(nickname, liveInfo?.anchor?.nickname)) {
                    onMsgArrived(ChatRoomMsgCreator.createRoomExit(nickname))
                }
            }

            /**
             * kicked out by login in other set
             */
            override fun onKickedOut() {
                if (!canRender) {
                    return
                }
                activity.finish()
                context.startActivity(Intent(context, DialogHelperActivity::class.java))
            }

            /**
             * anchor leave chatRoom
             */
            override fun onAnchorLeave() {
                if (!canRender) {
                    return
                }
                changeErrorState(true, AudienceErrorStateView.TYPE_FINISHED)
            }

            override fun onUserReward(rewardInfo: RewardMsg) {
                onMsgArrived(
                    ChatRoomMsgCreator.createGiftReward(
                        rewardInfo.rewarderNickname,
                        1, GiftCache.getGift(rewardInfo.giftId).staticIconResId
                    )
                )
                onUserRewardImpl(rewardInfo)
            }

            override fun onAudioEffectFinished(effectId: Int) {
                //need not impl
            }

            override fun onAudioMixingFinished() {
                //need not impl
            }

            /**
             * audience change
             * ten audience will return in live room
             */
            override fun onAudienceChange(infoList: MutableList<LiveUser>) {
                includeRoomTopBinding.rvAnchorPortraitList.updateAll(infoList)
            }

        }

    protected open fun showCdnView() {
        if (videoView == null) {
            videoView = CDNStreamTextureView(context)
            addView(videoView, 0, generateDefaultLayoutParams())
        }
        videoView?.visibility = VISIBLE
        // 初始化信息页面位置
        horSwitchView?.toSelectedPosition()
        // 播放器控制加载信息
        videoView?.prepare(liveInfo)
        // 聊天室信息更新到最新到最新一条
        infoBinding.crvMsgList.toLatestMsg()
    }

    open fun onUserRewardImpl(rewardInfo: RewardMsg) {
        if (TextUtils.equals(
                rewardInfo.anchorReward.accountId,
                liveInfo?.anchor?.accountId
            )
        ) {
            includeRoomTopBinding.tvAnchorCoinCount.text =
                StringUtils.getCoinCount(rewardInfo.anchorReward.rewardTotal)
            giftRender.addGift(GiftCache.getGift(rewardInfo.giftId).dynamicIconResId)
        }
    }

    fun onMsgArrived(msg: CharSequence?) {
        infoBinding.crvMsgList.appendItem(msg)
    }


    /**
     * 错误页面按钮点击响应
     */
    private val clickButtonListener: ClickButtonListener = object : ClickButtonListener {
        override fun onBackClick(view: View?) {
            ALog.d(LOG_TAG, "onBackClick")
            if (!activity.isFinishing) {
                activity.finish()
            }
        }

        override fun onRetryClick(view: View?) {
            ALog.d(LOG_TAG, "onRetryClick")
            if (canRender && liveInfo != null) {
                if (joinRoomSuccess) {
                    initLiveType(true)
                } else {
                    select(liveInfo!!.live.roomId)
                }
            }
        }
    }

    /**
     * 添加并初始化内部子 view
     */
    fun initViews() {
        // 设置 view 背景颜色
        setBackgroundColor(Color.parseColor("#ff201C23"))
        // 添加视频播放 TextureView
        videoView = CDNStreamTextureView(context)
        addView(videoView, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
        horSwitchView = ExtraTransparentView(context, infoBinding.root)
        // 页面左右切换时滑动到最新的消息内容
        horSwitchView?.registerSelectedRunnable { infoBinding.crvMsgList.toLatestMsg() }
        addView(
            horSwitchView,
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        // 浮层信息向下便宜 status bar 高度，避免重叠
        StatusBarConfig.paddingStatusBarHeight(activity, horSwitchView)

        // 添加错误状态浮层
        errorStateView = AudienceErrorStateView(context)
        addView(errorStateView)
        errorStateView?.visibility = GONE

        // 添加礼物展示浮层
        // 礼物动画渲染 view
        val gifAnimationView = GifAnimationView(context)
        val size = SpUtils.getScreenWidth(context)
        val layoutParams = generateDefaultLayoutParams()
        layoutParams.width = size
        layoutParams.height = size
        layoutParams.gravity = Gravity.BOTTOM
        layoutParams.bottomMargin = SpUtils.dp2pix(context, 166f)
        addView(gifAnimationView, layoutParams)
        gifAnimationView.bringToFront()
        // 绑定礼物渲染 view
        giftRender.init(gifAnimationView)

        // 监听软件盘弹起
        activity.let {
            InputUtils.registerSoftInputListener(it, object : InputParamHelper {
                override fun getHeight(): Int {
                    return this@BaseAudienceContentView.height
                }

                override fun getInputView(): EditText {
                    return infoBinding.etRoomMsgInput
                }
            })
        }

    }

    /**
     * 页面信息，拉流，直播间信息展示等
     *
     * @param info 直播间信息
     */
    open fun renderData(info: LiveInfo) {
        liveInfo = info
        videoView?.setUp(canRender)
        errorStateView?.renderInfo(info.anchor.avatar, info.anchor.nickname)
        // 输入聊天框
        infoBinding.etRoomMsgInput.setOnEditorActionListener(TextView.OnEditorActionListener { v: TextView?, actionId: Int, event: KeyEvent? ->
            if (v === infoBinding.etRoomMsgInput) {
                val input = infoBinding.etRoomMsgInput.text.toString()
                InputUtils.hideSoftInput(infoBinding.etRoomMsgInput)
                roomService.sendTextMessage(input)
                onMsgArrived(ChatRoomMsgCreator.createText(false,liveInfo?.joinUserInfo?.nickname,input))
                return@OnEditorActionListener true
            }
            false
        })
        infoBinding.etRoomMsgInput.visibility = GONE
        // 直播间总人数
        includeRoomTopBinding.tvAudienceCount.text =
            StringUtils.getAudienceCount(info.live.audienceCount)
        // 主播头像
        ImageLoader.with(context.applicationContext)
            .circleLoad(info.anchor.avatar, includeRoomTopBinding.ivAnchorPortrait)
        // 主播昵称
        includeRoomTopBinding.tvAnchorNickname.text = info.anchor.nickname
        includeRoomTopBinding.tvAnchorCoinCount.text =
            StringUtils.getCoinCount(info.live.rewardTotal)
        // 关闭按钮
        infoBinding.ivRoomClose.setOnClickListener {
            // 资源释放，页面退出
            activity.finish()
        }
        // 礼物发送
        infoBinding.ivRoomGift.setOnClickListener { v: View ->
            if (giftDialog == null) {
                giftDialog = GiftDialog(activity)
            }
            giftDialog!!.show(object : GiftSendListener {
                override fun onSendGift(giftId: Int?) {
                    giftId?.let {
                        roomService.reward(it, object : NetRequestCallback<Unit> {
                            override fun success(info: Unit?) {
                                //do nothing
                            }

                            override fun error(code: Int, msg: String) {
                                ToastUtils.showShort(R.string.biz_live_reward_failed)
                            }

                        })
                    }
                }
            })
        }

        // 显示底部输入栏
        infoBinding.tvRoomMsgInput.setOnClickListener { v: View ->
            InputUtils.showSoftInput(
                infoBinding.etRoomMsgInput
            )
        }
    }

    /**
     * 页面绑定准备
     */
    fun prepare() {
        showCdnView()
        changeErrorState(false, -1)
        canRender = true
    }

    /**
     * 页面展示
     */
    fun select(roomId: String) {
        roomService.addDelegate(roomDelegate)
        roomService.enterRoom(roomId, object : NetRequestCallback<LiveInfo> {
            override fun success(info: LiveInfo?) {
                ALog.d(LOG_TAG, "audience join room success")
                joinRoomSuccess = true
                liveInfo = info
                // 根据房间当前状态初始化房间信息
                initLiveType(false)
            }

            override fun error(code: Int, msg: String) {
                ToastUtils.showShort(msg)
                ALog.e(LOG_TAG, "join room failed msg:$msg code= $code")
                // 加入聊天室出现异常直接退出当前页面
                activity.finish()
            }

        })
    }

    protected open fun initLiveType(isRetry: Boolean) {
        if (isRetry) {
            showCdnView()
            changeErrorState(false, -1)
        }
    }


    /**
     * 页面资源释放
     */
    open fun release() {
        roomService.leaveRoom(object : NetRequestCallback<Unit> {
            override fun success(info: Unit?) {

            }

            override fun error(code: Int, msg: String) {
                ToastUtils.showLong(msg)
            }
        })
        if (!canRender) {
            return
        }
        canRender = false
        // 播放器资源释放
        videoView?.release()
        videoView = null
        // 礼物渲染释放
        giftRender.release()
        // 消息列表清空
        infoBinding.crvMsgList.clearAllInfo()

        joinRoomSuccess = false
    }

    protected open fun changeErrorState(error: Boolean, type: Int) {
        if (!canRender) {
            return
        }
        if (error) {
            videoView?.visibility = GONE
            videoView?.reset()
            if (type == AudienceErrorStateView.TYPE_FINISHED) {
                release()
            } else {
                videoView?.release()
            }
        }
        infoBinding.groupNormal.visibility =
            if (error) GONE else VISIBLE

        errorStateView?.visibility = if (error) VISIBLE else GONE

        if (error ) {
            errorStateView?.updateType(type, clickButtonListener)
        }
    }

    override fun dispatchTouchEvent(ev: MotionEvent): Boolean {
        val x = ev.rawX.toInt()
        val y = ev.rawY.toInt()
        // 键盘区域外点击收起键盘
        if (!ViewUtils.isInView(infoBinding.etRoomMsgInput, x, y)) {
            InputUtils.hideSoftInput(infoBinding.etRoomMsgInput)
        }
        return super.dispatchTouchEvent(ev)
    }


    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        NetworkUtils.registerNetworkStatusChangedListener(onNetworkStatusChangedListener)
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        NetworkUtils.unregisterNetworkStatusChangedListener(onNetworkStatusChangedListener)
    }

    companion object {
        const val LOG_TAG = "BaseAudienceContentView"
    }

    init {
        initViews()
    }
}
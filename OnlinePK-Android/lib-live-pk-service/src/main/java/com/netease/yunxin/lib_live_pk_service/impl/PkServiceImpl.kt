/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_pk_service.impl

import com.blankj.utilcode.util.GsonUtils
import com.google.gson.JsonObject
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.Observer
import com.netease.nimlib.sdk.chatroom.ChatRoomServiceObserver
import com.netease.nimlib.sdk.chatroom.model.ChatRoomMessage
import com.netease.nimlib.sdk.passthrough.PassthroughServiceObserve
import com.netease.nimlib.sdk.passthrough.model.PassthroughNotifyData
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.lib_live_pk_service.Constants
import com.netease.yunxin.lib_live_pk_service.PkService
import com.netease.yunxin.lib_live_pk_service.bean.*
import com.netease.yunxin.lib_live_pk_service.delegate.PkDelegate
import com.netease.yunxin.lib_live_pk_service.repository.PkRepository
import com.netease.yunxin.lib_network_kt.NetRequestCallback
import com.netease.yunxin.lib_network_kt.network.Request
import kotlinx.coroutines.*

object PkServiceImpl : PkService {

    private const val LOG_TAG = "PkServiceImpl"

    private var pkScope: CoroutineScope? = null

    private var delegate: PkDelegate? = null

    private var roomId: String? = null

    private var targetAccId: String? = null

    /**
     * 点对点透传消息
     */
    private val p2pMessage by lazy {
        Observer<PassthroughNotifyData> {
            val msgAction: PkActionMsg = GsonUtils.fromJson(it.body, PkActionMsg::class.java)
            val type = msgAction.type
            ALog.d(
                LOG_TAG,
                "p2pMessage type=$type,action =$msgAction"
            )
            if (type == Constants.PkMsgType.PK_ACTION) {
                when (msgAction.action) {
                    Constants.PkAction.PK_INVITE -> {
                        targetAccId = msgAction.actionAnchor.accountId
                        delegate?.onPkRequestReceived(msgAction)
                    }
                    Constants.PkAction.PK_CANCEL -> {
                        delegate?.onPkRequestCancel(msgAction)
                    }
                    Constants.PkAction.PK_ACCEPT -> {
                        delegate?.onPkRequestAccept(msgAction)
                    }
                    Constants.PkAction.PK_REJECT -> {
                        delegate?.onPkRequestRejected(msgAction)
                    }
                    Constants.PkAction.PK_TIME_OUT -> {
                        delegate?.onPkRequestTimeout(msgAction)
                    }
                }
            }

        }
    }

    /**
     * 聊天室服务回调监听（IM SDK）
     */
    private val chatRoomMsgObserver: Observer<MutableList<ChatRoomMessage>> =
        Observer { chatRoomMessages ->
            if (chatRoomMessages.isEmpty()) {
                return@Observer
            }
            for (message in chatRoomMessages) {
                val attachStr = message.attachStr
                ALog.d(LOG_TAG,"chat room message:$attachStr")
                val jsonObject: JsonObject = GsonUtils.fromJson<JsonObject>(
                    attachStr,
                    JsonObject::class.java
                )
                when (jsonObject["type"]?.asInt) {
                    Constants.PkMsgType.PK_START -> {
                        val startPkInfo: PkStartInfo =
                            GsonUtils.fromJson(attachStr, PkStartInfo::class.java)
                        delegate?.onPkStart(startPkInfo)
                        continue
                    }
                    Constants.PkMsgType.PK_PUNISH -> {
                        val punishInfo: PkPunishInfo =
                            GsonUtils.fromJson(attachStr, PkPunishInfo::class.java)
                        delegate?.onPunishStart(punishInfo)
                        continue
                    }
                    Constants.PkMsgType.PK_STOP -> {
                        val endInfo: PkEndInfo = GsonUtils.fromJson(attachStr, PkEndInfo::class.java)
                        delegate?.onPkEnd(endInfo)
                        continue
                    }
                }
            }
        }

    fun destroyInstance() {
        listen(false)
        delegate = null
        roomId = null
        pkScope?.cancel()
        pkScope = null
    }

    /**
     * 注册/反注册 聊天室（IM SDK）
     *
     * @param register true 注册，false 反注册
     */
    private fun listen(register: Boolean) {
        NIMClient.getService(ChatRoomServiceObserver::class.java)
            .observeReceiveMessage(chatRoomMsgObserver, register)

        NIMClient.getService(PassthroughServiceObserve::class.java)
            .observePassthroughNotify(p2pMessage, register)
    }

    /**
     * init pk service
     */
    override fun init(roomId: String) {
        this.roomId = roomId
        pkScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
        listen(true)
    }

    /**
     * set Delegate
     */
    override fun setDelegate(delegate: PkDelegate) {
        this.delegate = delegate
    }

    /**
     * remove delegate
     */
    override fun removeDelegate(delegate: PkDelegate) {
        this.delegate = null
    }

    /**
     * request Pk for other anchor
     * accountId:the anchor you want pk
     */
    override fun requestPk(accountId: String, callback: NetRequestCallback<Unit>) {
        targetAccId = accountId
        pkScope?.launch {
            Request.request(
                { PkRepository.pkAction(Constants.PkAction.PK_INVITE, accountId) },
                success = {
                    callback.success()
                },
                error = { code: Int, msg: String ->
                    callback.error(code, msg)
                }
            )
        }
    }

    /**
     * cancel Pk request
     */
    override fun cancelPkRequest(callback: NetRequestCallback<Unit>) {
        pkScope?.launch {
            Request.request(
                { PkRepository.pkAction(Constants.PkAction.PK_CANCEL, targetAccId) },
                success = {
                    callback.success()
                },
                error = { code: Int, msg: String ->
                    callback.error(code, msg)
                }
            )
        }
    }

    /**
     * accept pk request
     */
    override fun acceptPk(callback: NetRequestCallback<Unit>) {
        pkScope?.launch {
            Request.request(
                { PkRepository.pkAction(Constants.PkAction.PK_ACCEPT, targetAccId) },
                success = {
                    callback.success()
                },
                error = { code: Int, msg: String ->
                    callback.error(code, msg)
                }
            )
        }
    }

    /**
     * reject pk request
     */
    override fun rejectPkRequest(callback: NetRequestCallback<Unit>) {
        pkScope?.launch {
            Request.request(
                { PkRepository.pkAction(Constants.PkAction.PK_REJECT, targetAccId) },
                success = {
                    callback.success()
                },
                error = { code: Int, msg: String ->
                    callback.error(code, msg)
                }
            )
        }
    }

    /**
     * stop pk
     */
    override fun stopPk(callback: NetRequestCallback<Unit>) {
        pkScope?.launch {
            Request.request(
                { PkRepository.stopPk() },
                success = {
                    callback.success()
                },
                error = { code: Int, msg: String ->
                    callback.error(code, msg)
                }
            )
        }
    }

    /**
     * fetch pk Info
     */
    override fun fetchPkInfo(callback: NetRequestCallback<PkInfo>) {
        pkScope?.launch {
            Request.request(
                { PkRepository.getPkInfo(roomId!!) },
                success = { callback.success(it) },
                error = { code: Int, msg: String ->
                    callback.error(code, msg)
                }
            )
        }
    }

}
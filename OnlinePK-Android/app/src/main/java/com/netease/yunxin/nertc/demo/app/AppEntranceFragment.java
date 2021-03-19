package com.netease.yunxin.nertc.demo.app;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.netease.biz_live.yunxin.live.LiveService;
import com.netease.yunxin.nertc.demo.R;
import com.netease.yunxin.nertc.demo.basic.BaseFragment;
import com.netease.yunxin.nertc.demo.list.FunctionAdapter;
import com.netease.yunxin.nertc.demo.list.FunctionItem;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;

import java.util.Arrays;

public class AppEntranceFragment extends BaseFragment {
    public AppEntranceFragment() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    private void initView(View rootView) {
        // 功能列表初始化
        RecyclerView rvFunctionList = rootView.findViewById(R.id.rv_function_list);
        rvFunctionList.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false));
        rvFunctionList.setAdapter(new FunctionAdapter(getContext(), Arrays.asList(
                // 每个业务功能入口均在此处生成 item
                new FunctionItem(R.drawable.icon_pk_live, "PK 直播",
                        () -> {
                            LiveService liveService = ModuleServiceMgr.getInstance().getService(LiveService.class);
                            liveService.launchPkLive(getContext());
                        })
        )));
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_app_entrance, container, false);
        initView(rootView);
        paddingStatusBarHeight(rootView);
        return rootView;
    }
}
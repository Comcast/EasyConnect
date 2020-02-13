package com.easyconnect.easyconnectap.mdns;

import android.content.Context;
import android.net.nsd.NsdServiceInfo;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.easyconnect.easyconnectapp.R;

import java.util.List;


public class MDNSListAdapter extends RecyclerView.Adapter<MDNSListAdapter.MyViewHolder> {

    private LayoutInflater inflater;
    Context mContext;
    private List<NsdServiceInfo> mDNSConfigList;

    public MDNSListAdapter(Context context,List<NsdServiceInfo> mdnsConfigList) {
        inflater = LayoutInflater.from(context);
        this.mContext = context;
        this.mDNSConfigList = mdnsConfigList;
    }

    @Override
    public MyViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = inflater.inflate(R.layout.dialog_listitem, parent, false);
        MyViewHolder holder = new MyViewHolder(view);
        return holder;
    }

    @Override
    public void onBindViewHolder(MyViewHolder holder, int position) {
        holder.config_name.setText(mDNSConfigList.get(position).getServiceName());
    }

    @Override
    public int getItemCount() {
        return mDNSConfigList.size();
    }

    class MyViewHolder extends RecyclerView.ViewHolder {
        TextView config_name;

        public MyViewHolder(View itemView) {
            super(itemView);
            config_name = (TextView) itemView.findViewById(android.R.id.text1);
        }
    }
}

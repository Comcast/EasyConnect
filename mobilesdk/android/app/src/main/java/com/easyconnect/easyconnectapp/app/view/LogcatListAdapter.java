package com.easyconnect.easyconnectapp.app.view;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;
import com.easyconnect.easyconnectapp.app.R;
import java.util.List;

public class LogcatListAdapter extends RecyclerView.Adapter<LogcatListAdapter.MyViewHolder> {

     LayoutInflater inflater;
     Context mContext;
     List<String> mConsoleList;

    public LogcatListAdapter(Context context, List<String> consoleList) {
        inflater = LayoutInflater.from(context);
        this.mContext = context;
        this.mConsoleList = consoleList;
    }

    @Override
    public MyViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = inflater.inflate(R.layout.dialog_listitem, parent, false);
        return new MyViewHolder(view);
    }

    @Override
    public void onBindViewHolder(MyViewHolder holder, int position) {
        holder.configName.setText(mConsoleList.get(position));
    }

    @Override
    public int getItemCount() {
        return mConsoleList.size();
    }

    class MyViewHolder extends RecyclerView.ViewHolder {
        TextView configName;

        public MyViewHolder(View itemView) {
            super(itemView);
            configName = (TextView) itemView.findViewById(android.R.id.text1);
        }
    }
}

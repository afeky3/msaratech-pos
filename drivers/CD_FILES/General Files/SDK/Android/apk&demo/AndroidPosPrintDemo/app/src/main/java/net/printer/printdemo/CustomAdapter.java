/*
* Copyright (C) 2014 The Android Open Source Project
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*      http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

package net.printer.printdemo;

import static net.printer.printdemo.MainActivity.myBinder;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.Spinner;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import net.posprinter.posprinterface.ProcessData;
import net.posprinter.posprinterface.TaskCallback;
import net.posprinter.utils.DataForSendToPrinterPos80;
import net.posprinter.utils.DataForSendToPrinterTSC;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;


/**
 * Provide views to RecyclerView with data from mDataSet.
 */
public class CustomAdapter extends RecyclerView.Adapter<CustomAdapter.ViewHolder> {
    private static final String TAG = "CustomAdapter";

    private String[] mDataSet;
    private Context context;
    private int[] cmdTypeSet;
    // BEGIN_INCLUDE(recyclerViewSampleViewHolder)
    /**
     * Provide a reference to the type of views that you are using (custom ViewHolder)
     */
    public class ViewHolder extends RecyclerView.ViewHolder {
        private final TextView textView;
        private Button test_btn,delete_btn;
        private Spinner cmdType_spinner;
        private int cmdType=0;
        public ViewHolder(View v) {
            super(v);
            // Define click listener for the ViewHolder's View.
            v.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Log.d(TAG, "Element " + getAdapterPosition() + " clicked.");
                }
            });
            textView = (TextView) v.findViewById(R.id.textView);
            test_btn=v.findViewById(R.id.test_btn);
            test_btn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    myBinder.SendDataToPrinter(textView.getText().toString(), new TaskCallback() {
                        @Override
                        public void OnSucceed() {

                        }

                        @Override
                        public void OnFailed() {

                        }
                    }, new ProcessData() {
                        @Override
                        public List<byte[]> processDataBeforeSend() {
                            List<byte[]> list = new ArrayList<byte[]>();
                            if(cmdType==0) {
                                list.add("Welcome to Thermal Printer\r\n".getBytes());
                                list.add(DataForSendToPrinterPos80.selectCutPagerModerAndCutPager(0x42, 0x66));
                            }else{
                                //设置标签纸大小
                                list.add(DataForSendToPrinterTSC.sizeBymm(50,30));
                                //设置间隙
                                list.add(DataForSendToPrinterTSC.gapBymm(2,0));
                                //清除缓存
                                list.add(DataForSendToPrinterTSC.cls());
                                //设置方向
                                list.add(DataForSendToPrinterTSC.direction(0));
                                //线条
//                    list.add(DataForSendToPrinterTSC.bar(10,10,200,3));
                                //条码
                                list.add(DataForSendToPrinterTSC.barCode(10,15,"128",100,1,0,2,2,"abcdef12345"));
                                //文本
//                    list.add(DataForSendToPrinterTSC.text(10,30,"1",0,1,1,"abcasdjknf"));
                                //打印
                                list.add(DataForSendToPrinterTSC.print(1));
                            }
                            return list;
                        }
                    });
                }
            });
            delete_btn=v.findViewById(R.id.delete_btn);
            delete_btn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                   myBinder.RemovePrinter(textView.getText().toString(), new TaskCallback() {
                       @Override
                       public void OnSucceed() {
                           removeData(textView.getText().toString());
                       }

                       @Override
                       public void OnFailed() {

                       }
                   });
                }
            });
            cmdType_spinner=v.findViewById(R.id.cmdType_list);
            ArrayAdapter<String> arrayAdapter;
            //设置选中后的布局，simple_spinner_item 是系统定义的布局，这里用系统的
            arrayAdapter = new ArrayAdapter<String>(context,R.layout.custom_spinner_item, context.getResources().getStringArray(R.array.CmdType));
            //设置下拉框布局，simple_spinner_dropdown_item 是系统定义的布局，这里用系统的
            arrayAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
            cmdType_spinner.setAdapter(arrayAdapter);
            //设置默认选中项
            cmdType_spinner.setSelection(0,true);
            cmdType_spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                @Override
                public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                    cmdType_spinner.setSelection(position,true);
                    cmdType=position;
                    for(int i=0;i<mDataSet.length;i++){
                        if(mDataSet[i].equals(textView.getText().toString())){
                            cmdTypeSet[i]=position;
                            break;
                        }
                    }
                }

                @Override
                public void onNothingSelected(AdapterView<?> parent) {

                }
            });
        }

        public TextView getTextView() {
            return textView;
        }
    }

    // END_INCLUDE(recyclerViewSampleViewHolder)

    /**
     * Initialize the dataset of the Adapter.
     *
     * @param dataSet String[] containing the data to populate views to be used by RecyclerView.
     */
    public CustomAdapter(String[] dataSet, Context tmpContext) {
        mDataSet = dataSet;
        context=tmpContext;
        cmdTypeSet=new int[mDataSet.length];
    }
    public void setmData(String[] dataSet) {
        mDataSet = dataSet;
        cmdTypeSet=new int[mDataSet.length];
        notifyDataSetChanged();
    }
    public int[] getCmdTypeSet(){
        return cmdTypeSet;
    }
    @SuppressLint("NotifyDataSetChanged")
    public void removeData(String dataSet) {
        for(int i=0;i<mDataSet.length;i++){
           if(mDataSet[i]==dataSet){
               String[] temp=new String[mDataSet.length-1];
               for(int j=0;j<mDataSet.length-1;j++){
                   temp[j]=mDataSet[j+1];
               }
               mDataSet=temp;
               break;
           }
        }
        cmdTypeSet=new int[mDataSet.length];
        notifyDataSetChanged();
    }
    // BEGIN_INCLUDE(recyclerViewOnCreateViewHolder)
    // Create new views (invoked by the layout manager)
    @Override
    public ViewHolder onCreateViewHolder(ViewGroup viewGroup, int viewType) {
        // Create a new view.
        View v = LayoutInflater.from(viewGroup.getContext())
                .inflate(R.layout.text_row_item, viewGroup, false);

        return new ViewHolder(v);
    }
    // END_INCLUDE(recyclerViewOnCreateViewHolder)

    // BEGIN_INCLUDE(recyclerViewOnBindViewHolder)
    // Replace the contents of a view (invoked by the layout manager)
    @Override
    public void onBindViewHolder(ViewHolder viewHolder, final int position) {
        Log.d(TAG, "Element " + position + " set.");
        // Get element from your dataset at this position and replace the contents of the view
        // with that element
        viewHolder.getTextView().setText(mDataSet[position]);
    }
    // END_INCLUDE(recyclerViewOnBindViewHolder)

    // Return the size of your dataset (invoked by the layout manager)
    @Override
    public int getItemCount() {
        return mDataSet.length;
    }
}

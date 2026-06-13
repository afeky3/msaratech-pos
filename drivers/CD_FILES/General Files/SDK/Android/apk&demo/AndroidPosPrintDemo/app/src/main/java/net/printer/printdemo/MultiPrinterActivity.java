package net.printer.printdemo;

import static net.printer.printdemo.MainActivity.myBinder;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ExpandableListView;
import android.widget.ListView;
import android.widget.RadioButton;
import android.widget.TextView;

import net.posprinter.posprinterface.ProcessData;
import net.posprinter.posprinterface.TaskCallback;
import net.posprinter.utils.DataForSendToPrinterPos80;
import net.posprinter.utils.DataForSendToPrinterTSC;
import net.printer.printdemo.ReceiptPrinter.R80Activity;

import org.json.JSONException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class MultiPrinterActivity extends AppCompatActivity {
    private static final String TAG = "RecyclerViewFragment";
    private static final String KEY_LAYOUT_MANAGER = "layoutManager";
    private static int DATASET_COUNT = 20;
    private Button AddPrinter_btn,TestAll_btn;
    private enum LayoutManagerType {
        GRID_LAYOUT_MANAGER,
        LINEAR_LAYOUT_MANAGER
    }
    protected LayoutManagerType mCurrentLayoutManagerType;
    protected RecyclerView mRecyclerView;
    protected CustomAdapter mAdapter;
    protected RecyclerView.LayoutManager mLayoutManager;
    protected String[] mDataset;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_multi_printer);
        AddPrinter_btn=findViewById(R.id.addPrinter_btn);
        AddPrinter_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(MultiPrinterActivity.this, AddPrinterActivity.class);
                startActivity(intent);
            }
        });
        TestAll_btn=findViewById(R.id.testAll_btn);
        TestAll_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                    for(int i=0;i<myBinder.GetPrinterInfoList().size();i++){
                        int finalI = i;
                        myBinder.SendDataToPrinter(myBinder.GetPrinterInfoList().get(i).printerName, new TaskCallback() {
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
                                if(mAdapter.getCmdTypeSet()[finalI]==0){
                                    list.add("Welcome to Thermal Printer\r\n".getBytes());
                                    list.add(DataForSendToPrinterPos80.selectCutPagerModerAndCutPager(0x42,0x66));
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
            }
        });
        // BEGIN_INCLUDE(initializeRecyclerView)
        mRecyclerView = (RecyclerView) findViewById(R.id.printer_list);

        // LinearLayoutManager is used here, this will layout the elements in a similar fashion
        // to the way ListView would layout elements. The RecyclerView.LayoutManager defines how
        // elements are laid out.
        mLayoutManager = new LinearLayoutManager(MultiPrinterActivity.this);

        mCurrentLayoutManagerType = LayoutManagerType.LINEAR_LAYOUT_MANAGER;

        if (savedInstanceState != null) {
            // Restore saved layout manager type.
            mCurrentLayoutManagerType = (LayoutManagerType) savedInstanceState
                    .getSerializable(KEY_LAYOUT_MANAGER);
        }
        setRecyclerViewLayoutManager(mCurrentLayoutManagerType);
        // Initialize dataset, this data would usually come from a local content provider or
        // remote server.
        initDataset();
        mAdapter = new CustomAdapter(mDataset,getApplicationContext());
        // Set CustomAdapter as the adapter for RecyclerView.
        mRecyclerView.setAdapter(mAdapter);
        // END_INCLUDE(initializeRecyclerView)

    }

    /**
     * Set RecyclerView's LayoutManager to the one given.
     *
     * @param layoutManagerType Type of layout manager to switch to.
     */
    public void setRecyclerViewLayoutManager(LayoutManagerType layoutManagerType) {
        int scrollPosition = 0;

        // If a layout manager has already been set, get current scroll position.
        if (mRecyclerView.getLayoutManager() != null) {
            scrollPosition = ((LinearLayoutManager) mRecyclerView.getLayoutManager())
                    .findFirstCompletelyVisibleItemPosition();
        }

        mLayoutManager = new LinearLayoutManager(MultiPrinterActivity.this);
        mCurrentLayoutManagerType = LayoutManagerType.LINEAR_LAYOUT_MANAGER;

        mRecyclerView.setLayoutManager(mLayoutManager);
        mRecyclerView.scrollToPosition(scrollPosition);
    }

    /**
     * Generates Strings for RecyclerView's adapter. This data would usually come
     * from a local content provider or remote server.
     */
    private void initDataset() {
        DATASET_COUNT=myBinder.GetPrinterInfoList().size();
        mDataset = new String[DATASET_COUNT];
        for (int i = 0; i < DATASET_COUNT; i++) {
            mDataset[i] = myBinder.GetPrinterInfoList().get(i).printerName;
        }
    }
    @Override
    protected void onResume() {
        super.onResume();
        initDataset();
        mAdapter.setmData(mDataset);
        mAdapter.notifyDataSetChanged();
    }
}
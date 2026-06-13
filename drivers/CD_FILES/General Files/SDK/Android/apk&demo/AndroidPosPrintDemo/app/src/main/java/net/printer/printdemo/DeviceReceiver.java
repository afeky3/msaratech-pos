package net.printer.printdemo;

import android.Manifest;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.util.Log;
import android.widget.ArrayAdapter;
import android.widget.ListView;


import androidx.core.app.ActivityCompat;

import java.util.ArrayList;

/**
 * Created by charlie on 2017/4/2.
 * Bluetooth search state braodcastrecever
 * 蓝牙搜索广播监听
 */

public class DeviceReceiver extends BroadcastReceiver {


    private ArrayList<String> deviceList_found = new ArrayList<String>();
    private ArrayAdapter<String> adapter;
    private ListView listView;

    public DeviceReceiver(ArrayList<String> deviceList_found, ArrayAdapter<String> adapter, ListView listView) {
        this.deviceList_found = deviceList_found;
        this.adapter = adapter;
        this.listView = listView;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        if (BluetoothDevice.ACTION_FOUND.equals(action)) {
            //搜索到的新设备
            BluetoothDevice btd = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
            //搜索没有配对过的蓝牙设备
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                // only for gingerbread and newer versions
                if (ActivityCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
                    // TODO: Consider calling
                    //    ActivityCompat#requestPermissions
                    // here to request the missing permissions, and then overriding
                    //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
                    //                                          int[] grantResults)
                    // to handle the case where the user grants the permission. See the documentation
                    // for ActivityCompat#requestPermissions for more details.
                    return;
                }
            }
            if (btd.getBondState() != BluetoothDevice.BOND_BONDED) {
                if (!deviceList_found.contains(btd.getName() + '\n' + btd.getAddress())) {
                    deviceList_found.add(btd.getName() + '\n' + btd.getAddress());
                   // Log.e("onReceive: ","fsdf" );
                    try {
                        adapter.notifyDataSetChanged();
                        listView.notify();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }else if (BluetoothAdapter.ACTION_DISCOVERY_FINISHED.equals(action)){
            //搜索结束
            if(listView.getCount()==0){
                deviceList_found.add(context.getString(R.string.none_ble_device));
                try{
                    adapter.notifyDataSetChanged();
                }catch (Exception e){
                    e.printStackTrace();
                }
            }


        }

    }
}

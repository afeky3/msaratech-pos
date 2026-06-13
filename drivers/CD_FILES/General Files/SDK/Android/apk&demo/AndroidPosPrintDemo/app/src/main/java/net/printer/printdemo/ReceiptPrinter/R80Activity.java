package net.printer.printdemo.ReceiptPrinter;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import com.starmicronics.starioextension.ICommandBuilder;
import com.starmicronics.starioextension.StarIoExt;

import net.posprinter.posprinterface.ProcessData;
import net.posprinter.posprinterface.TaskCallback;
import net.posprinter.utils.BitmapProcess;
import net.posprinter.utils.BitmapToByteData;
import net.posprinter.utils.DataForSendToPrinterPos80;
import net.posprinter.utils.StringUtils;
import net.printer.printdemo.MainActivity;
import net.printer.printdemo.R;
import net.printer.printdemo.databinding.ActivityMainBinding;
import net.printer.printdemo.databinding.ActivityR80Binding;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

public class R80Activity extends AppCompatActivity implements View.OnClickListener {
    private ActivityR80Binding binding;
    private Button sample,text,barcode,qrcode,bitmap,status,cashdrawer;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_r80);
        binding = ActivityR80Binding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        initview();
    }

    private void initview(){
        sample = findViewById(R.id.bt_rcp);
        text = findViewById(R.id.bt_80text);
        barcode = findViewById(R.id.bt_80barcode);
        qrcode = findViewById(R.id.bt_80qr);
        bitmap = findViewById(R.id.bt_80bitmap);
        status=findViewById(R.id.bt_status);
        cashdrawer=findViewById(R.id.bt_cashdrawer);
        sample.setOnClickListener(this);
        text.setOnClickListener(this);
        barcode.setOnClickListener(this);
        qrcode.setOnClickListener(this);
        bitmap.setOnClickListener(this);
        status.setOnClickListener(this);
        cashdrawer.setOnClickListener(this);
    }
    @Override
    public void onClick(View view) {
        int id = view.getId();
        for(int i=0;i<Integer.parseInt(binding.rep.getText().toString());i++) {
            if (id == R.id.bt_rcp) {
                printSample();
//                printText();
//                printBarcode();
//                printqr();
//                printBitmap();
//                printCut();
            }

            if (id == R.id.bt_80text) {
                printText();
            }

            if (id == R.id.bt_80barcode) {
                printBarcode();
            }

            if (id == R.id.bt_80qr) {
                printqr();
            }

            if (id == R.id.bt_80bitmap) {
                printBitmap();

            }
            if(id==R.id.bt_status){
                GetStatus();
            }
            if(id==R.id.bt_cashdrawer){
                openCashdrawer();
            }
        }
    }

    /**
     * print receipt
     */
    private void printSample(){
        if (MainActivity.ISCONNECT){
            MainActivity.myBinder.WriteDataByUSB(new TaskCallback() {
                @Override
                public void OnSucceed() {
                    Log.e( "OnSucceed: ", "");
                    Toast.makeText(getApplicationContext(),getString(R.string.send_success),Toast.LENGTH_SHORT).show();
                }

                @Override
                public void OnFailed() {
                    Log.e( "OnFailed: ", "");
                    Toast.makeText(getApplicationContext(),getString(R.string.send_failed),Toast.LENGTH_SHORT).show();
                }
            }, new ProcessData() {
                @Override
                public List<byte[]> processDataBeforeSend() {
                    List<byte[]> list = new ArrayList<>();
                    list.add(DataForSendToPrinterPos80.initializePrinter());
                    list.add(DataForSendToPrinterPos80.setAbsolutePrintPosition(60,00));//设置初始位置
                    list.add(DataForSendToPrinterPos80.selectCharacterSize(17));//字体放大一倍
                    list.add(StringUtils.strTobytes("printer"));
                    list.add(DataForSendToPrinterPos80.setAbsolutePrintPosition(100,01));
                    list.add(StringUtils.strTobytes("printer"));
                    list.add(DataForSendToPrinterPos80.printAndFeedLine());
                    list.add(DataForSendToPrinterPos80.printAndFeedLine());

                    list.add(DataForSendToPrinterPos80.initializePrinter());
                    list.add(DataForSendToPrinterPos80.setAbsolutePrintPosition(60,00));
                    list.add(StringUtils.strTobytes("printer"));
                    list.add(DataForSendToPrinterPos80.setAbsolutePrintPosition(100,01));
                    list.add(StringUtils.strTobytes("printer"));
                    list.add(DataForSendToPrinterPos80.printAndFeedLine());

                    list.add(DataForSendToPrinterPos80.initializePrinter());
                    list.add(DataForSendToPrinterPos80.setAbsolutePrintPosition(60,00));
                    list.add(StringUtils.strTobytes("printer"));
                    list.add(DataForSendToPrinterPos80.setAbsolutePrintPosition(100,01));
                    list.add(StringUtils.strTobytes("printer"));
                    list.add(DataForSendToPrinterPos80.printAndFeedLine());

                    list.add(DataForSendToPrinterPos80.initializePrinter());
                    list.add(DataForSendToPrinterPos80.setAbsolutePrintPosition(60,00));
                    list.add(StringUtils.strTobytes("printer"));
                    list.add(DataForSendToPrinterPos80.setAbsolutePrintPosition(100,01));
                    list.add(StringUtils.strTobytes("printer"));
                    list.add(DataForSendToPrinterPos80.printAndFeedLine());

                    list.add(DataForSendToPrinterPos80.initializePrinter());
                    list.add(DataForSendToPrinterPos80.setAbsolutePrintPosition(60,00));
                    list.add(StringUtils.strTobytes("printer"));
                    list.add(DataForSendToPrinterPos80.setAbsolutePrintPosition(100,01));
                    list.add(StringUtils.strTobytes("printer"));
                    list.add(DataForSendToPrinterPos80.printAndFeedLine());

                    list.add(DataForSendToPrinterPos80.initializePrinter());
                    list.add(DataForSendToPrinterPos80.setAbsolutePrintPosition(60,00));
                    list.add(StringUtils.strTobytes("printer"));
                    list.add(DataForSendToPrinterPos80.setAbsolutePrintPosition(100,01));
                    list.add(StringUtils.strTobytes("printer"));
                    list.add(DataForSendToPrinterPos80.printAndFeedLine());

                    list.add(DataForSendToPrinterPos80.initializePrinter());
                    list.add(DataForSendToPrinterPos80.setAbsolutePrintPosition(60,00));
                    list.add(StringUtils.strTobytes("printer"));
                    list.add(DataForSendToPrinterPos80.setAbsolutePrintPosition(100,01));
                    list.add(StringUtils.strTobytes("printer"));
                    list.add(DataForSendToPrinterPos80.printAndFeedLine());
                    printCut();
                    return list;
                }
            },6000);
        }else {
            Toast.makeText(getApplicationContext(),getString(R.string.connect_first),Toast.LENGTH_SHORT).show();
        }
    }

    /**
     * print text
     */
    private void printText(){

        if (MainActivity.ISCONNECT){
            MainActivity.myBinder.WriteSendData(new TaskCallback() {
                @Override
                public void OnSucceed() {
                    Toast.makeText(getApplicationContext(),getString(R.string.send_success),Toast.LENGTH_SHORT).show();

                }

                @Override
                public void OnFailed() {
                    Toast.makeText(getApplicationContext(),getString(R.string.send_failed),Toast.LENGTH_SHORT).show();
                }
            }, new ProcessData() {
                @Override
                public List<byte[]> processDataBeforeSend() {
                    List<byte[]> list = new ArrayList<>();
                    list.add(DataForSendToPrinterPos80.initializePrinter());
                    list.add(DataForSendToPrinterPos80.selectOrCancelBoldModel(0));
                    list.add(StringUtils.strTobytes("1234567890qwertyuiopakjbdscm nkjdv mcdskjb"));
                    list.add(DataForSendToPrinterPos80.selectOrCancelBoldModel(1));
                    list.add(StringUtils.strTobytes("1234567890qwertyuiopakjbdscm nkjdv mcdskjb"));
                    for(int i=0;i<10;i++)
                    {
                        list.add(StringUtils.strTobytes("1234567890\r\n"));
                    }
//                    list.add(DataForSendToPrinterPos80.printAndFeedLine());
                    list.add(DataForSendToPrinterPos80.printAndFeedForward(10));
                    printCut();
                    return list;
                }
            });
        }else {
            Toast.makeText(getApplicationContext(),getString(R.string.connect_first),Toast.LENGTH_SHORT).show();
        }

    }
    private void sendHex(){
        if (MainActivity.ISCONNECT){
            MainActivity.myBinder.WriteSendData(new TaskCallback() {
                @Override
                public void OnSucceed() {
                    Toast.makeText(getApplicationContext(),getString(R.string.send_success),Toast.LENGTH_SHORT).show();

                }

                @Override
                public void OnFailed() {
                    Toast.makeText(getApplicationContext(),getString(R.string.send_failed),Toast.LENGTH_SHORT).show();
                }
            }, new ProcessData() {
                @Override
                public List<byte[]> processDataBeforeSend() {
                    List<byte[]> list = new ArrayList<>();
                    byte[] codepage={0x1F, 0x1B, 0x1F, (byte)0xFF,(byte)51,0x0A,0x00};
                    list.add(codepage);
                    return list;
                }
            });
        }else {
            Toast.makeText(getApplicationContext(),getString(R.string.connect_first),Toast.LENGTH_SHORT).show();
        }
    }

    /**
     print barcode
     */
    private void printBarcode(){
        if (MainActivity.ISCONNECT){
            MainActivity.myBinder.WriteSendData(new TaskCallback() {
                @Override
                public void OnSucceed() {
                    Toast.makeText(getApplicationContext(),getString(R.string.send_success),Toast.LENGTH_SHORT).show();

                }

                @Override
                public void OnFailed() {
                    Toast.makeText(getApplicationContext(),getString(R.string.send_failed),Toast.LENGTH_SHORT).show();
                }
            }, new ProcessData() {
                @Override
                public List<byte[]> processDataBeforeSend() {
                    List<byte[]> list = new ArrayList<>();
                    //初始化打印机，清除缓存
                    list.add(DataForSendToPrinterPos80.initializePrinter());
                    //选择对齐方式
                    list.add(DataForSendToPrinterPos80.selectAlignment(1));
                    //选择HRI文字文字
                    list.add(DataForSendToPrinterPos80.selectHRICharacterPrintPosition(02));
                    //设置条码宽度
                    list.add(DataForSendToPrinterPos80.setBarcodeWidth(2));
                    //设置高度
                    list.add(DataForSendToPrinterPos80.setBarcodeHeight(80));
                    //条码的类型和内容，73是code128的类型，请参考说明手册每种类型的规则
                    list.add(DataForSendToPrinterPos80.printBarcode(73,10,"{B12345678"));
                    //打印指令
                    list.add(DataForSendToPrinterPos80.printAndFeedLine());
                    printCut();
                    return list;
                }
            });
        }else {
            Toast.makeText(getApplicationContext(),getString(R.string.connect_first),Toast.LENGTH_SHORT).show();
        }
    }
    /**
     * 打印二维条码
     */
    private void printqr(){
        if (MainActivity.ISCONNECT){
            MainActivity.myBinder.WriteSendData(new TaskCallback() {
                @Override
                public void OnSucceed() {
                    Toast.makeText(getApplicationContext(),getString(R.string.send_success),Toast.LENGTH_SHORT).show();

                }

                @Override
                public void OnFailed() {
                    Toast.makeText(getApplicationContext(),getString(R.string.send_failed),Toast.LENGTH_SHORT).show();
                }
            }, new ProcessData() {
                @Override
                public List<byte[]> processDataBeforeSend() {
                    List<byte[]> list = new ArrayList<>();
                    //initial printer
                    list.add(DataForSendToPrinterPos80.initializePrinter());
                    //align type
                    list.add(DataForSendToPrinterPos80.selectAlignment(1));
                    list.add(DataForSendToPrinterPos80.printQRcode(3,48,"print test"));
                    //Log.e( "processDataBeforeSend: ", StringUtils.bytes2HexString(DataForSendToPrinterPos80.printQRcode(3,48,"print test")));
                    list.add(DataForSendToPrinterPos80.printAndFeedLine());
                    printCut();
                    return list;
                }
            });
        }else {
            Toast.makeText(getApplicationContext(),getString(R.string.connect_first),Toast.LENGTH_SHORT).show();
        }
    }

    private void printBitmap(){
//        final Bitmap bitmap1 = BitmapFactory.decodeResource(getResources(), R.drawable.test);
        final Bitmap bitmap1 =  BitmapProcess.compressBmpByYourWidth
                (BitmapFactory.decodeResource(getResources(), R.drawable.test),300);

        if (MainActivity.ISCONNECT){
            MainActivity.myBinder.WriteSendData(new TaskCallback() {
                @Override
                public void OnSucceed() {
                    Toast.makeText(getApplicationContext(),getString(R.string.send_success),Toast.LENGTH_SHORT).show();

                }

                @Override
                public void OnFailed() {
                    Toast.makeText(getApplicationContext(),getString(R.string.send_failed),Toast.LENGTH_SHORT).show();
                }
            }, new ProcessData() {
                @Override
                public List<byte[]> processDataBeforeSend() {
                    List<byte[]> list = new ArrayList<>();
                    list.add(DataForSendToPrinterPos80.initializePrinter());
                    List<Bitmap> blist= new ArrayList<>();
                    blist = BitmapProcess.cutBitmap(150,bitmap1);
                    for (int i= 0 ;i<blist.size();i++){
                        list.add(DataForSendToPrinterPos80.printRasterBmp(0,blist.get(i), BitmapToByteData.BmpType.Dithering, BitmapToByteData.AlignType.Center,576));
                    }
//                    list.add(StringUtils.strTobytes("1234567890qwe rtyuiopakjbdscm nkjdv mcdskjb"));
                    list.add(DataForSendToPrinterPos80.printAndFeedLine());
                    printCut();
                    return list;
                }
            });
        }else {
            Toast.makeText(getApplicationContext(),getString(R.string.connect_first),Toast.LENGTH_SHORT).show();
        }
    }
    private void printCut(){
        if (MainActivity.ISCONNECT){
            MainActivity.myBinder.WriteSendData(new TaskCallback() {
                @Override
                public void OnSucceed() {
                    Toast.makeText(getApplicationContext(),getString(R.string.send_success),Toast.LENGTH_SHORT).show();

                }

                @Override
                public void OnFailed() {
                    Toast.makeText(getApplicationContext(),getString(R.string.send_failed),Toast.LENGTH_SHORT).show();
                }
            }, new ProcessData() {
                @Override
                public List<byte[]> processDataBeforeSend() {
                    List<byte[]> list = new ArrayList<>();
                    list.add(DataForSendToPrinterPos80.initializePrinter());
                    //directly cut
//                    list.add(DataForSendToPrinterPos80.selectCutPagerModerAndCutPager(0));
                    //feed and cut
                    list.add(DataForSendToPrinterPos80.selectCutPagerModerAndCutPager(0x42,0x66));
                    return list;
                }
            });
        }else {
            Toast.makeText(getApplicationContext(),getString(R.string.connect_first),Toast.LENGTH_SHORT).show();
        }
    }
    private void openCashdrawer(){
        if (MainActivity.ISCONNECT){
            MainActivity.myBinder.WriteSendData(new TaskCallback() {
                @Override
                public void OnSucceed() {
                    Toast.makeText(getApplicationContext(),getString(R.string.send_success),Toast.LENGTH_SHORT).show();

                }

                @Override
                public void OnFailed() {
                    Toast.makeText(getApplicationContext(),getString(R.string.send_failed),Toast.LENGTH_SHORT).show();
                }
            }, new ProcessData() {
                @Override
                public List<byte[]> processDataBeforeSend() {
                    List<byte[]> list = new ArrayList<>();
                    list.add(DataForSendToPrinterPos80.initializePrinter());
                    //directly cut
//                    list.add(DataForSendToPrinterPos80.selectCutPagerModerAndCutPager(0));
                    //feed and cut
                    list.add(DataForSendToPrinterPos80.openCashdrawer());
                    return list;
                }
            });
        }else {
            Toast.makeText(getApplicationContext(),getString(R.string.connect_first),Toast.LENGTH_SHORT).show();
        }
    }
    //Get printer status
    private void GetStatus(){
        if (MainActivity.ISCONNECT){
//            MainActivity.myBinder.WriteSendData(new TaskCallback() {
//                @Override
//                public void OnSucceed() {
//                    Toast.makeText(getApplicationContext(),getString(R.string.send_success),Toast.LENGTH_SHORT).show();
//                    MainActivity.myBinder.Acceptdatafromprinter(new TaskCallback() {
//                        @Override
//                        public void OnSucceed() {
//                            if (MainActivity.myBinder.ReadBuffer() != null) {
//                                byte[] fromPrinter = MainActivity.myBinder.ReadBuffer().getFirst();
//                                Log.e("AcceptOnSucceed: ", StringUtils.bytes2HexString(fromPrinter));
//                                if(fromPrinter[0]!=0x16){
//                                    Toast.makeText(getApplicationContext(),"Printer error",Toast.LENGTH_SHORT).show();
//                                }else{
//                                    Toast.makeText(getApplicationContext(),"Printer normal",Toast.LENGTH_SHORT).show();
//                                }
//                            }
//                        }
//
//                        @Override
//                        public void OnFailed() {
//                            Log.e("OnFailed: ", "");
//                        }
//                    }, 1);
//                }
//
//                @Override
//                public void OnFailed() {
//                    Toast.makeText(getApplicationContext(),getString(R.string.send_failed),Toast.LENGTH_SHORT).show();
//                }
//            }, new ProcessData() {
//                @Override
//                public List<byte[]> processDataBeforeSend() {
//                    List<byte[]> list = new ArrayList<>();
//                    list.add(DataForSendToPrinterPos80.initializePrinter());
//                    byte[] getStatus={0x10,0x04,0x01};
//                    list.add(getStatus);
//                    return list;
//                }
//            });
            Toast.makeText(getApplicationContext(),MainActivity.myBinder.GetPrinterStatus().toString(),Toast.LENGTH_SHORT).show();
        }else {
            Toast.makeText(getApplicationContext(),getString(R.string.connect_first),Toast.LENGTH_SHORT).show();
        }

    }
}

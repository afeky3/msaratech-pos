using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Runtime.InteropServices;


namespace TestDLL_WindowsFormsApplication
{
    public partial class Form1 : Form
    {
        private int NET_PORT = 0;
        private int USB_PORT = 1;
        private int COM_PORT = 2;
        private int PortType;

        /// ////////////////////////////////////////// dll interface
        /// //net api
        [DllImport("ZyPrinter.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
        public static extern IntPtr InitNetSev();

        [DllImport("ZyPrinter.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
        public static extern IntPtr ConnectNetPortEx(int addr0, int addr1, int addr2, int addr3, int port, int Timeout);

        [DllImport("ZyPrinter.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
        public static extern int WriteToNetPort(IntPtr hNet, byte[] sendBuffer, int bufferSize);

        [DllImport("ZyPrinter.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
        public static extern int CloseNetPor(IntPtr hNe);

        //usb api
        [DllImport("ZyPrinter.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
        public static extern IntPtr OpenUsb();

        [DllImport("ZyPrinter.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
        public static extern int CloseUsb(IntPtr hUsb);

        [DllImport("ZyPrinter.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
        public static extern int WriteUsb(IntPtr hUsb, byte[] sendBuffer, int bufferSize);

        //com api
        [DllImport("ZyPrinter.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
        public static extern IntPtr OpenCOM(int comm, int baud, int timeOut);

        [DllImport("ZyPrinter.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
        public static extern int CloseCom(IntPtr hCom);

        [DllImport("ZyPrinter.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
        public static extern int WriteCom(IntPtr hCom, byte[] sendBuffer, int bufferSize);

        IntPtr hNet;
        IntPtr hUsb;
        IntPtr hCOM;
        public Form1()
        {
            InitializeComponent();
        }
        private void OpenPort()
        {
            if (PortType == NET_PORT)
            {
                // api mode
                int port = 9100;
                string host = "191.168.1.100";
                string[] sArray = host.Split('.');

                InitNetSev();
                hNet = ConnectNetPortEx(int.Parse(sArray[0]), int.Parse(sArray[1]), int.Parse(sArray[2]), int.Parse(sArray[3]), port, 20);

                if (null != hNet && "-1" != hNet.ToString())
                {
                    Console.Write("Successful Opening of Network Port");
                }
                else
                {
                    Console.Write("Failed to open net! Please insert net printer!");
                }
            }
            else if (PortType == USB_PORT)
            {
                hUsb = OpenUsb();

                if (null != hUsb && "-1" != hUsb.ToString())
                {
                    Console.Write("Successful Opening of USB Port");
                }
                else
                {
                    Console.Write("Failed to open USB! Please insert USB printer!");
                }
            }
            else  //COM PORT
            {
                int comm = 7;
                int baud = 19200;

                hCOM = OpenCOM(comm, baud, 10);
                if (null != hCOM && "-1" != hCOM.ToString())
                {
                    Console.Write("Successful Opening of Serial Port");
                }
                else
                {
                    Console.Write("Failed to open COM! Please insert COM printer!");
                }
            }
        }

        private void ClosePort()
        {
            if (PortType == NET_PORT)
            {
                CloseNetPor(hNet);
                hNet = (IntPtr)null;
            }
            else if (PortType == USB_PORT)
            {
                CloseUsb(hUsb);
                hUsb = (IntPtr)null;
            }
            else  //COM PORT
            {
                CloseCom(hCOM);
                hCOM = (IntPtr)null;
            }
        }

        private void SendDataToPort(byte[] sendBuffer, int bufferSize)
        {
            int ret = 0;

            for (int i = 0; i < 3; i++)  //max send again three
            {
                if (PortType == NET_PORT)
                {
                    if (null == hNet || "0" == hNet.ToString())
                        OpenPort();

                    if (null != hNet && "-1" != hNet.ToString())
                        ret = WriteToNetPort(hNet, sendBuffer, bufferSize);

                    //CloseNetPor(hNet);
                }
                else if (PortType == USB_PORT)
                {
                    if (null == hUsb || "0" == hUsb.ToString())
                        OpenPort();

                    if (null != hUsb && "-1" != hUsb.ToString())
                        ret = WriteUsb(hUsb, sendBuffer, bufferSize);

                    //CloseUsb(hUsb);
                }
                else  //COM PORT
                {
                    if (null == hCOM || "0" == hCOM.ToString())
                        OpenPort();

                    if (null != hCOM && "-1" != hCOM.ToString())
                        ret = WriteCom(hCOM, sendBuffer, bufferSize);

                    //CloseCom(hCOM);
                }

                if (ret > 0)
                {
                    break;
                }
                else
                {
                    ClosePort();
                }
            }

            if (ret > 0)
            {
                Console.Write("Data send finish");
            }
            else
            {
                Console.Write("Data send fail");
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            PortType = USB_PORT;
            OpenPort();
            //Byte[] openCashDrawer = new Byte[] { 0x1b, 0x70, 0x00, 0x1e, 0xff, 0x00 };
        }

        private void button2_Click(object sender, EventArgs e)
        {
            Byte[] SendBuf = new Byte[] { 0x1d, 0x56, 0x42, 0x66 };
            SendDataToPort(SendBuf, 4);
        }

        private void button3_Click(object sender, EventArgs e)
        {
            ClosePort();
        }
    }
}

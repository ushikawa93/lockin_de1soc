using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace plot
{
    class Scope
    {
        protected float x;
        Point[] state;
        Control canvas;
        Graphics graphics;
        List<Pen> pens;
        public bool[] EnabledChannels;
        internal int Delay;
        private DateTime delay_time;
        private bool delay_status = false;

        public uint SignalsNumber { get; private set; }
        public float [] Amplitude { get; set; }
        public float Time { get; set; }
        public float SamplingFrequency { get; private set; }

        public float Gain { get; private set; }

        public bool ClearOnOverrun { get; private set; }

        public Color BackColor { get; set; }
        public Color MainGridColor { get; set; }
        public Color SecGridColor { get; set; }
        public int NumHLines { get; private set; }
        public int NumVLines { get; private set; }

       

        public Scope(Control control, uint signalsNumber, float [] amplitude, float time, float samplingFrequency, float gain)
        {
            canvas = control;
            SignalsNumber = signalsNumber;
            Amplitude = amplitude;
            Time = time;
            SamplingFrequency = samplingFrequency;
            NumHLines = 5;
            NumVLines = 10;
            Gain = gain;
            x = 0;
            ClearOnOverrun = true;
            EnabledChannels = new bool[signalsNumber];
            for (int i = 0; i < SignalsNumber; i++)
            {
                EnabledChannels[i] = true;
            }

            state = new Point[SignalsNumber];
            for (int i = 0; i < SignalsNumber; i++)
            {
                state[i] = new Point((int)0, (int)(canvas.Height * 0.5f));
            }

            pens = new List<Pen>() {
                                    new Pen(Color.Yellow,2),
                                    new Pen(Color.Magenta,2),
                                    new Pen(Color.Cyan,2),
                                    new Pen(Color.Red,2),
                                    new Pen(Color.Blue,2)
            };
            BackColor = Color.Black;
            MainGridColor = Color.LightGray;
            SecGridColor = Color.Gray;
        }

        public void AddSignal(List<float> signal,float amplitude, Pen pen, ref Point last)
        {

            Point[] points = new Point[signal.Count + ((x == 0) ? 0 : 1)];

            float width = canvas.Width;
            float height = canvas.Height;
            float dx = width / SamplingFrequency / Time;

            points[0] = last;
            int i = ((x == 0) ? 0 : 1);
            foreach (float valor in signal)
            {
                if (!float.IsNaN(valor))
                    points[i] = new Point((int)x, (int)(height * (0.5f - valor*Gain/ amplitude)));
                else
                    points[i] = new Point((int)x, (int)(height * 0.5f));
                x += dx;

                i++;
            }
            graphics.DrawLines(pen, points);
            last = points[i - 1];
        }


        public virtual void AddSignals(List<List<float>> signals)
        {
            if (delay_status == true && DateTime.Now.Subtract(delay_time).TotalMilliseconds < Delay)
                return;

            delay_status = false;           
            graphics = canvas.CreateGraphics();
            float width = canvas.Width;
            float height = canvas.Height;

            if (signals.Count != SignalsNumber) throw new Exception("The number of signals is wrong! (!= " + SignalsNumber + ")");

            if (x == 0) Clear();

            float x0 = x;
            for (int i = 0; i < SignalsNumber; i++)
            {

                if (EnabledChannels[i])
                {
                    x = x0;
                    AddSignal(signals[i], Amplitude[i], pens[i % pens.Count], ref state[i]);
                }
                    
            }


            if (x > width)
            {
                x = width;
                OnOverrunWidth();
                delay_time = DateTime.Now;
                delay_status = true;
            }

        }

        private void OnOverrunWidth()
        {
            if (ClearOnOverrun)
                x = 0;
        }

        public void DrawSignals(List<List<float>> signals)
        {
            x = 0;
            AddSignals(signals);
        }

        public void PlotXY()
        {
            //TODO
        }

        public void Clear()
        {
            graphics = canvas.CreateGraphics();
            float width = canvas.Width;
            float height = canvas.Height;

            graphics.Clear(BackColor);
            /* preparar pantalla con divisiones */

            Pen pen1 = new Pen(MainGridColor, 1.75f);
            Pen pen2 = new Pen(SecGridColor, 0.75f);
            float pasoH = height / NumHLines;
            float pasoV = width / NumVLines;

            for (int j = 0; j < NumHLines; j++)
            {
                graphics.DrawLine(pen1, 0, pasoH * j, width, pasoH * j);
                for (int jj = 1; jj < 5; jj++)
                    graphics.DrawLine(pen2, 0, pasoH * j + jj * pasoH / 5.0f, width, pasoH * j + jj * pasoH / 5.0f);
            }
            for (int j = 0; j < NumVLines; j++)
            {
                graphics.DrawLine(pen1, pasoV * j, 0, pasoV * j, height);
                for (int jj = 1; jj < 5; jj++)
                    graphics.DrawLine(pen2, pasoV * j + jj * pasoV / 5.0f, 0, pasoV * j + jj * pasoV / 5.0f, height);
            }

        }


    }
    
    class BufferedScope : Scope
    {
        List<List<float>> signalsBuffer;

        public bool DrawingMemory { get; set; }

        public List<List<float>> Buffer { get { return signalsBuffer; } }

        public BufferedScope(Control control, uint signalsNumber, float [] amplitude, float time, float samplingFrequency, float gain) : base(control, signalsNumber, amplitude, time, samplingFrequency, gain)
        {
            signalsBuffer = new List<List<float>>();
            for (int i = 0; i < SignalsNumber; i++)
                signalsBuffer.Add(new List<float>());
        }

        public void ClearBuffers()
        {
            foreach (List<float> buffer in signalsBuffer)
                buffer.Clear();
        }

        public override void AddSignals(List<List<float>> signals)
        {
            for(int i=0; i<SignalsNumber;i++)
                signalsBuffer[i].AddRange(signals[i]);
            if(!DrawingMemory)
                base.AddSignals(signals);
        }

        public void PlotFromMemory(float t0, float timeRange)
        {
            
            float tempTime = Time;
            Time = timeRange;
            try
            {
                int n0 = (int)(t0 * SamplingFrequency);
                int nsamples = (int)(timeRange * SamplingFrequency);
                List<List<float>> signals = new List<List<float>>();
                foreach (List<float> buffer in signalsBuffer)
                {
                    signals.Add(buffer.GetRange(n0, nsamples));
                }
                x = 0;
                base.AddSignals(signals);
            }
            catch { }
            Time = tempTime;
        }


    }

}

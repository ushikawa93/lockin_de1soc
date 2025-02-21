using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace LIA_GUI_1
{
    public partial class Form1 : Form
    {
        // Parametros reconfigurables
        //.parameter_out_0				(fuente_procesamiento), -> 0 adc_2308 // 1 adc_hs // 2 simulacion
        //.parameter_out_1				(M),
        //.parameter_out_2				(N_ma),
        //.parameter_out_3				(N_ca),
        //.parameter_out_4				(sim_noise),
        //.parameter_out_9				(led_test),

        FPGA fpga;
        long X, Y;
        int N_ma, N_ca, M;


        public Form1()
        {
            InitializeComponent();
            fpga = new FPGA();
            fuente_box.SelectedIndex = 0;
            configure();
        }       

        private void iniciar_boton_Click(object sender, EventArgs e)
        {
            configure();
            fpga.Toggle_led();
            fpga.Reset();
            fpga.Start();

            X = fpga.get_result_64(FPGA.FIFO_DIRECTION.F0_64);
            Y = fpga.get_result_64(FPGA.FIFO_DIRECTION.F1_64);

            Lockin_results lia_results = new Lockin_results(X, Y, N_ma * N_ca * M);

            X_text.Text = X.ToString();
            Y_text.Text = Y.ToString();
            R_text.Text = lia_results.R.ToString("F4");
            phi_text.Text = lia_results.Phi.ToString("F4");

        }

        private void Boton_cerrar_Click(object sender, EventArgs e)
        {
            fpga.Terminate();
            this.Close();
        }

        private void configure()
        {
            int fuente = (fuente_box.SelectedIndex == 0) ? 1 : ((fuente_box.SelectedIndex == 1) ? 2 : 0);
            N_ma = int.Parse(N_ma_box.Text);
            N_ca = int.Parse(N_ca_box.Text);
            M = int.Parse(M_box.Text);

            fpga.set_lockin_frec(int.Parse(frec_box.Text),M);
            fpga.set_param(0, fuente);
            fpga.set_param(1, M);
            fpga.set_param(2, N_ma);
            fpga.set_param(3, N_ca);
            fpga.set_param(4, int.Parse(ruido_box.Text));

           

        }
    }
}

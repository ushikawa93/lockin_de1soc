using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using plot;

namespace FIR_GUI
{
    public partial class FIR_demo : Form
    {
        FPGA fpga;
        int f_muestreo;
        BancoFiltros filtros;
        int index_filtro_actual;
        bool f_muestreo_changed;
        bool block_plot_modifiers;

        BufferedScope plotter;

        int Nplot = 64;
        float MaxAmplitudPlot = 8192 * 2;
        float plot_offset;


        public FIR_demo()
        {
            InitializeComponent();
            Update_fmuestreo();
            filtros = new BancoFiltros(f_muestreo);

            fpga = new FPGA();

            if (f_muestreo_changed)
            {
                fpga.set_clk(f_muestreo);
                f_muestreo_changed = false;
            }

            // Actualizo la lista...
            Update_list();

            // Para plot
            block_plot_modifiers = false;
            plot_offset = MaxAmplitudPlot / 2;


        }

        private void Iniciar_button_Click(object sender, EventArgs e)
        {
            timer_plot.Stop();
            if (f_muestreo_changed) 
            { 
                fpga.set_clk(f_muestreo); 
                f_muestreo_changed = false; 
            }
            fpga.setFilter_to_FPGA(filtros.getFiltro(index_filtro_actual, getTipoFiltroActual()));
            fpga.Reset();
            fpga.Start();
            fpga.Toggle_led();
            timer_plot.Start();


            Iniciar_button.Text = "Refresh";
        }


        private void finalizar_button_Click(object sender, EventArgs e)
        {
            timer_plot.Stop();
            fpga.Reset();
            fpga.Toggle_led();
            Iniciar_button.Text = "Start";

        }

        private void frec_muestreo_ok_Click(object sender, EventArgs e)
        {
            Update_fmuestreo();
            filtros.F_muestreo = f_muestreo;
            Update_list();
        }

        private void exit_button_Click(object sender, EventArgs e)
        {
            fpga.Reset();
            fpga.Terminate();
            timer_plot.Stop();
            this.Close();
        }

        private Filtro.TIPOS_FILTRO getTipoFiltroActual()
        {
            if (button_PB.Checked) { return Filtro.TIPOS_FILTRO.PB; }
            if (button_PA.Checked) { return Filtro.TIPOS_FILTRO.PA; }
            if (button_bypass.Checked) { return Filtro.TIPOS_FILTRO.BYPASS; }
            else return Filtro.TIPOS_FILTRO.PB;
        }

        private void FIR_demo_FormClosed(object sender, FormClosedEventArgs e)
        {
            timer_plot.Stop();
            fpga.Reset();
            fpga.Terminate();
        }

        private void Update_fmuestreo()
        {
            try
            {
                f_muestreo = int.Parse(f_muestreo_textbox.Text);
            }
            catch (Exception e)
            {
                f_muestreo_textbox.Text = "1000";
                f_muestreo = int.Parse(f_muestreo_textbox.Text);
            }
            f_muestreo_changed = true;
        }

        private void Update_list()
        {
            checkedListBox_filtros.Items.Clear();
            if (getTipoFiltroActual() == Filtro.TIPOS_FILTRO.PB)
            {
                foreach (Filtro f in filtros.Filtros_PB)
                {
                    checkedListBox_filtros.Items.Add(f.ToString());
                }
            }
            if (getTipoFiltroActual() == Filtro.TIPOS_FILTRO.PA)
            {
                foreach (Filtro f in filtros.Filtros_PA)
                {
                    checkedListBox_filtros.Items.Add(f.ToString());
                }
            }
            if (getTipoFiltroActual() == Filtro.TIPOS_FILTRO.BYPASS)
            {
                foreach (Filtro f in filtros.Bypass)
                {
                    checkedListBox_filtros.Items.Add(f.ToString());
                }
            }
            checkedListBox_filtros.SetItemChecked(0, true);
            index_filtro_actual = 0;
        }

        private void checkedListBox_filtros_SelectedIndexChanged(object sender, EventArgs e)
        {
            for (int ix = 0; ix < checkedListBox_filtros.Items.Count; ++ix)
                if (ix != checkedListBox_filtros.SelectedIndex) checkedListBox_filtros.SetItemChecked(ix, false);

            if(checkedListBox_filtros.SelectedIndex != -1)
            {
                index_filtro_actual = checkedListBox_filtros.SelectedIndex;
            }
            else
            {
                index_filtro_actual = 0;
            }
            

        }

        private void filter_type_changed(object sender, EventArgs e)
        {
            Update_list();
        }


        // ----------- Funciones para plotear ------------- //
        private void timer_plot_Tick(object sender, EventArgs e)
        {
            if (checkBox_plot.Checked)
            {
                block_plot_modifiers = true;
                fpga.Reset();
                fpga.Start();
                List<List<float>> datos = new List<List<float>>();
                uint number_of_signals = 0;
                List<float> amplitudes = new List<float>();

                if (checkBox_plot_raw.Checked)
                {
                    List<int> data_canal1 = fpga.get_from_fifo(FPGA.FIFO_DIRECTION.F0_32, Nplot);
                    List<float> canal1 = new List<float>();
                    foreach (int i in data_canal1)
                    {
                        canal1.Add((float)i - plot_offset);
                    }
                    datos.Add(canal1);
                    number_of_signals++;
                    amplitudes.Add(MaxAmplitudPlot);
                }
                if (checkBox_plot_processed.Checked)
                {
                    List<int> data_canal2 = fpga.get_from_fifo(FPGA.FIFO_DIRECTION.F1_32, Nplot);
                    List<float> canal2 = new List<float>();
                    foreach (int i in data_canal2)
                    {
                        canal2.Add((float)i - plot_offset);
                    }
                    datos.Add(canal2);
                    number_of_signals++;
                    amplitudes.Add(MaxAmplitudPlot);
                }
                if (number_of_signals > 0)
                {
                    plotter = new BufferedScope(plot_panel, number_of_signals, amplitudes.ToArray(), Nplot - 1, 1, 1);
                    plotter.AddSignals(datos);
                }
                block_plot_modifiers = false;

            }


        }

        private void button_time_down_Click(object sender, EventArgs e)
        {
            if ((Nplot == 128) && (!block_plot_modifiers))
            {
                Nplot = 64;
            }

        }

        private void button_tension_down_Click(object sender, EventArgs e)
        {
            if ((MaxAmplitudPlot == 8192 * 2) && (!block_plot_modifiers))
            {
                MaxAmplitudPlot = 8192;
                plot_offset = MaxAmplitudPlot;
            }

        }

        private void button_time_up_Click(object sender, EventArgs e)
        {
            if ((Nplot == 64) && (!block_plot_modifiers))
            {
                Nplot = 128;
            }

        }

        private void button_tension_up_Click(object sender, EventArgs e)
        {
            if ((MaxAmplitudPlot == 8192) && (!block_plot_modifiers))
            {
                MaxAmplitudPlot = 8192 * 2;
                plot_offset = MaxAmplitudPlot / 2;
            }

        }

    }
}

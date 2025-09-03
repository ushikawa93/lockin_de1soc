
namespace FIR_GUI
{
    partial class FIR_demo
    {
        /// <summary>
        /// Variable del diseñador necesaria.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Limpiar los recursos que se estén usando.
        /// </summary>
        /// <param name="disposing">true si los recursos administrados se deben desechar; false en caso contrario.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Código generado por el Diseñador de Windows Forms

        /// <summary>
        /// Método necesario para admitir el Diseñador. No se puede modificar
        /// el contenido de este método con el editor de código.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.tableLayoutPanel_fmuestreo = new System.Windows.Forms.TableLayoutPanel();
            this.Fmuestreo_label = new System.Windows.Forms.Label();
            this.tableLayoutPanel4 = new System.Windows.Forms.TableLayoutPanel();
            this.f_muestreo_textbox = new System.Windows.Forms.TextBox();
            this.frec_muestreo_button = new System.Windows.Forms.Button();
            this.tableLayoutPanel_filtro = new System.Windows.Forms.TableLayoutPanel();
            this.Filtro_label = new System.Windows.Forms.Label();
            this.tableLayoutPanel_filtro2 = new System.Windows.Forms.TableLayoutPanel();
            this.Coef_manuales_button = new System.Windows.Forms.Button();
            this.tableLayoutPanel_filtro3 = new System.Windows.Forms.TableLayoutPanel();
            this.checkedListBox_filtros = new System.Windows.Forms.CheckedListBox();
            this.tableLayoutPanel_filtro4 = new System.Windows.Forms.TableLayoutPanel();
            this.groupBox_tipo_filtro = new System.Windows.Forms.GroupBox();
            this.button_bypass = new System.Windows.Forms.RadioButton();
            this.button_PA = new System.Windows.Forms.RadioButton();
            this.button_PB = new System.Windows.Forms.RadioButton();
            this.label_tipo_filtro = new System.Windows.Forms.Label();
            this.tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel();
            this.finalizar_button = new System.Windows.Forms.Button();
            this.Iniciar_button = new System.Windows.Forms.Button();
            this.tableLayoutPanel2 = new System.Windows.Forms.TableLayoutPanel();
            this.plot_panel = new System.Windows.Forms.Panel();
            this.tableLayoutPanel5 = new System.Windows.Forms.TableLayoutPanel();
            this.label3 = new System.Windows.Forms.Label();
            this.button_tension_up = new System.Windows.Forms.Button();
            this.button_time_up = new System.Windows.Forms.Button();
            this.button_tension_down = new System.Windows.Forms.Button();
            this.button_time_down = new System.Windows.Forms.Button();
            this.label2 = new System.Windows.Forms.Label();
            this.tableLayoutPanel3 = new System.Windows.Forms.TableLayoutPanel();
            this.checkBox_plot_processed = new System.Windows.Forms.CheckBox();
            this.checkBox_plot_raw = new System.Windows.Forms.CheckBox();
            this.checkBox_plot = new System.Windows.Forms.CheckBox();
            this.button1 = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.exit_button = new System.Windows.Forms.Button();
            this.timer_plot = new System.Windows.Forms.Timer(this.components);
            this.tableLayoutPanel_fmuestreo.SuspendLayout();
            this.tableLayoutPanel4.SuspendLayout();
            this.tableLayoutPanel_filtro.SuspendLayout();
            this.tableLayoutPanel_filtro2.SuspendLayout();
            this.tableLayoutPanel_filtro3.SuspendLayout();
            this.tableLayoutPanel_filtro4.SuspendLayout();
            this.groupBox_tipo_filtro.SuspendLayout();
            this.tableLayoutPanel1.SuspendLayout();
            this.tableLayoutPanel2.SuspendLayout();
            this.plot_panel.SuspendLayout();
            this.tableLayoutPanel5.SuspendLayout();
            this.tableLayoutPanel3.SuspendLayout();
            this.SuspendLayout();
            // 
            // tableLayoutPanel_fmuestreo
            // 
            this.tableLayoutPanel_fmuestreo.CellBorderStyle = System.Windows.Forms.TableLayoutPanelCellBorderStyle.Single;
            this.tableLayoutPanel_fmuestreo.ColumnCount = 1;
            this.tableLayoutPanel_fmuestreo.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel_fmuestreo.Controls.Add(this.Fmuestreo_label, 0, 0);
            this.tableLayoutPanel_fmuestreo.Controls.Add(this.tableLayoutPanel4, 0, 1);
            this.tableLayoutPanel_fmuestreo.Location = new System.Drawing.Point(44, 352);
            this.tableLayoutPanel_fmuestreo.Name = "tableLayoutPanel_fmuestreo";
            this.tableLayoutPanel_fmuestreo.RowCount = 2;
            this.tableLayoutPanel_fmuestreo.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 30.43478F));
            this.tableLayoutPanel_fmuestreo.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 69.56522F));
            this.tableLayoutPanel_fmuestreo.Size = new System.Drawing.Size(197, 73);
            this.tableLayoutPanel_fmuestreo.TabIndex = 0;
            // 
            // Fmuestreo_label
            // 
            this.Fmuestreo_label.AutoSize = true;
            this.Fmuestreo_label.Dock = System.Windows.Forms.DockStyle.Fill;
            this.Fmuestreo_label.Location = new System.Drawing.Point(4, 1);
            this.Fmuestreo_label.Name = "Fmuestreo_label";
            this.Fmuestreo_label.Size = new System.Drawing.Size(189, 21);
            this.Fmuestreo_label.TabIndex = 0;
            this.Fmuestreo_label.Text = "Sampling frequency [kHz]";
            this.Fmuestreo_label.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // tableLayoutPanel4
            // 
            this.tableLayoutPanel4.ColumnCount = 2;
            this.tableLayoutPanel4.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 71.33758F));
            this.tableLayoutPanel4.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 28.66242F));
            this.tableLayoutPanel4.Controls.Add(this.f_muestreo_textbox, 0, 0);
            this.tableLayoutPanel4.Controls.Add(this.frec_muestreo_button, 1, 0);
            this.tableLayoutPanel4.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel4.Location = new System.Drawing.Point(4, 26);
            this.tableLayoutPanel4.Name = "tableLayoutPanel4";
            this.tableLayoutPanel4.RowCount = 1;
            this.tableLayoutPanel4.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel4.Size = new System.Drawing.Size(189, 43);
            this.tableLayoutPanel4.TabIndex = 1;
            // 
            // f_muestreo_textbox
            // 
            this.f_muestreo_textbox.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.f_muestreo_textbox.Location = new System.Drawing.Point(17, 11);
            this.f_muestreo_textbox.Name = "f_muestreo_textbox";
            this.f_muestreo_textbox.Size = new System.Drawing.Size(100, 20);
            this.f_muestreo_textbox.TabIndex = 1;
            this.f_muestreo_textbox.Text = "10000";
            this.f_muestreo_textbox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            // 
            // frec_muestreo_button
            // 
            this.frec_muestreo_button.Dock = System.Windows.Forms.DockStyle.Fill;
            this.frec_muestreo_button.Location = new System.Drawing.Point(137, 3);
            this.frec_muestreo_button.Name = "frec_muestreo_button";
            this.frec_muestreo_button.Size = new System.Drawing.Size(49, 37);
            this.frec_muestreo_button.TabIndex = 2;
            this.frec_muestreo_button.Text = "OK";
            this.frec_muestreo_button.UseVisualStyleBackColor = true;
            this.frec_muestreo_button.Click += new System.EventHandler(this.frec_muestreo_ok_Click);
            // 
            // tableLayoutPanel_filtro
            // 
            this.tableLayoutPanel_filtro.CellBorderStyle = System.Windows.Forms.TableLayoutPanelCellBorderStyle.Single;
            this.tableLayoutPanel_filtro.ColumnCount = 1;
            this.tableLayoutPanel_filtro.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel_filtro.Controls.Add(this.Filtro_label, 0, 0);
            this.tableLayoutPanel_filtro.Controls.Add(this.tableLayoutPanel_filtro2, 0, 1);
            this.tableLayoutPanel_filtro.Location = new System.Drawing.Point(44, 70);
            this.tableLayoutPanel_filtro.Name = "tableLayoutPanel_filtro";
            this.tableLayoutPanel_filtro.RowCount = 2;
            this.tableLayoutPanel_filtro.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 9.523809F));
            this.tableLayoutPanel_filtro.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 90.47619F));
            this.tableLayoutPanel_filtro.Size = new System.Drawing.Size(380, 276);
            this.tableLayoutPanel_filtro.TabIndex = 1;
            // 
            // Filtro_label
            // 
            this.Filtro_label.AutoSize = true;
            this.Filtro_label.Dock = System.Windows.Forms.DockStyle.Fill;
            this.Filtro_label.Location = new System.Drawing.Point(4, 1);
            this.Filtro_label.Name = "Filtro_label";
            this.Filtro_label.Size = new System.Drawing.Size(372, 26);
            this.Filtro_label.TabIndex = 0;
            this.Filtro_label.Text = "Filter used";
            this.Filtro_label.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // tableLayoutPanel_filtro2
            // 
            this.tableLayoutPanel_filtro2.ColumnCount = 1;
            this.tableLayoutPanel_filtro2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel_filtro2.Controls.Add(this.Coef_manuales_button, 0, 1);
            this.tableLayoutPanel_filtro2.Controls.Add(this.tableLayoutPanel_filtro3, 0, 0);
            this.tableLayoutPanel_filtro2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel_filtro2.Location = new System.Drawing.Point(4, 31);
            this.tableLayoutPanel_filtro2.Name = "tableLayoutPanel_filtro2";
            this.tableLayoutPanel_filtro2.RowCount = 2;
            this.tableLayoutPanel_filtro2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel_filtro2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 42F));
            this.tableLayoutPanel_filtro2.Size = new System.Drawing.Size(372, 241);
            this.tableLayoutPanel_filtro2.TabIndex = 1;
            // 
            // Coef_manuales_button
            // 
            this.Coef_manuales_button.Dock = System.Windows.Forms.DockStyle.Fill;
            this.Coef_manuales_button.Location = new System.Drawing.Point(3, 202);
            this.Coef_manuales_button.Name = "Coef_manuales_button";
            this.Coef_manuales_button.Size = new System.Drawing.Size(366, 36);
            this.Coef_manuales_button.TabIndex = 0;
            this.Coef_manuales_button.Text = "Enter new Filter";
            this.Coef_manuales_button.UseVisualStyleBackColor = true;
            // 
            // tableLayoutPanel_filtro3
            // 
            this.tableLayoutPanel_filtro3.ColumnCount = 2;
            this.tableLayoutPanel_filtro3.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 30.60109F));
            this.tableLayoutPanel_filtro3.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 69.39891F));
            this.tableLayoutPanel_filtro3.Controls.Add(this.checkedListBox_filtros, 1, 0);
            this.tableLayoutPanel_filtro3.Controls.Add(this.tableLayoutPanel_filtro4, 0, 0);
            this.tableLayoutPanel_filtro3.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel_filtro3.Location = new System.Drawing.Point(3, 3);
            this.tableLayoutPanel_filtro3.Name = "tableLayoutPanel_filtro3";
            this.tableLayoutPanel_filtro3.RowCount = 1;
            this.tableLayoutPanel_filtro3.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel_filtro3.Size = new System.Drawing.Size(366, 193);
            this.tableLayoutPanel_filtro3.TabIndex = 1;
            // 
            // checkedListBox_filtros
            // 
            this.checkedListBox_filtros.Dock = System.Windows.Forms.DockStyle.Fill;
            this.checkedListBox_filtros.FormattingEnabled = true;
            this.checkedListBox_filtros.Location = new System.Drawing.Point(115, 3);
            this.checkedListBox_filtros.Name = "checkedListBox_filtros";
            this.checkedListBox_filtros.Size = new System.Drawing.Size(248, 187);
            this.checkedListBox_filtros.TabIndex = 7;
            this.checkedListBox_filtros.SelectedIndexChanged += new System.EventHandler(this.checkedListBox_filtros_SelectedIndexChanged);
            // 
            // tableLayoutPanel_filtro4
            // 
            this.tableLayoutPanel_filtro4.ColumnCount = 1;
            this.tableLayoutPanel_filtro4.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel_filtro4.Controls.Add(this.groupBox_tipo_filtro, 0, 1);
            this.tableLayoutPanel_filtro4.Controls.Add(this.label_tipo_filtro, 0, 0);
            this.tableLayoutPanel_filtro4.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel_filtro4.Location = new System.Drawing.Point(3, 3);
            this.tableLayoutPanel_filtro4.Name = "tableLayoutPanel_filtro4";
            this.tableLayoutPanel_filtro4.RowCount = 2;
            this.tableLayoutPanel_filtro4.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 25F));
            this.tableLayoutPanel_filtro4.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 75F));
            this.tableLayoutPanel_filtro4.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel_filtro4.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel_filtro4.Size = new System.Drawing.Size(106, 187);
            this.tableLayoutPanel_filtro4.TabIndex = 0;
            // 
            // groupBox_tipo_filtro
            // 
            this.groupBox_tipo_filtro.Controls.Add(this.button_bypass);
            this.groupBox_tipo_filtro.Controls.Add(this.button_PA);
            this.groupBox_tipo_filtro.Controls.Add(this.button_PB);
            this.groupBox_tipo_filtro.Dock = System.Windows.Forms.DockStyle.Fill;
            this.groupBox_tipo_filtro.Location = new System.Drawing.Point(3, 49);
            this.groupBox_tipo_filtro.Name = "groupBox_tipo_filtro";
            this.groupBox_tipo_filtro.Size = new System.Drawing.Size(100, 135);
            this.groupBox_tipo_filtro.TabIndex = 2;
            this.groupBox_tipo_filtro.TabStop = false;
            // 
            // button_bypass
            // 
            this.button_bypass.AutoSize = true;
            this.button_bypass.Location = new System.Drawing.Point(6, 56);
            this.button_bypass.Name = "button_bypass";
            this.button_bypass.Size = new System.Drawing.Size(59, 17);
            this.button_bypass.TabIndex = 2;
            this.button_bypass.Text = "Bypass";
            this.button_bypass.UseVisualStyleBackColor = true;
            this.button_bypass.CheckedChanged += new System.EventHandler(this.filter_type_changed);
            // 
            // button_PA
            // 
            this.button_PA.AutoSize = true;
            this.button_PA.Location = new System.Drawing.Point(6, 33);
            this.button_PA.Name = "button_PA";
            this.button_PA.Size = new System.Drawing.Size(73, 17);
            this.button_PA.TabIndex = 1;
            this.button_PA.Text = "High-Pass";
            this.button_PA.UseVisualStyleBackColor = true;
            this.button_PA.CheckedChanged += new System.EventHandler(this.filter_type_changed);
            // 
            // button_PB
            // 
            this.button_PB.AutoSize = true;
            this.button_PB.Checked = true;
            this.button_PB.Location = new System.Drawing.Point(6, 10);
            this.button_PB.Name = "button_PB";
            this.button_PB.Size = new System.Drawing.Size(71, 17);
            this.button_PB.TabIndex = 0;
            this.button_PB.TabStop = true;
            this.button_PB.Text = "Low-Pass";
            this.button_PB.UseVisualStyleBackColor = true;
            this.button_PB.CheckedChanged += new System.EventHandler(this.filter_type_changed);
            // 
            // label_tipo_filtro
            // 
            this.label_tipo_filtro.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.label_tipo_filtro.AutoSize = true;
            this.label_tipo_filtro.Location = new System.Drawing.Point(37, 16);
            this.label_tipo_filtro.Name = "label_tipo_filtro";
            this.label_tipo_filtro.Size = new System.Drawing.Size(31, 13);
            this.label_tipo_filtro.TabIndex = 0;
            this.label_tipo_filtro.Text = "Type";
            // 
            // tableLayoutPanel1
            // 
            this.tableLayoutPanel1.ColumnCount = 2;
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel1.Controls.Add(this.finalizar_button, 1, 0);
            this.tableLayoutPanel1.Controls.Add(this.Iniciar_button, 0, 0);
            this.tableLayoutPanel1.Location = new System.Drawing.Point(298, 378);
            this.tableLayoutPanel1.Name = "tableLayoutPanel1";
            this.tableLayoutPanel1.RowCount = 1;
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel1.Size = new System.Drawing.Size(545, 47);
            this.tableLayoutPanel1.TabIndex = 2;
            // 
            // finalizar_button
            // 
            this.finalizar_button.Dock = System.Windows.Forms.DockStyle.Fill;
            this.finalizar_button.Location = new System.Drawing.Point(275, 3);
            this.finalizar_button.Name = "finalizar_button";
            this.finalizar_button.Size = new System.Drawing.Size(267, 41);
            this.finalizar_button.TabIndex = 3;
            this.finalizar_button.Text = "Stop";
            this.finalizar_button.UseVisualStyleBackColor = true;
            this.finalizar_button.Click += new System.EventHandler(this.finalizar_button_Click);
            // 
            // Iniciar_button
            // 
            this.Iniciar_button.Dock = System.Windows.Forms.DockStyle.Fill;
            this.Iniciar_button.Location = new System.Drawing.Point(3, 3);
            this.Iniciar_button.Name = "Iniciar_button";
            this.Iniciar_button.Size = new System.Drawing.Size(266, 41);
            this.Iniciar_button.TabIndex = 0;
            this.Iniciar_button.Text = "Start";
            this.Iniciar_button.UseVisualStyleBackColor = true;
            this.Iniciar_button.Click += new System.EventHandler(this.Iniciar_button_Click);
            // 
            // tableLayoutPanel2
            // 
            this.tableLayoutPanel2.CellBorderStyle = System.Windows.Forms.TableLayoutPanelCellBorderStyle.Single;
            this.tableLayoutPanel2.ColumnCount = 1;
            this.tableLayoutPanel2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel2.Controls.Add(this.plot_panel, 0, 0);
            this.tableLayoutPanel2.Controls.Add(this.tableLayoutPanel3, 0, 1);
            this.tableLayoutPanel2.Location = new System.Drawing.Point(440, 70);
            this.tableLayoutPanel2.Name = "tableLayoutPanel2";
            this.tableLayoutPanel2.RowCount = 2;
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 90F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 10F));
            this.tableLayoutPanel2.Size = new System.Drawing.Size(403, 297);
            this.tableLayoutPanel2.TabIndex = 3;
            // 
            // plot_panel
            // 
            this.plot_panel.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.plot_panel.Controls.Add(this.tableLayoutPanel5);
            this.plot_panel.Dock = System.Windows.Forms.DockStyle.Fill;
            this.plot_panel.Location = new System.Drawing.Point(4, 4);
            this.plot_panel.Name = "plot_panel";
            this.plot_panel.Size = new System.Drawing.Size(395, 258);
            this.plot_panel.TabIndex = 0;
            // 
            // tableLayoutPanel5
            // 
            this.tableLayoutPanel5.ColumnCount = 3;
            this.tableLayoutPanel5.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 33.33333F));
            this.tableLayoutPanel5.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 33.33333F));
            this.tableLayoutPanel5.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 33.33333F));
            this.tableLayoutPanel5.Controls.Add(this.label3, 1, 1);
            this.tableLayoutPanel5.Controls.Add(this.button_tension_up, 2, 1);
            this.tableLayoutPanel5.Controls.Add(this.button_time_up, 2, 0);
            this.tableLayoutPanel5.Controls.Add(this.button_tension_down, 0, 1);
            this.tableLayoutPanel5.Controls.Add(this.button_time_down, 0, 0);
            this.tableLayoutPanel5.Controls.Add(this.label2, 1, 0);
            this.tableLayoutPanel5.Location = new System.Drawing.Point(271, 190);
            this.tableLayoutPanel5.Name = "tableLayoutPanel5";
            this.tableLayoutPanel5.RowCount = 2;
            this.tableLayoutPanel5.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel5.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel5.Size = new System.Drawing.Size(119, 63);
            this.tableLayoutPanel5.TabIndex = 0;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Dock = System.Windows.Forms.DockStyle.Fill;
            this.label3.Font = new System.Drawing.Font("Microsoft Sans Serif", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label3.Location = new System.Drawing.Point(42, 31);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(33, 32);
            this.label3.TabIndex = 11;
            this.label3.Text = "V";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // button_tension_up
            // 
            this.button_tension_up.Dock = System.Windows.Forms.DockStyle.Fill;
            this.button_tension_up.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.button_tension_up.Location = new System.Drawing.Point(81, 34);
            this.button_tension_up.Name = "button_tension_up";
            this.button_tension_up.Size = new System.Drawing.Size(35, 26);
            this.button_tension_up.TabIndex = 7;
            this.button_tension_up.Text = "+";
            this.button_tension_up.UseVisualStyleBackColor = true;
            this.button_tension_up.Click += new System.EventHandler(this.button_tension_up_Click);
            // 
            // button_time_up
            // 
            this.button_time_up.Dock = System.Windows.Forms.DockStyle.Fill;
            this.button_time_up.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.button_time_up.Location = new System.Drawing.Point(81, 3);
            this.button_time_up.Name = "button_time_up";
            this.button_time_up.Size = new System.Drawing.Size(35, 25);
            this.button_time_up.TabIndex = 8;
            this.button_time_up.Text = "+";
            this.button_time_up.UseVisualStyleBackColor = true;
            this.button_time_up.Click += new System.EventHandler(this.button_time_up_Click);
            // 
            // button_tension_down
            // 
            this.button_tension_down.Dock = System.Windows.Forms.DockStyle.Fill;
            this.button_tension_down.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.button_tension_down.Location = new System.Drawing.Point(3, 34);
            this.button_tension_down.Name = "button_tension_down";
            this.button_tension_down.Size = new System.Drawing.Size(33, 26);
            this.button_tension_down.TabIndex = 9;
            this.button_tension_down.Text = "-";
            this.button_tension_down.UseVisualStyleBackColor = true;
            this.button_tension_down.Click += new System.EventHandler(this.button_tension_down_Click);
            // 
            // button_time_down
            // 
            this.button_time_down.Dock = System.Windows.Forms.DockStyle.Fill;
            this.button_time_down.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.button_time_down.Location = new System.Drawing.Point(3, 3);
            this.button_time_down.Name = "button_time_down";
            this.button_time_down.Size = new System.Drawing.Size(33, 25);
            this.button_time_down.TabIndex = 6;
            this.button_time_down.Text = "-";
            this.button_time_down.UseVisualStyleBackColor = true;
            this.button_time_down.Click += new System.EventHandler(this.button_time_down_Click);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(42, 0);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(33, 31);
            this.label2.TabIndex = 10;
            this.label2.Text = "t";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // tableLayoutPanel3
            // 
            this.tableLayoutPanel3.ColumnCount = 3;
            this.tableLayoutPanel3.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 33.33333F));
            this.tableLayoutPanel3.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 33.33333F));
            this.tableLayoutPanel3.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 33.33333F));
            this.tableLayoutPanel3.Controls.Add(this.checkBox_plot_processed, 2, 0);
            this.tableLayoutPanel3.Controls.Add(this.checkBox_plot_raw, 1, 0);
            this.tableLayoutPanel3.Controls.Add(this.checkBox_plot, 0, 0);
            this.tableLayoutPanel3.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel3.Location = new System.Drawing.Point(4, 269);
            this.tableLayoutPanel3.Name = "tableLayoutPanel3";
            this.tableLayoutPanel3.RowCount = 1;
            this.tableLayoutPanel3.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel3.Size = new System.Drawing.Size(395, 24);
            this.tableLayoutPanel3.TabIndex = 1;
            // 
            // checkBox_plot_processed
            // 
            this.checkBox_plot_processed.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.checkBox_plot_processed.AutoSize = true;
            this.checkBox_plot_processed.Checked = true;
            this.checkBox_plot_processed.CheckState = System.Windows.Forms.CheckState.Checked;
            this.checkBox_plot_processed.Location = new System.Drawing.Point(275, 3);
            this.checkBox_plot_processed.Name = "checkBox_plot_processed";
            this.checkBox_plot_processed.Size = new System.Drawing.Size(106, 17);
            this.checkBox_plot_processed.TabIndex = 1;
            this.checkBox_plot_processed.Text = "Processed signal";
            this.checkBox_plot_processed.UseVisualStyleBackColor = true;
            // 
            // checkBox_plot_raw
            // 
            this.checkBox_plot_raw.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.checkBox_plot_raw.AutoSize = true;
            this.checkBox_plot_raw.Checked = true;
            this.checkBox_plot_raw.CheckState = System.Windows.Forms.CheckState.Checked;
            this.checkBox_plot_raw.Location = new System.Drawing.Point(157, 3);
            this.checkBox_plot_raw.Name = "checkBox_plot_raw";
            this.checkBox_plot_raw.Size = new System.Drawing.Size(78, 17);
            this.checkBox_plot_raw.TabIndex = 0;
            this.checkBox_plot_raw.Text = "Raw signal";
            this.checkBox_plot_raw.UseVisualStyleBackColor = true;
            // 
            // checkBox_plot
            // 
            this.checkBox_plot.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.checkBox_plot.AutoSize = true;
            this.checkBox_plot.Checked = true;
            this.checkBox_plot.CheckState = System.Windows.Forms.CheckState.Checked;
            this.checkBox_plot.Location = new System.Drawing.Point(26, 3);
            this.checkBox_plot.Name = "checkBox_plot";
            this.checkBox_plot.Size = new System.Drawing.Size(79, 17);
            this.checkBox_plot.TabIndex = 2;
            this.checkBox_plot.Text = "Plot signals";
            this.checkBox_plot.UseVisualStyleBackColor = true;
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(568, 178);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(75, 23);
            this.button1.TabIndex = 2;
            this.button1.Text = "button1";
            this.button1.UseVisualStyleBackColor = true;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(282, 19);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(266, 37);
            this.label1.TabIndex = 4;
            this.label1.Text = "FIR Filter DEMO";
            // 
            // exit_button
            // 
            this.exit_button.Location = new System.Drawing.Point(814, 12);
            this.exit_button.Name = "exit_button";
            this.exit_button.Size = new System.Drawing.Size(29, 25);
            this.exit_button.TabIndex = 5;
            this.exit_button.Text = "X";
            this.exit_button.UseVisualStyleBackColor = true;
            this.exit_button.Click += new System.EventHandler(this.exit_button_Click);
            // 
            // timer_plot
            // 
            this.timer_plot.Interval = 1000;
            this.timer_plot.Tick += new System.EventHandler(this.timer_plot_Tick);
            // 
            // FIR_demo
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(855, 437);
            this.Controls.Add(this.exit_button);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.tableLayoutPanel2);
            this.Controls.Add(this.tableLayoutPanel1);
            this.Controls.Add(this.tableLayoutPanel_filtro);
            this.Controls.Add(this.tableLayoutPanel_fmuestreo);
            this.Name = "FIR_demo";
            this.Text = "FIR Filter Demo";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FIR_demo_FormClosed);
            this.tableLayoutPanel_fmuestreo.ResumeLayout(false);
            this.tableLayoutPanel_fmuestreo.PerformLayout();
            this.tableLayoutPanel4.ResumeLayout(false);
            this.tableLayoutPanel4.PerformLayout();
            this.tableLayoutPanel_filtro.ResumeLayout(false);
            this.tableLayoutPanel_filtro.PerformLayout();
            this.tableLayoutPanel_filtro2.ResumeLayout(false);
            this.tableLayoutPanel_filtro3.ResumeLayout(false);
            this.tableLayoutPanel_filtro4.ResumeLayout(false);
            this.tableLayoutPanel_filtro4.PerformLayout();
            this.groupBox_tipo_filtro.ResumeLayout(false);
            this.groupBox_tipo_filtro.PerformLayout();
            this.tableLayoutPanel1.ResumeLayout(false);
            this.tableLayoutPanel2.ResumeLayout(false);
            this.plot_panel.ResumeLayout(false);
            this.tableLayoutPanel5.ResumeLayout(false);
            this.tableLayoutPanel5.PerformLayout();
            this.tableLayoutPanel3.ResumeLayout(false);
            this.tableLayoutPanel3.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel_fmuestreo;
        private System.Windows.Forms.Label Fmuestreo_label;
        private System.Windows.Forms.TextBox f_muestreo_textbox;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel_filtro;
        private System.Windows.Forms.Label Filtro_label;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel_filtro2;
        private System.Windows.Forms.Button Coef_manuales_button;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel_filtro3;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel_filtro4;
        private System.Windows.Forms.Label label_tipo_filtro;
        private System.Windows.Forms.GroupBox groupBox_tipo_filtro;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel1;
        private System.Windows.Forms.Button Iniciar_button;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel2;
        private System.Windows.Forms.Panel plot_panel;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel3;
        private System.Windows.Forms.CheckBox checkBox_plot_processed;
        private System.Windows.Forms.CheckBox checkBox_plot_raw;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.RadioButton button_bypass;
        private System.Windows.Forms.RadioButton button_PA;
        private System.Windows.Forms.RadioButton button_PB;
        private System.Windows.Forms.Button finalizar_button;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel4;
        private System.Windows.Forms.Button frec_muestreo_button;
        private System.Windows.Forms.Button exit_button;
        private System.Windows.Forms.Timer timer_plot;
        private System.Windows.Forms.CheckBox checkBox_plot;
        private System.Windows.Forms.Button button_time_down;
        private System.Windows.Forms.Button button_tension_up;
        private System.Windows.Forms.Button button_time_up;
        private System.Windows.Forms.Button button_tension_down;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel5;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.CheckedListBox checkedListBox_filtros;
    }
}


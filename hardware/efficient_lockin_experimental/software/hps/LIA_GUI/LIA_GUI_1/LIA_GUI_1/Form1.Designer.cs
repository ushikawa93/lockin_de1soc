namespace LIA_GUI_1
{
    partial class Form1
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
            this.iniciar_boton = new System.Windows.Forms.Button();
            this.tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel();
            this.label4 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.X_text = new System.Windows.Forms.Label();
            this.Y_text = new System.Windows.Forms.Label();
            this.R_text = new System.Windows.Forms.Label();
            this.phi_text = new System.Windows.Forms.Label();
            this.Boton_cerrar = new System.Windows.Forms.Button();
            this.tableLayoutPanel2 = new System.Windows.Forms.TableLayoutPanel();
            this.label5 = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.label7 = new System.Windows.Forms.Label();
            this.label8 = new System.Windows.Forms.Label();
            this.label9 = new System.Windows.Forms.Label();
            this.label10 = new System.Windows.Forms.Label();
            this.frec_box = new System.Windows.Forms.TextBox();
            this.M_box = new System.Windows.Forms.TextBox();
            this.N_ca_box = new System.Windows.Forms.TextBox();
            this.N_ma_box = new System.Windows.Forms.TextBox();
            this.ruido_box = new System.Windows.Forms.TextBox();
            this.fuente_box = new System.Windows.Forms.ComboBox();
            this.tableLayoutPanel1.SuspendLayout();
            this.tableLayoutPanel2.SuspendLayout();
            this.SuspendLayout();
            // 
            // iniciar_boton
            // 
            this.iniciar_boton.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.iniciar_boton.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.iniciar_boton.Location = new System.Drawing.Point(310, 31);
            this.iniciar_boton.Name = "iniciar_boton";
            this.iniciar_boton.Size = new System.Drawing.Size(102, 45);
            this.iniciar_boton.TabIndex = 0;
            this.iniciar_boton.Text = "Iniciar";
            this.iniciar_boton.UseVisualStyleBackColor = true;
            this.iniciar_boton.Click += new System.EventHandler(this.iniciar_boton_Click);
            // 
            // tableLayoutPanel1
            // 
            this.tableLayoutPanel1.CellBorderStyle = System.Windows.Forms.TableLayoutPanelCellBorderStyle.InsetDouble;
            this.tableLayoutPanel1.ColumnCount = 2;
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel1.Controls.Add(this.label4, 0, 3);
            this.tableLayoutPanel1.Controls.Add(this.label1, 0, 0);
            this.tableLayoutPanel1.Controls.Add(this.label2, 0, 1);
            this.tableLayoutPanel1.Controls.Add(this.label3, 0, 2);
            this.tableLayoutPanel1.Controls.Add(this.X_text, 1, 0);
            this.tableLayoutPanel1.Controls.Add(this.Y_text, 1, 1);
            this.tableLayoutPanel1.Controls.Add(this.R_text, 1, 2);
            this.tableLayoutPanel1.Controls.Add(this.phi_text, 1, 3);
            this.tableLayoutPanel1.Location = new System.Drawing.Point(266, 93);
            this.tableLayoutPanel1.Name = "tableLayoutPanel1";
            this.tableLayoutPanel1.RowCount = 4;
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 25F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 25F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 25F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 25F));
            this.tableLayoutPanel1.Size = new System.Drawing.Size(245, 232);
            this.tableLayoutPanel1.TabIndex = 1;
            // 
            // label4
            // 
            this.label4.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.label4.AutoSize = true;
            this.label4.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label4.Location = new System.Drawing.Point(46, 191);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(31, 20);
            this.label4.TabIndex = 6;
            this.label4.Text = "Phi";
            // 
            // label1
            // 
            this.label1.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(52, 20);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(20, 20);
            this.label1.TabIndex = 0;
            this.label1.Text = "X";
            // 
            // label2
            // 
            this.label2.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(52, 77);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(20, 20);
            this.label2.TabIndex = 1;
            this.label2.Text = "Y";
            // 
            // label3
            // 
            this.label3.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.label3.AutoSize = true;
            this.label3.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label3.Location = new System.Drawing.Point(51, 134);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(21, 20);
            this.label3.TabIndex = 2;
            this.label3.Text = "R";
            // 
            // X_text
            // 
            this.X_text.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.X_text.AutoSize = true;
            this.X_text.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.X_text.Location = new System.Drawing.Point(183, 20);
            this.X_text.Name = "X_text";
            this.X_text.Size = new System.Drawing.Size(0, 20);
            this.X_text.TabIndex = 3;
            // 
            // Y_text
            // 
            this.Y_text.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.Y_text.AutoSize = true;
            this.Y_text.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Y_text.Location = new System.Drawing.Point(183, 77);
            this.Y_text.Name = "Y_text";
            this.Y_text.Size = new System.Drawing.Size(0, 20);
            this.Y_text.TabIndex = 4;
            // 
            // R_text
            // 
            this.R_text.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.R_text.AutoSize = true;
            this.R_text.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.R_text.Location = new System.Drawing.Point(183, 134);
            this.R_text.Name = "R_text";
            this.R_text.Size = new System.Drawing.Size(0, 20);
            this.R_text.TabIndex = 5;
            this.R_text.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // phi_text
            // 
            this.phi_text.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.phi_text.AutoSize = true;
            this.phi_text.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.phi_text.Location = new System.Drawing.Point(183, 191);
            this.phi_text.Name = "phi_text";
            this.phi_text.Size = new System.Drawing.Size(0, 20);
            this.phi_text.TabIndex = 7;
            this.phi_text.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // Boton_cerrar
            // 
            this.Boton_cerrar.Font = new System.Drawing.Font("Microsoft Sans Serif", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Boton_cerrar.Location = new System.Drawing.Point(509, 12);
            this.Boton_cerrar.Name = "Boton_cerrar";
            this.Boton_cerrar.Size = new System.Drawing.Size(24, 26);
            this.Boton_cerrar.TabIndex = 2;
            this.Boton_cerrar.Text = "X";
            this.Boton_cerrar.UseVisualStyleBackColor = true;
            this.Boton_cerrar.Click += new System.EventHandler(this.Boton_cerrar_Click);
            // 
            // tableLayoutPanel2
            // 
            this.tableLayoutPanel2.ColumnCount = 2;
            this.tableLayoutPanel2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel2.Controls.Add(this.label5, 0, 0);
            this.tableLayoutPanel2.Controls.Add(this.label6, 0, 1);
            this.tableLayoutPanel2.Controls.Add(this.label7, 0, 2);
            this.tableLayoutPanel2.Controls.Add(this.label8, 0, 3);
            this.tableLayoutPanel2.Controls.Add(this.label9, 0, 4);
            this.tableLayoutPanel2.Controls.Add(this.label10, 0, 5);
            this.tableLayoutPanel2.Controls.Add(this.frec_box, 1, 1);
            this.tableLayoutPanel2.Controls.Add(this.M_box, 1, 2);
            this.tableLayoutPanel2.Controls.Add(this.N_ca_box, 1, 3);
            this.tableLayoutPanel2.Controls.Add(this.N_ma_box, 1, 4);
            this.tableLayoutPanel2.Controls.Add(this.ruido_box, 1, 5);
            this.tableLayoutPanel2.Controls.Add(this.fuente_box, 1, 0);
            this.tableLayoutPanel2.Location = new System.Drawing.Point(26, 31);
            this.tableLayoutPanel2.Name = "tableLayoutPanel2";
            this.tableLayoutPanel2.RowCount = 6;
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66667F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66667F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66667F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66667F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66667F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66667F));
            this.tableLayoutPanel2.Size = new System.Drawing.Size(200, 294);
            this.tableLayoutPanel2.TabIndex = 3;
            // 
            // label5
            // 
            this.label5.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.label5.AutoSize = true;
            this.label5.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label5.Location = new System.Drawing.Point(26, 16);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(48, 16);
            this.label5.TabIndex = 0;
            this.label5.Text = "Fuente";
            this.label5.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label6
            // 
            this.label6.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.label6.AutoSize = true;
            this.label6.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label6.Location = new System.Drawing.Point(13, 65);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(74, 16);
            this.label6.TabIndex = 1;
            this.label6.Text = "Frecuencia";
            this.label6.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label7
            // 
            this.label7.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.label7.AutoSize = true;
            this.label7.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label7.Location = new System.Drawing.Point(41, 114);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(18, 16);
            this.label7.TabIndex = 2;
            this.label7.Text = "M";
            this.label7.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label8
            // 
            this.label8.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.label8.AutoSize = true;
            this.label8.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label8.Location = new System.Drawing.Point(30, 163);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(39, 16);
            this.label8.TabIndex = 3;
            this.label8.Text = "N_ca";
            this.label8.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label9
            // 
            this.label9.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.label9.AutoSize = true;
            this.label9.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label9.Location = new System.Drawing.Point(28, 212);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(43, 16);
            this.label9.TabIndex = 4;
            this.label9.Text = "N_ma";
            this.label9.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label10
            // 
            this.label10.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.label10.AutoSize = true;
            this.label10.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label10.Location = new System.Drawing.Point(10, 253);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(79, 32);
            this.label10.TabIndex = 5;
            this.label10.Text = "Ruido (simulacion)";
            this.label10.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // frec_box
            // 
            this.frec_box.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.frec_box.Location = new System.Drawing.Point(103, 63);
            this.frec_box.Name = "frec_box";
            this.frec_box.Size = new System.Drawing.Size(94, 20);
            this.frec_box.TabIndex = 6;
            this.frec_box.Text = "1000";
            this.frec_box.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            // 
            // M_box
            // 
            this.M_box.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.M_box.Location = new System.Drawing.Point(103, 112);
            this.M_box.Name = "M_box";
            this.M_box.Size = new System.Drawing.Size(94, 20);
            this.M_box.TabIndex = 7;
            this.M_box.Text = "32";
            this.M_box.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            // 
            // N_ca_box
            // 
            this.N_ca_box.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.N_ca_box.Location = new System.Drawing.Point(103, 161);
            this.N_ca_box.Name = "N_ca_box";
            this.N_ca_box.Size = new System.Drawing.Size(94, 20);
            this.N_ca_box.TabIndex = 8;
            this.N_ca_box.Text = "16";
            this.N_ca_box.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            // 
            // N_ma_box
            // 
            this.N_ma_box.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.N_ma_box.Location = new System.Drawing.Point(103, 210);
            this.N_ma_box.Name = "N_ma_box";
            this.N_ma_box.Size = new System.Drawing.Size(94, 20);
            this.N_ma_box.TabIndex = 9;
            this.N_ma_box.Text = "1";
            this.N_ma_box.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            // 
            // ruido_box
            // 
            this.ruido_box.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.ruido_box.Location = new System.Drawing.Point(103, 259);
            this.ruido_box.Name = "ruido_box";
            this.ruido_box.Size = new System.Drawing.Size(94, 20);
            this.ruido_box.TabIndex = 10;
            this.ruido_box.Text = "0";
            this.ruido_box.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            // 
            // fuente_box
            // 
            this.fuente_box.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.fuente_box.FormattingEnabled = true;
            this.fuente_box.Items.AddRange(new object[] {
            "ADC HS",
            "Simulacion",
            "ADC 2308"});
            this.fuente_box.Location = new System.Drawing.Point(103, 14);
            this.fuente_box.Name = "fuente_box";
            this.fuente_box.Size = new System.Drawing.Size(94, 21);
            this.fuente_box.TabIndex = 11;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(545, 342);
            this.Controls.Add(this.tableLayoutPanel2);
            this.Controls.Add(this.Boton_cerrar);
            this.Controls.Add(this.tableLayoutPanel1);
            this.Controls.Add(this.iniciar_boton);
            this.Name = "Form1";
            this.Text = "Lock In";
            this.tableLayoutPanel1.ResumeLayout(false);
            this.tableLayoutPanel1.PerformLayout();
            this.tableLayoutPanel2.ResumeLayout(false);
            this.tableLayoutPanel2.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button iniciar_boton;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label X_text;
        private System.Windows.Forms.Label Y_text;
        private System.Windows.Forms.Label R_text;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label phi_text;
        private System.Windows.Forms.Button Boton_cerrar;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel2;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.Label label10;
        private System.Windows.Forms.TextBox frec_box;
        private System.Windows.Forms.TextBox M_box;
        private System.Windows.Forms.TextBox N_ca_box;
        private System.Windows.Forms.TextBox N_ma_box;
        private System.Windows.Forms.TextBox ruido_box;
        private System.Windows.Forms.ComboBox fuente_box;
    }
}


///// ================================================================================= /////
///// ============================ Servidor Lockin ==================================== /////
///// ================================================================================= /////


 /////// ====================== Variables generales ================================== /////	
const http = require('http');
var execFile = require('child_process').execFile;

const url = require('url');
const fs = require('fs');

var nombre_archivo_lockin = "/var/www/html/lockin/test_web.dat";
var nombre_archivo_adc = "/var/www/html/lockin/adc_web.dat"
var nombre_archivo_barrido = "/var/www/html/lockin/barrido_web.dat"
var nombre_archivo_ruido = "/var/www/html/lockin/barrido_ruido_web.dat"
var nombre_archivo_dep = "/var/www/html/lockin/dep_web.dat"

// Lockin y ADC
var noise = 5;
var N = 1;
var frecuencia = 100000;
var fuente = 2;
var modo = 1;
var frec_clk = 20;
var ciclos2display = 2;
var corregir_fase = 1;
var modo_referencias = 0;
var M = 32;

// Barrido en frecuencia
var f_inicial = 100000;
var f_final = 1000000
var f_step = 100000;

// Barrido de ruido
var N_inicial = 1;
var N_final = 32;
var iteraciones = 100; 

// DEP
var f_dac = 10000;

var buttonPressCount = 0; 



///// ================================================================================= /////
///// ============================ Creo el servidor ==================================== /////
///// ================================================================================= /////

const server = http.createServer(function (req, res) {

    req.setTimeout(3600000);

    // Configura los encabezados CORS para permitir solicitudes desde cualquier origen
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET');
    res.setHeader('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');

    const parsedUrl = url.parse(req.url, true); // Parsear la URL para obtener los parámetros
    const queryObject = parsedUrl.query; // Obtener los parámetros de la URL


    ///// ================================================================================= /////
    ///// =================== Solicitud iniciar_lockin ==================================== /////
    ///// ================================================================================= /////


    if (parsedUrl.pathname === '/iniciar_lockin' ) {
        console.log('Calculando...');

        // Obtener los valores de los parámetros de la solicitud
        noise = queryObject.noise;
        N = queryObject.N;
        frecuencia = queryObject.frecuencia;
        fuente = queryObject.fuente;
        modo = queryObject.modo;
        frec_clk = queryObject.f_clk;
        corregir_fase = queryObject.corregir_fase;
        M = queryObject.M;
        modo_referencias = queryObject.modo_referencias;

        // Ejecutar el comando para activar/desactivar el LED con los valores de los parámetros
        execFile("/root/Documents/de1soc_sw/cpp/measure_lockin/measure_li", [
            noise, 
            N, 
            frecuencia, 
            fuente, 
            modo, 
            nombre_archivo_lockin,
            frec_clk,
            corregir_fase,
            M,
            modo_referencias], 
            
            function (error, stdout, stderr) {
            if (error) {
                console.error('Error al ejecutar el comando:', error);
                res.statusCode = 500;
                res.end('Internal Server Error');
            } else {
                // Leer el contenido del archivo test_web.dat línea por línea
                fs.readFile(nombre_archivo_lockin, 'utf8', (err, data) => {
                    if (err) {
                        console.error('Error al leer el archivo:', err);
                        res.statusCode = 500;
                        res.end('Internal Server Error');
                    } else {
                        // Parsear cada línea del archivo y enviar como respuesta al cliente
                        const lines = data.split('\n');
                        const response = {};

                        lines.forEach(line => {
                            const parts = line.trim().split('=');
                            if (parts.length === 2) {
                                const key = parts[0].trim();
                                const value = parseFloat(parts[1].trim());
                                response[key] = value;
                            }
                        });

                        // Enviar la respuesta como JSON al cliente
                        res.setHeader('Content-Type', 'application/json');
                        res.end(JSON.stringify(response));
                    }
                });
            }
        });
    }        




    ///// ============================================================================ /////
    ///// =================== Solicitud datos_adc ==================================== /////
    ///// ============================================================================ /////

    else if (parsedUrl.pathname === '/datos_adc'){        

        // ./adquirir $sim_noise $N $frecuencia $ciclos2display $nombre_archivo 
        frecuencia = queryObject.frec;
        ciclos2display = queryObject.ciclos2display;
        frec_clk = queryObject.f_clk;        
        fuente = queryObject.fuente; 
        noise = queryObject.noise;
        N = queryObject.N;
        M = queryObject.M;
        modo_referencias = queryObject.modo_referencias;


        execFile("/root/Documents/de1soc_sw/cpp/adquirir2/adquirir2", [             
            N, 
            frecuencia, 
            ciclos2display, 
            nombre_archivo_adc,
            noise,
            frec_clk,
            fuente,
            M,
            modo_referencias], 
            
            function (error, stdout, stderr) {
            if (error) {
                console.error('Error al ejecutar el comando:', error);
                res.statusCode = 500;
                res.end('Internal Server Error');
            } else {
                // Leer el contenido del archivo test_web.dat línea por línea
                fs.readFile(nombre_archivo_adc, 'utf8', (err, data) => {
                    if (err) {
                        console.error('Error al leer el archivo:', err);
                        res.statusCode = 500;
                        res.end('Internal Server Error');
                    } else {

                        const lines = data.split('\n');

                        // Verificar si hay al menos dos líneas en el archivo
                        if (lines.length >= 2) {
                            // Obtener los datos de la primera línea
                            const data1 = lines[0].split(',');
                            
                            // Obtener los datos de la segunda línea
                            const data2 = lines[1].split(',');
                                                
                            // Enviar la respuesta como JSON al cliente
                            res.setHeader('Content-Type', 'application/json');
                            res.end(JSON.stringify({ data1 , data2 }));  
                    } 
                    }
                });
            }
        });
          
    } 



    ///// ================================================================================= /////
    ///// =================== Solicitud barrido_lockin ==================================== /////
    ///// ================================================================================= /////

    else if (parsedUrl.pathname === '/barrido_lockin'){        

        f_clk = queryObject.f_clk;  
        N = queryObject.N;
        fuente = queryObject.fuente;
        modo = queryObject.modo;
        f_inicial = queryObject.f_inicial;
        f_final = queryObject.f_final;
        f_step = queryObject.f_step;
        corregir_fase = queryObject.corregir_fase;
        noise = queryObject.noise;
        M = queryObject.M;
        modo_referencias = queryObject.modo_referencias;

    
        execFile("/root/Documents/de1soc_sw/cpp/barrido_en_f/barrido_f", [
            f_clk, 
            N, 
            fuente, 
            modo, 
            f_inicial, 
            f_final,
            f_step,
            nombre_archivo_barrido,
            corregir_fase,
            noise,
            M,
            modo_referencias], (error, stdout, stderr) => {
                if (error) {
                    console.error('Error al ejecutar el programa:', error);
                    res.statusCode = 500;
                    res.end('Internal Server Error');
                    return;
                }
                
                // Si el programa se ejecuta correctamente, leer el archivo
                fs.readFile(nombre_archivo_barrido, 'utf8', (err, data) => {
                    if (err) {
                        console.error('Error al leer el archivo:', err);
                        res.statusCode = 500;
                        res.end('Internal Server Error');
                    } else {
                        // Si se lee correctamente, responde con el contenido del archivo
                        res.writeHead(200, {'Content-Type': 'text/plain'});
                        res.end(data);
                    }
                });
            }
        );
    }


    
    ///// ================================================================================= /////
    ///// =================== Solicitud barrido_ruido ==================================== /////
    ///// ================================================================================= /////
    
    else if (parsedUrl.pathname === '/barrido_ruido') 
    {
    
        frecuencia = queryObject.frecuencia;
        N_inicial = queryObject.N_inicial;
        N_final = queryObject.N_final;
        iteraciones = queryObject.iteraciones;
        fuente = queryObject.fuente;
        noise = queryObject.noise;   
        frec_clk = queryObject.f_clk;
        M = queryObject.M;
        modo_referencias = queryObject.modo_referencias;
           
        execFile("/root/Documents/de1soc_sw/cpp/barrido_cte_tiempo/barrido_cte_tiempo", [
            frecuencia,
            N_inicial,
            N_final,
            iteraciones,
            fuente,
            noise,
            nombre_archivo_ruido,
            frec_clk,
            M,
            modo_referencias
        ], (error, stdout, stderr) => {
            console.log(stdout);
            if (error) {
                console.error('Error al ejecutar el programa:', error);
                res.statusCode = 500;
                res.end('Internal Server Error');
                return;
            }
    
            // Si el programa se ejecuta correctamente, leer el archivo
            fs.readFile(nombre_archivo_ruido, 'utf8', (err, data) => {
                if (err) {
                    console.error('Error al leer el archivo:', err);
                    res.statusCode = 500;
                    res.end('Internal Server Error');
                } else {
                    // Si se lee correctamente, responde con el contenido del archivo
                    res.writeHead(200, { 'Content-Type': 'text/plain' });
                    res.end(data);
                }
            });
        });   

    }



    ///// ================================================================================= /////
    ///// =================== Solicitud calcular_dep ==================================== /////
    ///// ================================================================================= /////

    else if (parsedUrl.pathname === '/calcular_dep') {
    
        // Uso calcular_dep f_clk N fuente f_dac f_inicial f_final f_step nombre_archivo iteraciones sim_noise

        frec_clk = queryObject.f_clk;
        N = queryObject.N;
        fuente = queryObject.fuente;
        f_dac = queryObject.f_dac;
        f_inicial = queryObject.f_inicial;
        f_final = queryObject.f_final;
        f_step = queryObject.f_step;
        iteraciones = queryObject.iteraciones;
        noise = queryObject.noise;       
        M = queryObject.M;
        modo_referencias = queryObject.modo_referencias;


           
        execFile("/root/Documents/de1soc_sw/cpp/calcular_dep/calcular_dep", [
            frec_clk,
            N,
            fuente,
            f_dac,
            f_inicial,
            f_final,
            f_step,
            nombre_archivo_dep,
            iteraciones,
            noise,
            M,
            modo_referencias
        ], (error, stdout, stderr) => {
            console.log(stdout);
            if (error) {
                console.error('Error al ejecutar el programa:', error);
                res.statusCode = 500;
                res.end('Internal Server Error');
                return;
            }
    
            // Si el programa se ejecuta correctamente, leer el archivo
            fs.readFile(nombre_archivo_dep, 'utf8', (err, data) => {
                if (err) {
                    console.error('Error al leer el archivo:', err);
                    res.statusCode = 500;
                    res.end('Internal Server Error');
                } else {
                    // Si se lee correctamente, responde con el contenido del archivo
                    res.writeHead(200, { 'Content-Type': 'text/plain' });
                    res.end(data);
                }
            });
        });
    }


    ///// ================================================================================= /////
    ///// =========================== Solicitud toggle ==================================== /////
    ///// ================================================================================= /////

    else if (parsedUrl.pathname === '/toggle' && queryObject.led_state !== undefined) {
        const ledState = parseInt(queryObject.led_state); // Obtener el valor de led_state

        // Verificar que ledState es un número válido (0 o 1)
        if (!isNaN(ledState) && (ledState === 0 || ledState === 1)) {

            // Ejecutar el comando para activar/desactivar el LED
            execFile("/root/Documents/de1soc_sw/cpp/toggle_led/toggle_led", [ledState], function (error, stdout, stderr) { });
                
            // Incrementa el contador de veces que se ha presionado el botón
            buttonPressCount++;

            // Envía una respuesta al cliente con el conteo actual de presiones del botón
            res.setHeader('Content-Type', 'application/json');
            res.end(JSON.stringify({ buttonPressCount }));
        }
       
         
    }  
    else {
        res.statusCode = 404;
        res.end('Not found');
    }
}).listen(8080);

console.log('Servidor iniciado en http://localhost:8080/');
const http = require('http');
var execFile = require('child_process').execFile;
const url = require('url');
const fs = require('fs');

var noise = 5;
var N = 1;
var frecuencia = 100000;
var fuente = 2;
var modo = 1;
var nombre_archivo = "test_web.dat";


http.createServer(function (req, res) {
    // Configura los encabezados CORS para permitir solicitudes desde cualquier origen
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET');
    res.setHeader('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');

    const parsedUrl = url.parse(req.url, true); // Parsear la URL para obtener los parámetros
    const queryObject = parsedUrl.query; // Obtener los parámetros de la URL

    if (parsedUrl.pathname === '/iniciar_lockin' ) {
        console.log('Calculando...');

        // Obtener los valores de los parámetros de la solicitud
        const noise = queryObject.noise;
        const N = queryObject.N;
        const frecuencia = queryObject.frecuencia;
        const fuente = queryObject.fuente;
        const modo = queryObject.modo;

        // Ejecutar el comando para activar/desactivar el LED con los valores de los parámetros
        execFile("/root/Documents/de1soc_sw/cpp/measure_lockin/measure_li", [noise, N, frecuencia, fuente, modo, nombre_archivo], function (error, stdout, stderr) {
            if (error) {
                console.error('Error al ejecutar el comando:', error);
                res.statusCode = 500;
                res.end('Internal Server Error');
            } else {
                // Leer el contenido del archivo test_web.dat línea por línea
                fs.readFile('/var/www/html/lockin/test_web.dat', 'utf8', (err, data) => {
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
    } else {
        res.statusCode = 404;
        res.end('Not found');
    }
}).listen(8080);

console.log('Lockin: Servidor iniciado en http://localhost:8080/');
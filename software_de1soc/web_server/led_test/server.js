const http = require('http');
var execFile = require('child_process').execFile;
const url = require('url');

var buttonPressCount = 0; // Contador para almacenar la cantidad de veces que se ha presionado el botón


http.createServer(function (req, res) {

    // Configura los encabezados CORS para permitir solicitudes desde cualquier origen
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET');
    res.setHeader('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');

    const parsedUrl = url.parse(req.url, true); // Parsear la URL para obtener los parámetros
    const queryObject = parsedUrl.query; // Obtener los parámetros de la URL

    if (parsedUrl.pathname === '/toggle' && queryObject.led_state !== undefined) {
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
}).listen(8080);

console.log('Probando LED: Servidor iniciado en http://localhost:8080/');
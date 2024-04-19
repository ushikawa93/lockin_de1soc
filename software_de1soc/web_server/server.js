var http = require('http');
var fs = require('fs');
var execFile = require('child_process').execFile;

var led_state = 0;

// Crear servidor HTTP
http.createServer(function (req, res) {
    // Verificar la ruta de la solicitud
    if (req.url === '/toggle') {
        // Si la ruta es /toggle, ejecutar el comando para activar el LED
        var child = execFile("/var/www/html/toggle_led", [led_state], function (error, stdout, stderr) {
            // Manejar errores, si es necesario
            console.log("Here is the complete output of the program: ");
            console.log(stdout);
        });
        led_state = (led_state==0)? 1:0;
        // Enviar respuesta al cliente
        res.writeHead(200, {'Content-Type': 'text/plain'});
        res.end('LED activated\n');
    } else {
        // Si la ruta no coincide con /toggle, enviar el archivo HTML al cliente
        fs.readFile('index.html', function(err, data) {
            res.writeHead(200, {'Content-Type': 'text/html'});
            res.write(data);
            res.end();
        });
    }
}).listen(8080);

console.log('Servidor iniciado en http://localhost:8080/');
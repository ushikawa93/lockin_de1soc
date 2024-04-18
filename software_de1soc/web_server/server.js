const http = require('http');
const exec = require('child_process').exec;


const port = 3000;

const server = http.createServer((req, res) => {
    if (req.url === '/toggle_led') {
        // Ejecutar el programa en C++
        exec('./var/www/html/toggle_led 1', (error, stdout, stderr) => {
            if (error) {
                console.error(`Error al ejecutar el programa en C++: ${error.message}`);
                res.writeHead(500, { 'Content-Type': 'text/plain' });
                res.end('Error al ejecutar el programa en C++.');
            } else {
                if (stderr) {
                    console.error(`Error de salida estándar del programa en C++: ${stderr}`);
                }
                console.log(`Salida estándar del programa en C++: ${stdout}`);
                res.writeHead(200, { 'Content-Type': 'text/plain' });
                res.end('Programa en C++ ejecutado correctamente. Node');
            }
        });
    } else {
        // Ruta no encontrada
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('Ruta no encontrada.');
    }
});

server.listen(port, () => {
    console.log(`Servidor web escuchando en http://localhost:${port}`);
});
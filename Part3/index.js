document.onkeydown = updateKey;
document.onkeyup = resetKey;

var server_port = 65432;
var server_addr = "192.168.2.129";   // the IP address of your Raspberry PI

function send_data(keyCode){
    console.log("-> send_data was triggered with key:", keyCode); // <--- Put this right here

    const net = require('net');
    
    const client = net.createConnection({ port: server_port, host: server_addr }, () => {
        console.log('connected to server!');
        client.write(`${keyCode}\r\n`);
    });

    client.on('error', (err) => {
        console.error("CONNECTION ERROR:", err.message);
    });

    client.on('data', (data) => {
        const response = JSON.parse(data.toString());
        document.getElementById("direction").innerHTML = response.direction;
        document.getElementById("speed").innerHTML = response.speed;
        document.getElementById("distance").innerHTML = response.distance;
        document.getElementById("temperature").innerHTML = response.temperature;

        client.end();
        client.destroy();
    });
}


// for detecting which key is been pressed w,a,s,d
function updateKey(e) {

    e = e || window.event;
    console.log("Key pressed down! KeyCode:", e.keyCode);

    if (e.keyCode == '87') {
        // up (w)
        document.getElementById("upArrow").style.color = "green";
        send_data("87");
    }
    else if (e.keyCode == '83') {
        // down (s)
        document.getElementById("downArrow").style.color = "green";
        send_data("83");
    }
    else if (e.keyCode == '65') {
        // left (a)
        document.getElementById("leftArrow").style.color = "green";
        send_data("65");
    }
    else if (e.keyCode == '68') {
        // right (d)
        document.getElementById("rightArrow").style.color = "green";
        send_data("68");
    }
}

// reset the key to the start state 
function resetKey(e) {

    e = e || window.event;

    document.getElementById("upArrow").style.color = "grey";
    document.getElementById("downArrow").style.color = "grey";
    document.getElementById("leftArrow").style.color = "grey";
    document.getElementById("rightArrow").style.color = "grey";
}

// function update_data(){
//     setInterval(() => {
//         send_data("1");
//     }, 200);
// }

// start_connection();
// update_data();
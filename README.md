# vala-chat-server
Vala chat server on WSL

sudo apt install libjson-glib-dev


Compile on WSL 
` valac server.vala --pkg gio-2.0`

To obtain WSL 2 ip address use :
`ip addr | grep eth0`

use ncat as client :
`ncat IP_ADDRESS 8080`

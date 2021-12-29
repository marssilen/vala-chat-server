List<SocketConnection> list;
void main () {
    string welcomeStr = "welcome to vala chat server";
	print (welcomeStr);
	print ("\n");

    list = new List<SocketConnection> ();
        var service = new SocketService ();
		try {
            service.add_inet_port (8080, null);
			service.incoming.connect (on_incoming_connection);
			service.start ();
			new MainLoop ().run ();
		} catch (Error e) {
			stderr.printf ("%s\n", e.message);
        }
}
bool on_incoming_connection (SocketConnection conn) {
    stdout.printf ("Got incoming connection\n");
    // Process the request asynchronously
    process_request.begin (conn);
    return true;
}
int count = 0;
async void process_request (SocketConnection conn)  {
    list.append (conn);
	count++;
	
		try {
                
                var address = conn.get_remote_address ();
                string formatted = "%s %s: %i\n".printf (address.to_string (), "new client joined the chat", count);
                print(formatted);
                //this.send_message_to_all(address.to_string (), formatted);

                var input = conn.input_stream;
                var output = conn.output_stream;
            
                var data_in = new DataInputStream (input);
                string line;
            
                while ((line = yield data_in.read_line_async (Priority.HIGH_IDLE)) != null) {
                    
                    send_message_to_all(conn, address.to_string (), line);

                    uint len = list.length ();
                    print ("List length: %u\n", len);
                    //print ("got this message: %s\n", line);
                }
            } catch (Error e) {
                stderr.printf ("%s\n", e.message);
            }
}

 void send_message_to_all(SocketConnection conn,string sender, string message){
        foreach (SocketConnection entry in list) {
            if(entry != conn){
				try{
					entry.output_stream.write (message.data);
					entry.output_stream.write ("\n".data);
				}catch (Error e) {
					list.remove_all (entry);
				}
            }
        }  
}

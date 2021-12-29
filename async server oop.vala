List<SocketConnection> list;
void main () {
    string welcomeStr = json_message(0, "server", "welcome to vala chat server");
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
    list.append (conn);
    var client = new ChatClient(conn);
    client.start();
    return true;
}

class ChatClient {

    private SocketConnection conn;
    private int count = 0;
    private static int chatID = 0;

    public ChatClient (SocketConnection conn) {
        this.conn = conn;
    }
    public void start(){
        this.process_request.begin ();
    }
    async void process_request () {
            try {
                this.count++;
                var address = this.conn.get_remote_address ();
                string formatted = "%s %s: %i\n".printf (address.to_string (), "new client joined the chat", this.count);
                print(formatted);
                this.send_message_to_all(address.to_string (), formatted);

                var input = this.conn.input_stream;
                //  var output = this.conn.output_stream;
            
                var data_in = new DataInputStream (input);
                string line;
            
                while ((line = yield data_in.read_line_async (Priority.HIGH_IDLE)) != null) {
                    chatID++;
                    this.send_message_to_all(address.to_string (), line);

                    uint len = list.length ();
                    print ("List length: %u\n", len);
                }
            } catch (Error e) {
                stderr.printf ("%s\n", e.message);
            }
    }

    private void send_message_to_all(string sender, string message){
        foreach (SocketConnection entry in list) {
            if(entry != conn){
                try{
                    entry.output_stream.write (json_message(chatID, sender, message.strip()).data);
                    entry.output_stream.write ("\n".data);
                }catch (Error e) {
                    list.remove_all (entry);
                }
            }
        }  
    }
}

string json_message(uint id, string sender, string message){
    Json.Builder builder = new Json.Builder ();

	builder.begin_object ();

    builder.set_member_name ("id");
	builder.add_int_value (id);

    builder.set_member_name ("sender");
	builder.add_string_value (sender);

	builder.set_member_name ("message");
	builder.add_string_value (message);

	builder.end_object ();

	// Generate a string:
	// {  "id" : 1 , "message" : ""}
	Json.Generator generator = new Json.Generator ();
	Json.Node root = builder.get_root ();
	generator.set_root (root);

	return generator.to_data (null);
}
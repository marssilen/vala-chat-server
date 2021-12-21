
List<SocketConnection> list;
void main () {
    list = new List<SocketConnection> ();
        var service = new SocketService ();
		try {
            service.add_inet_port (8080, null);
            service.start ();
            while (true) {
                var conn = service.accept (null);
                process_request (conn);
            }
		} catch (Error e) {
			stderr.printf ("%s\n", e.message);
        }
}

void process_request (SocketConnection conn)  {
    list.append (conn);
    var thread_user_data = new MyThread (conn);
    var thread_user = new Thread<void> ("thread_user", thread_user_data.thread_func);
     // Wait for threads to finish (this will never happen in our case)
    //  thread_user.join ();
}

class MyThread {

    private SocketConnection conn;
    private int count = 0;

    public MyThread (SocketConnection conn) {
        this.conn = conn;
    }

    public void thread_func () {
            try {
            stdout.printf ("%s: %i\n", "new client added", this.count);
            this.count++;
            
            var input = this.conn.input_stream;
            var output = this.conn.output_stream;
        
            var data_in = new DataInputStream (input);
            string line;
            
                while ((line = data_in.read_line (null)) != null) {
                    //  var header = new StringBuilder ();
                    //  header.append ("welcome");
                    //  output.write (header.str.data);

                    foreach (SocketConnection entry in list) {
                        if(entry != conn){
                            entry.output_stream.write (line.strip().data);
                            entry.output_stream.write ("\n".data);
                        }
                    }  

                    uint len = list.length ();
                    print ("List length: %u\n", len);
                }
            } catch (Error e) {
                stderr.printf ("%s\n", e.message);
            }
    }
}
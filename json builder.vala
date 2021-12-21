Json.Builder builder = new Json.Builder ();

	builder.begin_object ();
	builder.set_member_name ("url");
	builder.add_string_value ("http://www.gnome.org/img/flash/two-thirty.png");

	builder.set_member_name ("size");
	builder.begin_array ();
	builder.add_int_value (652);
	builder.add_int_value (242);
	builder.end_array ();

	builder.end_object ();
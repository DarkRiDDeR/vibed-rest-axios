import vibed_rest_axios;

void main()
{
	import vibe.inet.url;
	import vibe.http.common;
	import vibe.web.rest;

	interface S {
		void test();
	}

	interface I {
		@property S s();
		int test1();
		void test2();

		// GET /compute_sum?a=...&b=...
		@method(HTTPMethod.GET)
		float computeSum(float a, float b);

		// POST /to_console {"text": ...}
		void postToConsole(string text);
	}

	auto restsettings = new RestInterfaceSettings;
	restsettings.baseURL = URL("http://127.0.0.1:8080/");
	genRestAxios!I(restsettings, "./result");
}

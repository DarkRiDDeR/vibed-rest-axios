# Coinmarketcap D API

[![](https://img.shields.io/dub/v/vibed-rest-axios.svg?style=flat)](https://code.dlang.org/packages/vibed-rest-axios)
[![](https://img.shields.io/github/license/DarkRiDDeR/vibed-rest-axios.svg?style=flat)](https://github.com/DarkRiDDeR/vibed-rest-axios/blob/master/LICENSE)

Generator of Rest API JS ES6 client with Axios for Vibe.d

## Install

```sh
$ dub add vibed-rest-axios
```

## Example

```d
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
```
**Result in file "./result/I.js"":**
```javascript
import axios from 'axios'

const toRestString = (v) => {
  if (typeof(v) === "object") v = JSON.stringify(v);
  return encodeURIComponent(v);
}

const I = {
's': {   'test': () => {
    return axios({
      method: 'POST',
      url: 'http://127.0.0.1:8080/s/test'
    })
  } },
  'test1': () => {
    return axios({
      method: 'POST',
      url: 'http://127.0.0.1:8080/test1'
    })
  },
  'test2': () => {
    return axios({
      method: 'POST',
      url: 'http://127.0.0.1:8080/test2'
    })
  },
  'computeSum': (a,b) => {
    return axios({
      method: 'GET',
      url: 'http://127.0.0.1:8080/compute_sum' + "?a=" + toRestString(a) + "&b=" + toRestString(b)
    })
  },
  'postToConsole': (text) => {
    return axios({
      method: 'POST',
      url: 'http://127.0.0.1:8080/to_console',
      data: {"text": text}
    })
  }
}

export default I
```

## License

Apache 2.0
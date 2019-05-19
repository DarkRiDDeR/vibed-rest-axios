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
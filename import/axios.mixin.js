axios({
      method: '`~method~`',
      url: `~url~
      (headers.length==0 ? "" : ",\n      headers: "~headers)~
      (data.length==0 ? "" : ",\n      data: "~data)~`
    })
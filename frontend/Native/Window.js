// Mock values so that elm-repl doesn't blow up
var window = window || {};
var document = document || { location: { href: 'FAKE', pathname: 'FAKE', hash: 'FAKE', origin: 'FAKE',
                                        host: 'FAKE', username: 'FAKE', password: 'FAKE', search: 'FAKE',
                                        hostname: 'FAKE', port_: 0xFACE, protocol: 'FAKE'}};

// Actual module
var _futurice$tradenomiitti$Native_Window = function () {
  return {
    encodeURIComponent: window.encodeURIComponent
  };
}();

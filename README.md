# GroundControl
**Remote configuration for iOS**

> Break free of the two-week tyranny of the App Store approval process!

Many developers don't realize that they are allowed to remotely control the behavior of their app (provided that the application isn't downloading any new code).

GroundControl gives you a dead-simple way to remotely configure your app, allowing you to add things like [feature flags](http://code.flickr.com/blog/2009/12/02/flipping-out/), impromptu [A/B tests](http://en.wikipedia.org/wiki/A/B_testing), or a simple ["message of the day"](http://en.wikipedia.org/wiki/Motd_%28Unix%29).

It's built on top of [AFNetworking](https://github.com/afnetworking/afnetworking), and provides a single category on `NSUserDefaults` (just add `#import "NSUserDefaults+GroundControl.h"` to the top of any file you want to use it in).

> This project is part of a series of open source libraries covering the mission-critical aspects of an iOS app's infrastructure. Be sure to check out its sister projects: [SkyLab](https://github.com/mattt/SkyLab), [CargoBay](https://github.com/mattt/CargoBay), [houston](https://github.com/mattt/houston), and [Orbiter](https://github.com/mattt/Orbiter).

## Client Code

```objective-c
NSURL *URL = [NSURL URLWithString:@"http://example.com/defaults.plist"];
[[NSUserDefaults standardUserDefaults] registerDefaultsWithURL:URL];
```

...or if you need callbacks for success/failure, and prefer not to listen for a `NSUserDefaultsDidChangeNotification`:

```objective-c
NSURL *URL = [NSURL URLWithString:@"http://example.com/defaults.plist"];
[[NSUserDefaults standardUserDefaults] registerDefaultsWithURL:URL
  success:^(NSDictionary *) { 
    // ... 
} failure:^(NSError *) { 
    // ...
}];
```

...or if you need to use an HTTP method other than GET, or need to set any special headers, specify an `NSURLRequest`:

```objective-c
NSURL *URL = [NSURL URLWithString:@"http://example.com/defaults.plist"];
NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
[[NSUserDefaults standardUserDefaults] registerDefaultsWithURLRequest:request
  success:^(NSURLRequest *, NSHTTPURLResponse *, NSDictionary *) { 
    // ... 
} failure:^(NSURLRequest *, NSHTTPURLResponse *, NSError *) { 
    // ... 
}];
```

## Server Code

GroundControl asynchronously downloads and reads a remote plist file. This could be a static file or generated dynamically, like in the following examples (see also the complete Sinatra application found in `example/server`):

### Ruby

```ruby
require 'sinatra'
require 'plist'

get '/defaults.plist' do
  content_type 'application/x-plist'

  {
    'Greeting' => "Hello, World",
    'Price' => 4.20,
    'FeatureXIsLaunched' => true
  }.to_plist
end
```

### Python

```python
from django.http import HttpResponse
import plistlib

def property_list(request):
    plist = { 
         'Greeting': "Hello, World", 
         'Price': 4.20, 
         'FeatureXIsLaunched': True, 
         'Status': 1 
    }
    
    return HttpResponse(plistlib.writePlistToString(plist))
```

### Node.js

```javascript
var plist = require('plist'),
    express = require('express')

var host = "127.0.0.1"
var port = 8080

var app = express()
app.use(app.router)

app.get("/", function(request, response) { 
        response.send(plist.build(
            {
                'Greeting': "Hello, World", 
                'Price': 4.20, 
                'FeatureXIsLaunched': true, 
                'Status': 1
            }
        ).toString())
})

app.listen(port, host)
```

### Contact

[Mattt Thompson](http://github.com/mattt)  
[@mattt](https://twitter.com/mattt)

## License

GroundControl is available under the MIT license. See the LICENSE file for more info.


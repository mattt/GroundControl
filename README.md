# GroundControl
**Remote configuration for iOS**

> Break free of the two-week tyranny of the App Store approval process!

Many developers don't realize that they are allowed to remotely control the behavior of their app (provided that the application isn't downloading any new code).

GroundControl gives you a dead-simple way to remotely configure your app, allowing you to add things like [feature flags](http://code.flickr.com/blog/2009/12/02/flipping-out/), impromptu [A/B tests](http://en.wikipedia.org/wiki/A/B_testing), or a simple ["message of the day"](http://en.wikipedia.org/wiki/Motd_(Unix)).

It's built on top of [AFNetworking](https://github.com/afnetworking/afnetworking), and provides a single category on `NSUserDefaults` (just add `#import "NSUserDefaults+GroundControl.h"` to the top of any file you want to use it in).

## Client Code

```objective-c
  NSURL *URL = [NSURL URLWithString:@"http://example.com/defaults.plist"];
  [[NSUserDefaults standardUserDefaults] registerDefaultsWithURL:URL];
```

...or if you need callbacks for success/failure, and prefer not to listen for a `NSUserDefaultsDidChangeNotification`:

```objective-c
  NSURL *URL = [NSURL URLWithString:@"http://example.com/defaults.plist"];
  [[NSUserDefaults standardUserDefaults] registerDefaultsWithURL:URL
                                                         success:^(NSDictionary *defaults) { ... }
                                                         failure:^(NSError *error) { ... }
  ];
```

...or if you need to use an HTTP method other than GET, or need to set any special headers, specify an `NSURLRequest`:

```objective-c
  NSURL *URL = [NSURL URLWithString:@"http://example.com/defaults.plist"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
  [[NSUserDefaults standardUserDefaults] registerDefaultsWithURLRequest:URL
                                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *defaults) { ... }
                                                                failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) { ... }
  ];
```

## Server Code

GroundControl asynchronously downloads and reads a remote plist file. This could be a static file or served dynamically. Either way, since property lists aren't especially fun to write by hand, you can generate and serve one rather easily using the `plist` and `sinatra` gems (full working version can be found in example/server):

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

Django example (views.py)
```python
from django.http import HttpResponse
import plistlib

def property_list(request):
    d = { 
         'Greeting':"Hello, World", 
         'Price':4.20, 
         'FeatureXIsLaunched':True, 
         'Status':1 
    }
    
    return HttpResponse(plistlib.writePlistToString(d))
```

### Creators

[Mattt Thompson](http://github.com/mattt)  
[@mattt](https://twitter.com/mattt)

## License

GroundControl is available under the MIT license. See the LICENSE file for more info.


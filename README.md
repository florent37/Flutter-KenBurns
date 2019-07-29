# KenBurns

The Ken Burns effect is a type of panning and zooming effect used in video production from still imagery.

Wrap your image with a KenBurns widget
```dart
Container(
      height: 300,
      child: KenBurns(
        child: Image.network("https://lemag.nikonclub.fr/wp-content/uploads/2017/07/08.jpg", fit: BoxFit.cover,),
      ),
),
```

[![screen](https://raw.githubusercontent.com/florent37/Flutter-KenBurns/master/medias/kenburns_slow.gif)](https://www.github.com/florent37/Flutter-KenBurns)

# Configuration

You can configure KenBurns Widget

```
KenBurns(
    minAnimationDuration : Duration(milliseconds: 3000),
    maxAnimationDuration : Duration(milliseconds: 10000),
    maxScale : 8,
    child: ...
  });
```

# Multiple images

You can display multiple child in KenBurns with a CrossFade animation

```dart
Container(
    height: 300,
    child: KenBurns.multiple(
      childLoop: 3,
      children: [
        Image.network(
          "https://www.photo-paysage.com/?file=pic_download_link/picture&pid=3100",
          fit: BoxFit.cover,
        ),
        Image.network(
          "https://cdn.getyourguide.com/img/location_img-59-1969619245-148.jpg",
          fit: BoxFit.cover,
        ),
        Image.network(
          "https://www.theglobeandmail.com/resizer/vq3O7LI3hvsjTP2N0m9NwU4W3Eg=/1500x0/filters:quality(80)/arc-anglerfish-tgam-prod-tgam.s3.amazonaws.com/public/4ETF3GZR3NA3RDDW23XDRBKKCI",
          fit: BoxFit.cover,
        ),
      ],
    ),
),
```

# Download

https://pub.dev/packages/kenburns

```
dependencies:
  kenburns: 
```

## Getting Started with Flutter

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

# License

    Copyright 2019 florent37, Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

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

    Copyright 20189 florent37, Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

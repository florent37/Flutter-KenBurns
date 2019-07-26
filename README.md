# kenburns

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

[![screen](https://raw.githubusercontent.com/florent37/Flutter-KenBurns/master/medias/shake.gif)](https://www.github.com/florent37/Flutter-KenBurns)

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

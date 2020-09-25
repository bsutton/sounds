# Platform Implementations

The Sounds project currently supports the IOS and Android Platforms.

Sounds aims to provide support on every Flutter supported platform.

More than 95% of the Sounds project code is written in Dart. 

{% hint style="info" %}
The IOS Platform implementation is around 1600 lines of code including comments and blank lines.
{% endhint %}

This means that each Platform implementation is small as it only needs to provide a core set of functions defined by the Sounds Platform API.

To support that aim the Sounds project is moving towards  [Dart's federated plugin model](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#federated-plugins).

The Sounds team is looking for contributes to pick and developed support for each one of the emerging Flutter target platforms including:

* Web
* Linux
* Macos
* Windows

And any other platform as the Flutter team offers support for them.

As the requirements of the Sounds Platform API are fairly simple a single developer should be able to managed each platform.

## Federated plugin model

As noted, Sounds is moving towards  Dart's federated plugin model.

The federated model allow Sounds to defined a Platform API which describes the set of calls that Sounds makes into the Platform and expects back from the Platform.

By implementing the Platform specific code in a separate package, each Platform implementation is small a fairly simple to write and maintain.

The Platform API is defined in a separate package referred to as the Platform Interface Package, for Sounds this package is called the \`sounds\_platform\_interface\`.

Within the sounds\_platform\_interface  the Dart library `sounds_platform_api.dart` defines the api.

The federated model allows third party developers to contribute a Platform specific implementation of the Sounds platform API independent of the main Sounds project.

## Pigeon

The Pigeon project is a new Dart project for building Platform APIs that work with the Federated plugin model.

The Pigeon project allows Sounds to define the Sounds Platform API in Dart and then have Pigeon generate the Platform specific communications layer. 

The main Sounds project includes a `pigeon` directory that contains the `sounds_platform_api.dart` library which defines the Sounds Platform API. 

Sounds uses the Dcli script pigeon/pigeon\_gen.dart to generate the platform specific code. 

Currently Pigeon supports Android and IOS but we expect to see support for each of the Flutter supported Platforms as the Pigeon project matures.




# macOS.SparkleUpdater.Avalonia

Use the popular [macOS Sparkle](https://github.com/sparkle-project/Sparkle) library in your (Avalonia)[https://github.com/AvaloniaUI/Avalonia] projects! With this setup, you can still develop in Visual Studio normally without bundling the `.app` -- the native lib will make sure you're in a `.app` with a few `Info.plist` values defined before it runs Sparkle. When your project is ready for prime-time and you've got a `.app` ready, you can use this setup to run Sparkle with your app!

## Setup

Requirements:

* Xcode
* macOS computer (for building native library, etc.)
* This only works within a `.app` file, so your program needs to be bundled in a `.app` for this to work.
* Your `.app` needs a valid `Info.plist` defined with all the things Sparkle requires (`SUFeedURL`, etc.).
* This project comes with a pre-built `Sparkle.framework`. If you don't feel comfortable using that for whatever reason, just clone the [Sparkle repo]((https://github.com/sparkle-project/Sparkle)), build it yourself, and make sure your build's output Sparkle.framework is in the same place as the current one.

1. Download/clone this project. It'll work just fine within your current project structure.
2. Open up `SparkleUpdater/SparkleUpdater.xcodeproj` in Xcode. Build the project in both debug and release. The output defaults to `SparkleUpdater/build/{Configuration}/libSparkleUpdater.dylib`.
3. In your `.csproj` for your Avalonia project, add the following:

```
  <ItemGroup Condition="'$(Configuration)' == 'Debug' AND '$([MSBuild]::IsOSPlatform(OSX))' == 'true'">
    <Content Include="path/to/Debug/libSparkleUpdater.dylib">
      <PackagePath>runtimes/osx/native/libSparkleUpdater.dylib</PackagePath>
      <Pack>true</Pack>
      <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
    </Content>
  </ItemGroup>
  <ItemGroup Condition="'$(Configuration)' == 'Release' AND '$([MSBuild]::IsOSPlatform(OSX))' == 'true'">
    <Content Include="path/to/Release/libSparkleUpdater.dylib">
      <PackagePath>runtimes/osx/native/libSparkleUpdater.dylib</PackagePath>
      <Pack>true</Pack>
      <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
    </Content>
  </ItemGroup>
```

4. Make sure that when you build your .app that you copy `NetSparkle.framework` into `MyApp.app/Contents/Frameworks/NetSparkle.app`.
5. When your software has started, run this code to initialize Sparkle and check for updates silently (the update window will only show if an update is available):

```
[DllImport("libSparkleUpdater")]
private static extern void InitSparkle();

public SomeFunc()
{
    InitSparkle();
}
```

It's probably best to call this after your main window has been shown.

6. If you want the user to be able to manually check for updates, you can use this code:

```
[DllImport("libSparkleUpdater")]
private static extern void CheckForSparkleUpdates();

public SomeFunc()
{
    CheckForSparkleUpdates();
}
```

Ta-da! Sparkle updates will now work as provided in their [documentation](https://sparkle-project.org/documentation).

## FAQ

**When I code sign my app with a hardened runtime (for notarization), do I have to do anything special for NetSparkle?**

Yup! As [outlined in this GitHub comment](https://github.com/sparkle-project/Sparkle/issues/1389#issuecomment-507950890), you need to code sign `AutoUpdate.app`. You can do it like this:

```bash
!#/bin/bash
IDENTITY="Developer ID: MyCompany, Inc."

codesign --verbose --force --deep --options=runtime --sign "$IDENTITY" "MyApp.app/Contents/Frameworks/Sparkle.framework/Versions/A/Resources/AutoUpdate.app"
codesign --verbose --force --options=runtime --sign "$IDENTITY" "MyApp.app/Contents/Frameworks/Sparkle.framework/Versions/A"
codesign --verbose --force --options=runtime --sign "$IDENTITY" "MyApp.app/Contents/Frameworks/Sparkle.framework"
```

**What about all the Sparkle delegate functions, etc.?**

You'll need to modify the native lib yourself. Maybe you'd be willing to contribute those improvements back to this library?

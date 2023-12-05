
[This](https://github.com/dotnet/msquic) repo is a thin wrapper around https://github.com/microsoft/msquic . It is used to produce a package for _testing_ purposes, when an official MsQuic package is not available.
At this moment, there are two main use cases:
- Consuming latest MsQuic main to pick up feature work and general improvements to feed main branch of runtime,
- Building the package to test on Linux distros that don't have an official package yet (such as Alpine).

The build will create signed NuGet packages to be consumed by Windows and unsigned Linux and MacOS packages. Neither of them are meant for direct consumption.

On Windows, release versions of .NET use official MsQuic packages that are published to [NuGet](https://www.nuget.org/packages/Microsoft.Native.Quic.MsQuic.Schannel). Windows package is consumed by .NET runtime and `msquic.dll` is part of runtime distribution on Windows. In order to switch to the private package within the dotnet/runtime repo, you need to change the value of the [UseQuicTransportPackage](https://github.com/dotnet/runtime/blob/0c513d95c181159f3ea02531c7901ce15503f3ee/src/libraries/System.Net.Quic/src/System.Net.Quic.csproj#L20) flag to `true`.

For Linux, there is currently no automated workflow. Signed packages are published on https://packages.microsoft.com/. Linux users should use packages from there either directly or via their package manager. 

For more info, see [System.Net.Quic readme](https://github.com/dotnet/runtime/blob/main/src/libraries/System.Net.Quic/readme.md).

**Build & Updates**

To build this repro, make sure you checkout appropriate branch _RECURSIVELY_. MsQuic code is pulled in as submodule as well as it uses submodules internally. The build currently depends on PowerShell as well as it needs all the prerequisities required by MsQuic. (https://github.com/microsoft/msquic/blob/main/docs/BUILD.md)

To build it, run top-level `build` script. That essentially calls `Build-native` from [src/System.Net.MsQuic.Transport/System.Net.MsQuic.Transport.csproj](https://github.com/dotnet/msquic/blob/main/src/System.Net.MsQuic.Transport/System.Net.MsQuic.Transport.csproj)
To see what is going on with official Azure pipeline you can check [eng/pipelines/msquic.yml](https://github.com/dotnet/msquic/blob/main/eng/pipelines/msquic.yml)

to update msquic you can use following sequence
```
cd  src/msquic
git fetch origin
git checkout main (or what ever branch or tag)
cd ../..
git add src/msquic
```
At this point, full build is recommended and changes should be staged for PR. You can use `git log` to check whether msquic has changed. Also GitHub UI shows the actual changes instead of just updated directory like the command line tool. 

When changes are submitted, official build will kick in and it will produce updated NuGet package. To see the latest package and its history look at https://dev.azure.com/dnceng/public/_artifacts/feed/dotnet9-transport/NuGet/System.Net.MsQuic.Transport

The packages _should_ flow to runtime repo via DARC e.g. there should eventually be maestro PR to updated reference. 
It is also always possible to update the runtime directly with change similar to https://github.com/dotnet/runtime/pull/57541

There is currently no process for updating Linux packages. 

**Updating test images**

On Linux for now we only run tests in cotainers. To pick up change, one need to rebuild appropriate container and update pipeline configuration to point at update image. To rebuild container _without_ submitting changes, one needs to do manual pipeline run (internal) with added `noCache = true` variable. 



[This](https://github.com/microsoft/msquic) repo is thin wrapper around https://github.com/microsoft/msquic . Main reason is packaging and release management so .NET runtime. 
At this moment, there are two branches:
-	Release/6.0 to supply MsQuic for .NET 6.0 release. (msquic 1.7)
-	Main branch to pick up feature work and general improvements to feed main branch of runtime (msquic 1.8)

In both cases, the build will create signed NuGet packages to be consumed by Windows and unsigned Linux packages. 
Neither one is meant for direct consumption. Windows package is consumed by .NET runtime and msquic.dll is part of runtime distribution on Windows.
For Linux, there is currently no automated workflow. Signed packages are manually published on https://packages.microsoft.com/. Linux users should use packages from there either directly or via their package manager. 


**Build & Updates**

To build this repro, make sure you checkout appropriate branch _RECURSIVELY_. MsQuic code is pulled in as submodule as well as it uses submodules internally. The build currently depends on PowerShell as well as it needs all the prerequisities required by MsQuic. 

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

When changes are submitted, official build will kick in and it will produce updated NuGet package. To see the latest package and its history look at https://dev.azure.com/dnceng/public/_packaging?_a=package&feed=dotnet6-transport&package=System.Net.MsQuic.Transport

The packages _should_ flow to runtime repo via DARC e.g. there should eventually be maestro PR to updated reference. 
It is also always possible to update the runtime directly with change similar to https://github.com/dotnet/runtime/pull/57541

There is currently no process for updating Linux packages. 

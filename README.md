# Spigot NMS All-in-One

[![License](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)
[![Discord](https://img.shields.io/discord/341897164642975756?color=blue&label=Discord)](https://discord.foxelia.fr/)
[![GitHub](https://img.shields.io/github/stars/FoxeliaFR/spigot-nms-all-in-one?style=social)](https://github.com/FoxeliaFR/spigot-nms-all-in-one)

This is a simple project that allows you to use all NMS versions in one plugin. This is useful for developers who want to use NMS in their plugins, but don't want to have to worry about the version of the server they are running on.

## What the tool can do ?
- Create single JAR file which handles all NMS versions.
- Support all future NMS versions.
- Support all Minecraft versions starting from 1.16.1
- Include each specific craftbukkit version in the plugin.
- Create a local maven repository for easy dependency management.
- Create per major version JAR files (1.16, 1.17, etc.)
- Easy of use.

## How to use ?

### Prerequisites
To use this tool, you need to have the following software installed on your computer:
- [![Java JDK](https://img.shields.io/badge/Java-22-red?logo=oracle)](https://www.oracle.com/java/technologies/downloads/) [Java JDK 16](https://www.oracle.com/java/technologies/javase/jdk16-archive-downloads.html) or higher ([Java JDK 17](https://www.oracle.com/java/technologies/downloads/#java17) recommended)
- [![Maven](https://img.shields.io/badge/Maven-3.9.6-orange?logo=apache)](https://maven.apache.org/download.cgi) [Maven](https://maven.apache.org/download.cgi) installed or have already used it before.
- [![Git](https://img.shields.io/badge/Git-2.45.0-blue?logo=git)](https://git-scm.com/downloads) [Git](https://git-scm.com/downloads) bash only for Windows users.

<br/>

You can check your Java version by running the following command:
```shell
java -version
```
<br/>

You can check your Maven version by running the following command:
```shell
mvn -version
```
If the command is not recognized, you need to have at least a .m2 folder in your user directory.

<br/>

### [![Windows](https://img.shields.io/badge/Windows-11-blue?logo=windows)](https://www.microsoft.com/windows/get-windows-11) | Windows
To run shell scripts on Windows, you need to install a shell emulator like [Git Bash](https://git-scm.com/downloads).

1. Download the [latest version](run.sh) of the shell script and place it in into an empty directory.
2. Open a terminal in the directory where the script is located and run the following command:
```bash
./run.sh
```
3. Follow the [instructions](#instructions) below.

### [![Linux](https://img.shields.io/badge/Linux-Ubuntu-orange?logo=ubuntu)](https://ubuntu.com/download) | Linux
The script was only tested on Windows, but it should work on Linux as well. If you encounter any issues, please let me know.

1. Create a new directory and place the [latest version](run.sh) of the shell script in it.
```shell
mkdir spigot-nms-all-in-one
cd spigot-nms-all-in-one
wget https://raw.githubusercontent.com/FoxeliaFR/spigot-nms-all-in-one/main/run.sh
```
2. Run the script.
```shell
chmod +x run.sh
./run.sh
```
3. Follow the [instructions](#instructions) below.

### [![MacOS](https://img.shields.io/badge/MacOS-Sonama-black?logo=apple)](https://www.apple.com/macos/sonoma/) | MacOS
The script was only tested on Windows, but it should work on MacOS as well. I don't have a MacOS device to test it. If you encounter any issues, please let me know.

1. Create a new directory and place the [latest version](run.sh) of the shell script in it.
2. Run the script.
```shell
chmod +x run.sh
./run.sh
```
3. Follow the [instructions](#instructions) below.

### Instructions
1. The script will ask you to enter the version you want to use. Example, if you input `1.16` it will create a JAR file for `1.16.1`, `1.16.2`, `1.16.3`, etc.
<br/>If you want to compile all versions, you can input `all`.
2. If you input `all`, the script will ask you if you want include old versions (1.16.x and 1.17.x) or only the latest versions.
<br/>Answer `y` to include old versions `1.16.x`, `1.17.x`, `1.18.x`, `1.19.x`, etc.
<br/>Answer `n` to only include the latest most recent versions `1.18.x`, `1.19.x`, `1.20.x`, etc.
3. The next question is to warn you about the time it will take to compile all versions.
<br/>You need to have a good internet connection and a good computer to compile all versions. 
<br/><br/>Example, on my computer Ryzen 7 3800X (8 cores, 16 threads) with 48GB of RAM and a 1Gbps internet connection, it takes around __**8 minutes per version**__ you want to build.
<br/><br/>If you have ever run BuildTools with `--remap` flag or used the script in the past, the script will just skip the versions you have already compiled to save time.
<br/><br/>If you want to recompile all versions even if you have already compiled them, answer `n` and restart the script with the force flag `-f`.
```shell
./run.sh -f 
```
<br/><br/>If you have a slow internet connection or a slow computer, I recommend you launch in debug mode to see the progress of the script.
```shell
./run.sh -d
```
<br/><br/>⚠️ If you answer `y`, don't press `^C` (CTRL+C) to stop the script. Sometimes the BuildTools process will not stop and you will need to kill the process manually. Other times, the script will be locked and you won't be able to run it again. See the [troubleshooting](#troubleshooting) section for more information.
4. When all versions are compiled and merged into a single JAR file, the script will ask you if you want to install the JAR file in your local maven repository.
<br/>Answer `y` to install the JAR file in your local maven repository.
<br/>Answer `n` if you prefer importing the JAR file manually in your project (you can do both by answering `y` to this step).

5. The script will ask you if you want to delete created JAR files.
<br/>Answer `y` to delete the JAR files and free up space.
<br/>Answer `n` if you want to keep the JAR files for importing them manually in your project.

## How to use in your project ?

### Maven
To use the plugin in your project, you need to add the following dependency in your `pom.xml` file:
```xml
<dependency>
    <groupId>fr.foxelia</groupId>
    <artifactId>spigot</artifactId>
    <version>ALLINONE-R0.1-SNAPSHOT</version>
    <scope>provided</scope>
</dependency>
```

The differrent versions available are the following:
- `1.x-R0.1-SNAPSHOT` if you have compiled only one version (e.g. `1.18-R0.1-SNAPSHOT` will include `1.18`, `1.18.1`, `1.18.2`)
- `ALLINONE-OLD-R0.1-SNAPSHOT` if you have compiled all versions with only Java JDK 16. It will include `1.16.1`, `1.16.2`, `1.16.3`, `1.16.4`, `1.16.5`, `1.17` and `1.17.1`
- `ALLINONE-MODERN-R0.1-SNAPSHOT` if you have compiled all versions with only Java JDK 17 or above. It will include all versions starting from `1.18`
- `ALLINONE-R0.1-SNAPSHOT` if you have compiled all versions with both Java JDK 16 and Java JDK 17 or above. It will include all versions starting from `1.16.1`

if you want to use mojang mappings, simply add a classifier to the dependency:
```xml
<dependency>
    <groupId>fr.foxelia</groupId>
    <artifactId>spigot</artifactId>
    <version>ALLINONE-R0.1-SNAPSHOT</version>
    <classifier>remapped-mojang</classifier>
    <scope>provided</scope>
</dependency>
```

## Troubleshooting

### The script is locked and I can't run it again

```
[Error] Please check the error message below:
Exception in thread "main" org.eclipse.jgit.errors.RepositoryNotFoundException: repository not found: C:\Users\User\Download\spigot-nms-all-in-one\CraftBukkit
```

This errors often occurs when you press `^C` (CTRL+C) to stop the script when it was building a version. The script will not be able to run again because the BuildTools process is still running in the background. You need to find it and kill the process manually.
<br/>If you don't know how to do it, you can restart your computer.
<br/><br/>Once you're sure the process is killed, you need to **delete** the `CraftBukkit` folder in the root directory of the script.

## FAQ

### Do you plan to support legacy versions of Minecraft ?
No, I don't plan to support older versions of Minecraft before 1.16. I have deliberately chosen to support starting from this version because is still played by a lot of players. If you want to use older versions, you can use the [all-spigot-nms](https://github.com/Jacxk/all-spigot-nms/)

## Get support
If you need help, you can join the [Foxelia's Discord server](https://discord.foxelia.fr/) and ask for help in the appropriate channel. You can also open an [issue](https://github.com/FoxeliaFR/spigot-nms-all-in-one/issues/).
<br/>If you have found a bug, you can open an issue on the [GitHub repository](https://github.com/FoxeliaFR/spigot-nms-all-in-one/issues/)

## Contributing
If you want to contribute to the project, you can fork the repository and create a pull request. If I don't respond to your pull request, you can join the [Foxelia's Discord server](https://discord.foxelia.fr/) and ask for help in the appropriate channel.

## Why this project ?
I have found a project made by [Jacxk](https://github.com/Jacxk/), but I found his project a little bit buggy or maybe too complicated to use. Also, his system need updates every time a new version of Minecraft is released. I wanted to create a simple project that would be easy to use and that would support all future versions of Minecraft. 

## License
[<img src="https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg">](https://creativecommons.org/licenses/by-sa/4.0/)<br>
<img src="https://mirrors.creativecommons.org/presskit/buttons/88x31/svg/by-sa.svg" alt="CC BY-SA 4.0" width="200" height="70"><br>
This work is licensed under a
[Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).<br>
Read the [LICENSE](LICENSE.md) file for license rights and limitations (CC BY-SA 4.0).

## Credits

| Name                | Role            |
|---------------------|-----------------|
| [Foxelia](https://foxelia.fr/) | Project creator |
| [Zarinoow](https://github.com/Zarinoow) | Project contributor |
| [Jacxk](https://github.com/Jacxk/) | Inspiration for the project |
| [SpigotMC](https://www.spigotmc.org/) | Minecraft server software |
| [Mojang](https://www.mojang.com/) | Minecraft game developer |

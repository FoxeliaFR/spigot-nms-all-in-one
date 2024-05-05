#!/bin/bash

# _______  _______           _______  _       _________ _______
#(  ____ \(  ___  )|\     /|(  ____ \( \      \__   __/(  ___  )
#| (    \/| (   ) |( \   / )| (    \/| (         ) (   | (   ) |
#| (__    | |   | | \ (_) / | (__    | |         | |   | (___) |
#|  __)   | |   | |  ) _ (  |  __)   | |         | |   |  ___  |
#| (      | |   | | / ( ) \ | (      | |         | |   | (   ) |
#| )      | (___) |( /   \ )| (____/\| (____/\___) (___| )   ( |
#|/       (_______)|/     \|(_______/(_______/\_______/|/     \|
#
# Foxelia Team - https://foxelia.fr
# Foxelia Discord - https://discord.foxelia.fr
# Foxelia Github - https://github.com/FoxeliaFR
# Spigot NMS All-In-One - https://github.com/FoxeliaFR/spigot-nms-all-in-one
# BuildTools - https://www.spigotmc.org/wiki/buildtools/
#
# License: CC BY-SA 4.0 - https://creativecommons.org/licenses/by-sa/4.0/
# This license lets others remix, adapt, and build upon your work even for commercial purposes,
# as long as they credit you and license their new creations under the identical terms.
#
# This script is a shell script used to build all Minecraft versions available
# to use the NMS package and the CraftBukkit specific to each version.
# This script is based on the Spigot BuildTools
#
# Legacy versions of Minecraft is deliberately not supported.
# The script will only build modern versions from 1.16 and above.
# If you want to build older versions, you are free to modify the script.
#
# Version 1.0.0 - 05/05/2024
# Developed by Foxelia Team - 2024
# | Zarinoow - https://github.com/Zarinoow

OS=$(uname)
debugModeEnabled=false
forceDownload=false

mcVersions=()
selectedMCVersions=()
javaVersions=()
javaPath=()

function pressKeyAndExit() {
  exitCode=$1
  read -p "Press any key to exit..." -n1 -s
  exit $exitCode
}

function checkOS() {
    if [ "$OS" == "Darwin" ]; then
      if [ "$debugModeEnabled" == true ]; then
        echo -e "\u001B[90m[DEBUG] Mac OS detected\u001B[0m"
      fi
    elif [ "$OS" == "Linux" ]; then
      if [ "$debugModeEnabled" == true ]; then
        echo -e "\u001B[90m[DEBUG] Linux detected\u001B[0m"
      fi
    else
      if [ "$debugModeEnabled" == true ]; then
        echo -e "\u001B[90m[DEBUG] Windows detected\u001B[0m"
      fi
      OS="Windows"
    fi
}

# Choose Minecraft Versions to build
# Choisir les versions de Minecraft à construire
function selectMCVersion() {
  echo " "
  read -a availableVersions -d '\n' <<< "$(printf "%s\n" "${mcVersions[@]}" | cut -d'.' -f1,2 | sort -u)"

  printf -v joinedVersions "\u001B[93m%s\u001B[92m; " "${availableVersions[@]}"
  echo -e "\u001B[92mAvailable versions: $joinedVersions\u001B[0m"

  echo -e "\u001B[94mDo you want to build all versions or only a specific version ?\u001B[0m"
  echo " "
  read -p "If yes enter the version (e.g. 1.16) or simply ask all : " version
  if [ "$version" == "all" ]; then
    read -p "Do you want to include old versions (1.16 and 1.17) ? (y/n) " oldVersions

    if [ "$oldVersions" == "y" ]; then
      if [ "$debugModeEnabled" == true ]; then
        echo -e "\u001B[90m[DEBUG] Building all versions\u001B[0m"
      fi
      selectedMCVersions+=("${mcVersions[@]}")
    else
      if [ "$debugModeEnabled" == true ]; then
        echo -e "\u001B[90m[DEBUG] Building only version >= 1.18\u001B[0m"
      fi
      # Add all versions >= 1.18 (1.18, 1.19, 1.20, ...)
      for mcVersion in "${mcVersions[@]}"; do
        major=$(echo $mcVersion | cut -d'.' -f2)
        if [[ $major -ge 18 ]]; then
          selectedMCVersions+=($mcVersion)
        fi
      done
    fi

    buildVersions

  else
    version=$(echo $version | cut -d'.' -f1,2)

    # Check if the entry is valid
    if [[ ! " ${availableVersions[@]} " =~ " ${version} " ]]; then
      echo -e "\u001B[91m[Error] Version \u001B[31m$version\u001B[91m is not available. Please enter a valid version.\u001B[0m"
      selectMCVersion
    fi

    # Check if the version can be built
    if canBeBuilt $version; then
      # Add all subversions which match the version
      for mcVersion in "${mcVersions[@]}"; do
        if [[ $mcVersion == $version* ]]; then
          selectedMCVersions+=($mcVersion)
        fi
      done
      buildVersions
    else
      echo -e "\u001B[91m[Error] Version \u001B[31m$version\u001B[91m can't be build. Please install the correct JDK version.\u001B[0m"
      selectMCVersion
    fi
  fi
}

# Get all JDK Versions installed
# Obtenir toutes les versions de JDK installées
function getJDKVersions() {
  if [ "$debugModeEnabled" == true ]; then
    echo -e "\u001B[90m[DEBUG] Getting all JDK Versions installed on your system.\u001B[0m"
  fi
  if [ "$OS" == "Windows" ]; then
    directories=(
          "C:/Program Files/Java/"
          "C:/Program Files (x86)/Java/"
        )

    for dir in "${directories[@]}"; do
      for javaDir in "$dir"; do
        if [ -d "$javaDir" ]; then
          for jdk in "$javaDir"*; do
            if [ -d "$jdk" ]; then
              version=$("$jdk/bin/java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
              if [ "$debugModeEnabled" == true ]; then
                echo -e "\u001B[90m[DEBUG] Found Java version $version in $jdk\u001B[0m"
              fi
              javaVersions+=($(echo $version | cut -d'.' -f1))
              javaPath+=("$jdk/bin")
            fi
          done
        fi
      done
    done

    if [ ${#javaVersions[@]} -eq 0 ]; then
      echo -e "\u001B[91m[Error]No JDK found on your system ! Please install a JDK and try again.\u001B[0m"
      echo " "
      pressKeyAndExit 1
    fi
  else
    for jdk in $(find /usr/lib/jvm -maxdepth 1 -mindepth 1 -type d); do
      version=$("$jdk/bin/java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
      if [ "$debugModeEnabled" == true ]; then
        echo -e "\u001B[90m[DEBUG] Found Java version $version in $jdk\u001B[0m"
      fi
      javaVersions+=($(echo $version | cut -d'.' -f1))
      javaPath+=("$jdk/bin")
    done

    if [ ${#javaVersions[@]} -eq 0 ]; then
      echo -e "\u001B[91m[Error]No JDK found on your system ! Please install a JDK and try again.\u001B[0m"
      echo " "
      pressKeyAndExit 1
    fi
  fi
  if [ "$debugModeEnabled" == true ]; then
    echo -e "\u001B[90m[DEBUG] Found the following JDK versions: ${javaVersions[@]}\u001B[0m"
    echo " "
  fi
}

# Download the BuildTools
# Téléchargement du BuildTools
function downloadBuildTools() {
  if [ ! -f "BuildTools.jar" ]; then
    echo -e "\u001B[93mBuildTools.jar not found. Downloading...\u001B[0m"
    curl -o BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
    echo -e "\u001B[92mSuccessfully downloaded BuildTools.jar\u001B[0m"
    echo " "
  fi
}

function detectMCVersions() {
  echo -e "\u001B[92mDetecting all Minecraft versions available for the BuildTools...\u001B[0m"
  # Get all existing versions of the Minecraft for the BuildTools
  # Obtenir toutes les versions existantes de Minecraft pour le BuildTools
  spigotUrl="https://hub.spigotmc.org/versions/"

  # Get all .json files
  files=$(curl -s $spigotUrl | grep -oP '>[0-9]+\.[0-9]+(\.[0-9]+)?\.json<' | sed 's/[<>]//g')

  for file in $files; do
    # Remove .json extension to get the version
    # Supprimer l'extension .json pour obtenir la version
    version=${file%.json}

    major=$(echo $version | cut -d'.' -f1)
    minor=$(echo $version | cut -d'.' -f2)
    if [[ $major -ge 1 && $minor -ge 16 ]]; then
      mcVersions+=($version)
    fi
  done

  IFS=$'\n' mcVersions=($(sort -V <<<"${mcVersions[*]}"))
  unset IFS
  echo -e "\u001B[92mFound \u001B[96m${#mcVersions[@]} versions\u001B[92m available for the BuildTools.\u001B[0m"
}

function canBeBuilt() {
  version=$1
  if [[ $version == "1.16" ]]; then
    for jdk in "${javaVersions[@]}"; do
      if [[ $jdk == "8" || $jdk == "16" ]]; then
        return 0
      fi
    done
  elif [[ $version == "1.17" ]]; then
    for jdk in "${javaVersions[@]}"; do
      if [[ $jdk == "16" ]]; then
        return 0
      fi
    done
  else
    for jdk in "${javaVersions[@]}"; do
      if [[ $jdk -ge 17 ]]; then
        return 0
      fi
    done
  fi
  return 1
}

function getJDKPath() {
  version=$1
  for i in "${!javaVersions[@]}"; do
    if [[ $version == 1.16 ]]; then
      if [[ ${javaVersions[$i]} == 8 || ${javaVersions[$i]} == 16 ]]; then
        echo ${javaPath[$i]}
        return
      fi
    elif [[ $version == 1.17 ]]; then
      if [[ ${javaVersions[$i]} == 16 ]]; then
        echo ${javaPath[$i]}
        return
      fi
    else
      if [[ ${javaVersions[$i]} -ge 17 ]]; then
        echo ${javaPath[$i]}
        return
      fi
    fi
  done
}


function buildVersions() {
  echo " "
  echo -e "\u001B[92mYou selected the following versions: \u001B[93m${selectedMCVersions[@]}\u001B[0m"

  # Find .m2 folder
  # Trouver le dossier .m2
  m2Folder=$(find ~/.m2 -type d -name "repository")

  if [ -z "$m2Folder" ]; then
    echo " "
    echo -e "\u001B[91m[Error] No .m2 folder found. Maven is not installed or not configured correctly.\u001B[0m"
    pressKeyAndExit 1
  fi

  lastBuildedVersion="1.0.0"

  flags="--remapped --compile spigot --output-dir ./buildsOutput"

  echo " "
  echo -e "\u001B[92mStarting the build process...\u001B[0m"
  echo " "
  echo -e "\u001B[93m⚠ This process can take a very long time depending on your system and your internet speed.\u001B[0m"
  echo -e "\u001B[93m⚠ If you want to see any progress information, restart the script with the -d flag.\u001B[0m"
  echo -e "\u001B[93m⚠ Closing the process unexpectedly can break the build tool.\u001B[0m"
  echo -e "\u001B[93m⚠ If you want close the script, to restart it now, answer 'n' to the next question.\u001B[0m"
  echo " "

  read -p "Are you sure you want to continue ? (y/n) " continueBuild
  if [ "$continueBuild" != "y" ]; then
    pressKeyAndExit 0
  fi

  for ver in "${selectedMCVersions[@]}"; do
    echo -e "\u001B[92mBuilding version \u001B[93m$ver\u001B[0m"

    toCheck=$(echo $ver | cut -d'.' -f1,2)
    if ! canBeBuilt $toCheck; then
      echo -e "\u001B[91m[Error] No JDK found for version $toCheck. Skipping...\u001B[0m"
      continue
    fi
    lastBuildedVersion=$ver
    # Get the path of the JDK
    selectedJDK=$(getJDKPath $toCheck)

    if [ "$debugModeEnabled" == true ]; then
      echo -e "\u001B[90m[DEBUG] Using JDK $selectedJDK for version $toCheck\u001B[0m"
    fi

    if [ -z "$selectedJDK" ]; then
      echo -e "\u001B[91m[Error] No JDK found for version $toCheck. Skipping...\u001B[0m"
      continue
    fi

    # Check force mode
    if [ "$forceDownload" == false ]; then
      if [ -d "$m2Folder/org/spigotmc/spigot/$ver-R0.1-SNAPSHOT" ]; then
        echo -e "\u001B[93mVersion $ver already built. Skipping...\u001B[0m"
        continue
      fi
    fi

    if [ "$debugModeEnabled" == true ]; then
      error_file=$(mktemp)
      "$selectedJDK/java" -jar BuildTools.jar --rev $ver $flags 2> $error_file | sed 's/^/[DEBUG] /'
      checkError $error_file $ver
      rm $error_file
    else
      # Start the animation in a background subshell
      {
        while :; do
          for i in {1..3}; do
            echo -ne "."
            sleep 1
          done
          echo -ne "\b\b\b   \b\b\b"
        done
      } &

      # Save the PID of the subshell to stop it later
      animation_pid=$!

      error_file=$(mktemp)
      "$selectedJDK/java" -jar BuildTools.jar --rev $ver $flags > /dev/null 2> $error_file

      # Stop the animation
      kill $animation_pid > /dev/null 2>&1
      echo -ne "\b\b\b   \b\b\b"

      # Check the error output for any known error messages
      checkError $error_file $ver

      # Delete the temporary error file
      rm $error_file
    fi

    # Delete created files in the output folder
    rm -rf ./buildsOutput
  done

  copyBuiltVersions

}

# Function to ask to continue or abort the process if an error occurs
# Use two parameters, the first is the error file, the second is the version of the build
function checkError() {
  error_file=$1
  version=$2
  if grep -q "Exception in thread" $error_file; then
    echo -e "\u001B[91m[Error] An error occurred while building version $version. Have you ignored the warning and stopped the process ?"
    echo "[Error] Please check the error message below:"
    # Display the error message (after Exception in thread)
    grep -oP "Exception in thread.*$" $error_file
    echo " "
    echo "Having a missing version can cause problems in the future."
    echo -e "\u001B[0m"
    read -p "Do you want to continue the process? (y/n) " continueProcess
    if [ "$continueProcess" != "y" ]; then
      pressKeyAndExit 1
    fi
  fi
}

function copyBuiltVersions() {
    clear
    echo -e "\u001B[92mAll versions have been built. Now copying the jars from the .m2 folder to prepare the merged JAR files.\u001B[0m"
    mkdir -p buildsOutput

    for ver in "${selectedMCVersions[@]}"; do
      toCheck=$(echo $ver | cut -d'.' -f1,2)
      if ! canBeBuilt $toCheck; then
        continue
      fi
      # Copy the jar from the .m2 folder to the output folder
      # Copier les jars du dossier .m2 vers le dossier de sortie
      cp $m2Folder/org/spigotmc/spigot/$ver-R0.1-SNAPSHOT/spigot-$ver-R0.1-SNAPSHOT.jar ./buildsOutput/spigot-$ver-R0.1-SNAPSHOT.jar
      cp $m2Folder/org/spigotmc/spigot/$ver-R0.1-SNAPSHOT/spigot-$ver-R0.1-SNAPSHOT-remapped-mojang.jar ./buildsOutput/spigot-$ver-R0.1-SNAPSHOT-remapped-mojang.jar
      cp $m2Folder/org/spigotmc/spigot/$ver-R0.1-SNAPSHOT/spigot-$ver-R0.1-SNAPSHOT-remapped-obf.jar ./buildsOutput/spigot-$ver-R0.1-SNAPSHOT-remapped-obf.jar
    done

    if [ "$debugModeEnabled" == true ]; then
      echo -e "\u001B[90m[DEBUG] All jars have been copied and are ready for the merge process.\u001B[0m"
    fi
    echo " "

    mergePackages
}

function mergePackages() {
    # Packages to merge
    # Les packages à fusionner
    packages=("org/bukkit/craftbukkit" "net/minecraft")
    # Versions to merge
    # Les versions à fusionner
    versions=("" "-remapped-mojang" "-remapped-obf")
    # Output directory for the merged JAR files
    # Le répertoire de sortie pour les fichiers JAR fusionnés
    outputDir="./mergedJars"
    mkdir -p $outputDir

    # Find the best JDK version to use, if multiple versions are compatible, use the latest one
    # Trouver la meilleure version de JDK à utiliser, si plusieurs versions sont compatibles, utiliser la plus récente
    latestMCVersion=1.16
    for ver in "${selectedMCVersions[@]}"; do
      major=$(echo $ver | cut -d'.' -f1)
      minor=$(echo $ver | cut -d'.' -f2)
      if [[ $major -gt 1 || ($major -eq 1 && $minor -gt 16) ]]; then
        latestMCVersion=$ver
      fi
    done

    # Get the path of the JDK
    # Obtenir le chemin du JDK
    selectedJDK=$(getJDKPath $latestMCVersion)
    selectedJDK="$selectedJDK/jar"

    # Browse each version
    # Parcourir chaque version
    for version in "${versions[@]}"; do

      if [ "$debugModeEnabled" == true ]; then
        echo -e "\u001B[90m[DEBUG] Preparing the merged JAR file for version spigot$version...\u001B[0m"
      else
        echo -e "\u001B[92mMerging the JAR files for version \u001B[93mspigot$version\u001B[92m...\u001B[0m"
      fi

      for mcVersion in "${selectedMCVersions[@]}"; do
        # Copy the content of the jar file to a temporary directory
        # Copier le contenu du fichier jar dans un répertoire temporaire
        tempDir="./temp"
        mkdir -p "$tempDir"
        cd "$tempDir" || exit 1
        "$selectedJDK" xf "../buildsOutput/spigot-$mcVersion-R0.1-SNAPSHOT$version.jar"
        cd - > /dev/null
      done

      # Keep only interesting folders (packages)
      # Ne conserver que les dossiers intéressants (packages)
      if [ "$debugModeEnabled" == true ]; then
        echo -e "\u001B[90m[DEBUG] Merging the following packages: ${packages[@]}\u001B[0m"
      fi
      for package in "${packages[@]}"; do
        mkdir -p "$outputDir/spigot$version/$package"

        if [ "$debugModeEnabled" == true ]; then
          cp -rv "$tempDir/$package/." "$outputDir/spigot$version/$package/" | sed 's/^/[DEBUG] /'
        else
          cp -r "$tempDir/$package/." "$outputDir/spigot$version/$package/"
        fi
      done

      # Delete the temporary directory
      # Supprimer le répertoire temporaire
      rm -rf "$tempDir"
    done

    # Detect MC Version for naming
    # Détecter la version MC pour le nommage
    # 1.16-R0.1-SNAPSHOT => 1.16.x
    # ALLINONE-R0.1-SNAPSHOT => 1.16.x -> 1.x.x
    # ALLINONE-MODERN-R0.1-SNAPSHOT) => 1.18.x -> 1.x.x
    # ALLINONE-OLD-R0.1-SNAPSHOT => 1.16.x -> 1.17.x

    compiledVersion=-1
    artifactName="UNDEFINED"
    for ver in "${selectedMCVersions[@]}"; do
      minor=$(echo $ver | cut -d'.' -f2)
      echo "Minor: $minor - Compiled: $compiledVersion - Artifact: $artifactName"
      if [ $compiledVersion -eq -1 ]; then
        if canBeBuilt $(echo $ver | cut -d'.' -f1,2); then
          compiledVersion=$minor
          artifactName=$ver
        fi
      elif [ $compiledVersion -ne $minor ]; then
        if canBeBuilt $(echo $ver | cut -d'.' -f1,2); then
          if [ $compiledVersion -le 17 ]; then
            if [ $minor -le 17 ]; then
              artifactName="ALLINONE-OLD"
            else
              artifactName="ALLINONE"
              break # No need to continue
            fi
          else
            if [ $minor -lt 18 ]; then
              artifactName="ALLINONE"
              break # No need to continue
            else
              artifactName="ALLINONE-MODERN"
            fi
          fi
        fi
      fi
    done

    # Compile the merged JAR files
    # Compiler les fichiers JAR fusionnés
    for version in "${versions[@]}"; do
      echo " "
      echo -e "\u001B[92mCompiling the merged JAR file for version \u001B[93mspigot-$artifactName-R0.1-SNAPSHOT$version...\u001B[0m"
      cd "$outputDir/spigot$version" || exit 1
      "$selectedJDK" cf "../spigot-$artifactName-R0.1-SNAPSHOT$version.jar" .
      cd - > /dev/null
      rm -rf "$outputDir/spigot$version"
    done

    clear

    echo -e "\u001B[92mAll merged JAR files have been compiled."
    echo " "
    echo "The merged JAR files are available in the $outputDir folder."
    echo -e "To import them into your project easily, we can create a Maven repository for you.\u001B[0m"
    read -p "Do you want to create a Maven repository for the merged JAR files ? (y/n) " createMaven
    if [ "$createMaven" == "y" ]; then
      createMavenRepository
    fi
}

function createMavenRepository() {
    # Copy the merged JAR to .m2 folder
    # Copier le JAR fusionné dans le dossier .m2
    mkdir -p "$m2Folder/fr/foxelia/spigot/$artifactName-R0.1-SNAPSHOT"
    cp "$outputDir/spigot-$artifactName-R0.1-SNAPSHOT.jar" "$m2Folder/fr/foxelia/spigot/$artifactName-R0.1-SNAPSHOT/spigot-$artifactName-R0.1-SNAPSHOT.jar"
    cp "$outputDir/spigot-$artifactName-R0.1-SNAPSHOT-remapped-mojang.jar" "$m2Folder/fr/foxelia/spigot/$artifactName-R0.1-SNAPSHOT/spigot-$artifactName-R0.1-SNAPSHOT-remapped-mojang.jar"
    cp "$outputDir/spigot-$artifactName-R0.1-SNAPSHOT-remapped-obf.jar" "$m2Folder/fr/foxelia/spigot/$artifactName-R0.1-SNAPSHOT/spigot-$artifactName-R0.1-SNAPSHOT-remapped-obf.jar"

    # Download pom.xml from the github repository
    # Télécharger le pom.xml du dépôt github
    curl -o pom.xml https://raw.githubusercontent.com/FoxeliaFR/spigot-nms-all-in-one/master/pom-example.xml

    # Replace values in the pom.xml file
    # Remplacer les valeurs dans le fichier pom.xml
    # ${artifactName} => artifactName
    # ${lastCompiledVersion} => lastBuildedVersion
    # ${latestMCVersion} => lastBuildedVersion m2 pom <minecraft_version> value
    sed -i "s/\${artifactName}/$artifactName/g" pom.xml
    sed -i "s/\${lastCompiledVersion}/$lastBuildedVersion/g" pom.xml
    sed -i "s/\${latestMCV}/$(grep -oPm1 "(?<=<minecraft_version>)[^<]+" $m2Folder/org/spigotmc/spigot/$lastBuildedVersion-R0.1-SNAPSHOT/spigot-$lastBuildedVersion-R0.1-SNAPSHOT.pom)/g" pom.xml

    # Move the pom.xml file to the .m2 folder
    # Déplacer le fichier pom.xml dans le dossier .m2
    mv pom.xml "$m2Folder/fr/foxelia/spigot/$artifactName-R0.1-SNAPSHOT/spigot-$artifactName-R0.1-SNAPSHOT.pom"

    clear

    echo -e "\u001B[92mThe Maven repository has been created at \u001B[93m$m2Folder/fr/foxelia/spigot/$artifactName-R0.1-SNAPSHOT"
    echo -e "\u001B[92mYou can now use the following dependency in your project:"
    echo " "
    echo -e "\u001B[33m<dependency>"
    echo "    <groupId>fr.foxelia.spigot</groupId>"
    echo "    <artifactId>spigot</artifactId>"
    echo "    <version>${artifactName}-R0.1-SNAPSHOT</version>"
    echo "</dependency>"
    echo -e "\u001B[92m"
    echo -e "To free up space, we can delete the merged JAR files.\u001B[0m"
    read -p "Do you want to delete the merged JAR files ? (y/n) " deleteMergedJars
    if [ "$deleteMergedJars" == "y" ]; then
      rm -rf $outputDir
      if [ "$debugModeEnabled" == true ]; then
        echo " "
        echo -e "\u001B[90m[DEBUG] Merged JAR files have been deleted.\u001B[0m"
        echo " "
      fi
    fi
}

echo -e "\033[38;5;208m                     ____  __  _  _\033[38;5;15m  ____  __    __   __  "
echo -e "\033[38;5;208m                    (  __)/  \( \/ )\033[38;5;15m(  __)(  )  (  ) / _\ "
echo -e "\033[38;5;208m                     ) _)(  O ))  ( \033[38;5;15m ) _) / (_/\ )( /    \\"
echo -e "\033[38;5;208m                    (__)  \__/(_/\_)\033[38;5;15m(____)\____/(__)\_/\_/"
echo -e "\033[38;5;2m"
echo " _____ _____ _____    _____ __    __       _____ _____    _____ _____ _____ "
echo "|   | |     |   __|  |  _  |  |  |  |     |     |   | |  |     |   | |   __|"
echo "| | | | | | |__   |  |     |  |__|  |__   |-   -| | | |  |  |  | | | |   __|"
echo "|_|___|_|_|_|_____|  |__|__|_____|_____|  |_____|_|___|  |_____|_|___|_____|"
echo -e "\u001B[92m"
echo "Welcome to the Spigot NMS All-In-One build script."
echo -e "\033[0m"

# Detect user start flags
# Détection des flags de démarrage de l'utilisateur
# --help : Display help
# -d : Debug mode
# -f : Force mode

if [ "$1" == "--help" ]; then
  echo " "
  echo "Usage: ./run.sh [flags]"
  echo " "
  echo "Flags:"
  echo "  --help : Display help"
  echo "  -d : Debug mode"
  echo "  -f : Force mode (rebuild all versions)"
  echo " "
  pressKeyAndExit 0
fi

if [ "$1" == "-d" ]; then
  debugModeEnabled=true
fi

if [ "$1" == "-f" ]; then
  forceDownload=true
fi

checkOS
getJDKVersions
downloadBuildTools
detectMCVersions

echo -e "\u001B[91m"
echo "Old Minecraft Versions need to have a specific JDK Version to build."
echo "MC Versions 1.16 require JDK 8 or 16."
echo "MC Versions 1.17 require JDK 16."
echo "MC Versions 1.18+ require JDK 17 or higher."
echo -e "If you haven't the correct JDK installed, the build will be skipped.\u001B[0m"

selectMCVersion

echo " "
echo " "
echo " "
echo -e "\u001B[92mThank you for using the Spigot NMS All-In-One build script."
echo -e "Created by the \u001B[33mFox\u001B[97melia\u001B[92m Team (\u001B[34m\u001B[4mhttps://foxelia.fr\u001B[0m\u001B[92m)"
echo -e "Have a nice day ! ;)\u001B[0m"

pressKeyAndExit 0
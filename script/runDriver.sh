#!/usr/bin/env bash

show_help() {
    echo "usage: $0 [--get] [--analyze] [--ios] [--apk] [--driver] [--clean] [<path to app package>]

Tool for managing CI builds.
(run from root of repo)

where:
    --get
        gets all dependencies
    --analyze
        analyzes dart code for all packages
    --ios
        builds ios release for all apps
    --apk
        builds android release for all apps
    --driver
        runs flutter driver for all apps
        (requires a single running emulator/simulator)
    --clean
        cleans all builds
    <path to app package>
        runs flutter driver for app at path
"
    exit 1
}

# runs integration tests for a package that has a lib/main.dart
runDriver () {
    cd $1
    if [ -f "lib/main.dart" ]; then
        echo "running driver in $1"
        # check if build_runner needs to be run
        # todo: fix build_runner in ./example/built_redux
        if grep build_runner pubspec.yaml > /dev/null  && [ "$1" != "./example/built_redux" ]; then
            flutter packages get
            flutter packages pub run build_runner build --delete-conflicting-outputs
        fi
            # todo: get input on MVU project to run with driver for screen i/o
            flutter driver test_driver/todo_app.dart
    fi
}

runGet() {
    cd $1;
    if [ -f "pubspec.yaml" ]; then
        flutter packages get
    fi
}

runAnalyze() {
    cd $1;
    if [ -f "pubspec.yaml" ]; then
        flutter analyze
    fi
}

runIos() {
    cd $1;
    if [ -f "lib/main.dart" ]; then
        flutter build ios
    fi
}

runApk() {
    cd $1;
    if [ -f "lib/main.dart" ]; then
        flutter build apk
    fi
}

runClean() {
    cd $1;
    if [ -f "pubspec.yaml" ]; then
        echo "running clean in $1"
        flutter clean
        rm -rf ios/Pods ios/Podfile.lock
    fi
}

export -f runDriver
export -f runGet
export -f runAnalyze
export -f runIos
export -f runApk
export -f runClean

if [ -z $1 ]; then show_help; exit 1; fi

case $1 in
    --get)
        find . -maxdepth 2 -type d -exec bash -c 'runGet "$0"' {} \;
        ;;
    --analyze)
        find . -maxdepth 2 -type d -exec bash -c 'runAnalyze "$0"' {} \;
        ;;
    --ios)
        find . -maxdepth 2 -type d -exec bash -c 'runIos "$0"' {} \;
        ;;
    --apk)
        find . -maxdepth 2 -type d -exec bash -c 'runApk "$0"' {} \;
        ;;
    --driver)
        find . -maxdepth 2 -type d -exec bash -c 'runDriver "$0"' {} \;
        ;;
    --clean)
        find . -maxdepth 2 -type d -exec bash -c 'runClean "$0"' {} \;
        ;;
    *)
        if [[ -d "$1" ]]; then
            runDriver $1
        else
            echo "Error: not a directory"
            show_help
        fi
        ;;
esac
# DMQ

DMQ is a simple tool to return the top 5 latest changelists and their results for each platform for any devmain lab branch. 

## Installation

```c#
nuget sources add -name <name> -source <path>
nuget install <packageID>
```
Or run exe from folder

## Usage

```cmd
dmq labxx [returns top 5 and last successful change]
dmq labxx top [returns only the most recent cl and its progress]
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
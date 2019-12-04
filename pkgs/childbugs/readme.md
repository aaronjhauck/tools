# ChildBugs

ChildBugs is a tool used to create a hierarchical relationship with a parent devmain bug to a child FFD bug.

## Installation

```c#
nuget sources add -name <name> -source <path>
nuget install <packageID>
```
Or run exe from folder

## Usage

```cmd
childbugs -b <bugID> -f [CSV of Forks] -p <projectName>
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
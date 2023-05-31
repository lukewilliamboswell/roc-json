
# Json Package for Roc 🤘


## Example 

Try running some of the examples using Roc cli.

```sh
$ roc run examples/simple.roc 
Successfully decoded image, title:"View from 15th Floor"
```

## Documentation

[Coming soon]

## Package URL Release

You can use the package as a URL release in your Roc project. For example, in your `main.roc` file you can reference the json package like so.

```roc
app "example"
    packages {
        cli: "https://github.com/roc-lang/basic-cli/releases/download/0.3.2/tE4xS_zLdmmxmHwHih9kHWQ7fsXtJr7W7h3425-eZFk.tar.br",
        json: "",
    }
    ...
```
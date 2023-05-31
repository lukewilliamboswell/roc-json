
# Json Package for Roc 🤘

## Example 

Try running some of the examples using Roc cli.

```sh
$ roc run examples/simple.roc 
Successfully decoded image, title:"View from 15th Floor"
```

## Documentation

See [https://lukewilliamboswell.github.io/roc-json/](https://lukewilliamboswell.github.io/roc-json/)

Alternatively, you can also generate docs locally using `roc docs package/main.roc` and then serve the html files. 

## Package URL Release

You can use the release URL package in your Roc app. In your `app.roc` file you can import the json package like so.

```roc
app "example"
    packages {
        cli: "https://github.com/roc-lang/basic-cli/releases/download/0.3.2/tE4xS_zLdmmxmHwHih9kHWQ7fsXtJr7W7h3425-eZFk.tar.br",
        json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.1.0/xbO9bXdHi7E9ja6upN5EJXpDoYm7lwmJ8VzL7a5zhYE.tar.br",
    }
    ...
```

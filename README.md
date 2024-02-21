
# Json Package for Roc 🤘

:warning: `--linker=legacy` is necessary for this package because of [this roc issue](https://github.com/roc-lang/roc/issues/3609) 

## Example 

```sh
$ roc run examples/simple1.roc --linker=legacy
Successfully decoded image, title:"View from 15th Floor"
```

## Documentation

See [https://lukewilliamboswell.github.io/roc-json/](https://lukewilliamboswell.github.io/roc-json/)

Alternatively, generate docs locally using `roc docs package/main.roc` and then serve the html files. 

## Package URL Release

You can use the release URL package in your Roc app. In your `app.roc` file you can import the json package like so.

```roc
app "example"
    packages {
        cli: "https://github.com/roc-lang/basic-cli/releases/download/[REPLACE WITH RELEASE URL].tar.br",
        json: "https://github.com/lukewilliamboswell/roc-json/releases/download/[REPLACE WITH RELEASE URL].tar.br",
    }
    ...
```

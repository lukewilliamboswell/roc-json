
# Json Package for Roc 🤘

## Example 

Try running some of the examples using Roc cli.

```sh
$ roc run examples/simple1.roc 
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
        cli: "https://github.com/roc-lang/basic-cli/releases/download/0.5.0/Cufzl36_SnJ4QbOoEmiJ5dIpUxBvdB3NEySvuH82Wio.tar.br",
        json: "https://github.com/lukewilliamboswell/roc-json/releases/download/v0.3.0/y2bZ-J_3aq28q0NpZPjw0NC6wghUYFooJpH03XzJ3Ls.tar.br",
    }
    ...
```

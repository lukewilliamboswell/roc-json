app "simple1"
    packages {
        cli: "https://github.com/roc-lang/basic-cli/releases/download/0.8.1/x8URkvfyi9I0QhmVG98roKBUs_AZRkLFwFJVJ3942YA.tar.br",
        json: "../package/main.roc", # use release URL (ends in tar.br) for local example, see github.com/lukewilliamboswell/roc-json/releases
    }
    imports [
        cli.Stdout,
        json.Core.{ json },
        Decode.{ fromBytesPartial },
    ]
    provides [main] to cli

main =
    bytes = Str.toUtf8 "[ [ 123,\n\"apples\" ], [  456,  \"oranges\" ]]"

    decoded : DecodeResult (List FruitCount)
    decoded = fromBytesPartial bytes json

    when decoded.result is
        Ok tuple -> Stdout.line "Successfully decoded tuple, got \(toStr tuple)"
        Err _ -> crash "Error, failed to decode image"

FruitCount : (U32, Str)

toStr : List FruitCount -> Str
toStr = \fcs ->
    fcs
    |> List.map \(count, fruit) -> "\(fruit):\(Num.toStr count)"
    |> Str.joinWith ", "

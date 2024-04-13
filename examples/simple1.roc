app "simple1"
    packages {
        cli: "https://github.com/roc-lang/basic-cli/releases/download/0.9.0/oKWkaruh2zXxin_xfsYsCJobH1tO8_JvNkFzDwwzNUQ.tar.br",
        json: "../package/main.roc", # use release URL (ends in tar.br) for local example, see github.com/lukewilliamboswell/roc-json/releases
    }
    imports [
        cli.Stdout,
        json.Core.{ jsonWithOptions },
        #Decode.{ DecodeResult, fromBytesPartial },
    ]
    provides [main] to cli

main =
    #requestBody = Str.toUtf8 "{\"Image\":{\"Animated\":false,\"Height\":600,\"Ids\":[116,943,234,38793],\"Thumbnail\":{\"Height\":125,\"Url\":\"http:\\/\\/www.example.com\\/image\\/481989943\",\"Width\":100},\"Title\":\"View from 15th Floor\",\"Width\":800}}"
    requestBody = Str.toUtf8 "{\"Image\":{\"Height\":600}}"

    # decoder = jsonWithOptions { fieldNameMapping: PascalCase }

    Stdout.line "done"

    # decoded : DecodeResult ImageRequest
    # decoded = fromBytesPartial requestBody decoder

    # when decoded.result is
    #     Ok record -> Stdout.line "Successfully decoded image, title:\"\(Num.toStr record.image.height)\""
    #     Err _ -> crash "Error, failed to decode image"

ImageRequest : {
    image : {
        height : I64,
    },
}

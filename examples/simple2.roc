app [main] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br",
    json: "../package/main.roc", # use release URL (ends in tar.br) for local example, see github.com/lukewilliamboswell/roc-json/releases
}

import cli.Stdout
import json.Json
import "data.json" as request_body : List U8

main =
    decoder = Json.utf8_with({})

    decoded : Decode.DecodeResult (List DataRequest)
    decoded = Decode.from_bytes_partial(request_body, decoder)

    when decoded.result is
        Ok(list) ->
            Stdout.line!("Successfully decoded list")

            when List.get(list, 0) is
                Ok(rec) -> Stdout.line!("Name of first person is: $(rec.lastname)")
                Err(_) -> Stdout.line!("Error occurred in List.get")

        Err(TooShort) -> Stdout.line!("A TooShort error occurred")

DataRequest : {
    id : I64,
    firstname : Str,
    lastname : Str,
    email : Str,
    gender : Str,
    ipaddress : Str,
}

# =>
# Successfully decoded list
# Name of first person is: Penddreth

app "json-basic"
    packages {
        cli: "https://github.com/roc-lang/basic-cli/releases/download/0.4.0/DI4lqn7LIZs8ZrCDUgLK-tHHpQmxGF1ZrlevRKq5LXk.tar.br",
        json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.1.0/xbO9bXdHi7E9ja6upN5EJXpDoYm7lwmJ8VzL7a5zhYE.tar.br",
    }
    imports [
        cli.Stdout,
        cli.Task.{ await },
        json.Core.{ jsonWithOptions },
        Decode.{ DecodeResult, fromBytesPartial },
        "data.json" as requestBody : List U8, 
    ]
    provides [main] to cli

main =
    decoder = jsonWithOptions { }
    decoded : DecodeResult (List DataRequest)
    decoded = fromBytesPartial requestBody decoder

    when decoded.result is
        Ok list -> 
            _ <- Stdout.line "Successfully decoded list" |> Task.await
            rec1 = List.get list 0
            when rec1 is
                Ok rec -> Stdout.line "Name of first person is: \(rec.lastname)"
                Err _  -> Stdout.line "Error occurred in List.get"
        Err TooShort -> Stdout.line "A TooShort error occurred"
    
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
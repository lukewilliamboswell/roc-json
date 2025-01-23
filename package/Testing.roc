module []

import Json

Option val := [None, Some val]
    implements [
        Eq,
        Decoding {
            decoder: option_decode,
        },
        Encoding {
            to_encoder: option_to_encode,
        },
    ]
none = |{}| @Option(None)
some = |a| @Option(Some(a))

option_to_encode = |@Option(val)|
    Encode.custom(
        |bytes, fmt|
            when val is
                Some(contents) -> bytes |> Encode.append(contents, fmt)
                None -> bytes,
    )

# Encode Option none
expect
    encoded =
        dat : Option U8
        dat = @Option(None)
        Encode.to_bytes(dat, Json.utf8)
        |> Str.from_utf8

    expected = Ok("")
    expected == encoded
# Encode Option None record
expect
    encoded =
        dat : { maybe : Option U8, other : Str }
        dat = { maybe: none({}), other: "hi" }
        Encode.to_bytes(dat, Json.utf8_with({ empty_encode_as_null: Json.encode_as_null_option({ record: Bool.false }) }))
        |> Str.from_utf8

    expected = Ok(
        """
        {"other":"hi"}
        """,
    )
    expected == encoded
# Encode Option Some record
expect
    encoded =
        { maybe: some(10) }
        |> Encode.to_bytes(Json.utf8)
        |> Str.from_utf8

    expected = Ok(
        """
        {"maybe":10}
        """,
    )
    expected == encoded
# Encode Option list
expect
    encoded =
        dat = [some(1), none({}), some(2), some(3)]
        Encode.to_bytes(dat, Json.utf8)
        |> Str.from_utf8

    expected = Ok("[1,2,3]")
    expected == encoded

# Encode Option None record with null
expect
    encoded =
        dat : { maybe : Option U8, other : Str }
        dat = { maybe: none({}), other: "hi" }
        Encode.to_bytes(dat, Json.utf8)
        |> Str.from_utf8

    expected = Ok(
        """
        {"maybe":null,"other":"hi"}
        """,
    )
    expected == encoded
# Encode Option tuple
expect
    encoded =
        dat : (U8, Option U8, Option Str, Str)
        dat = (10, none({}), some("opt"), "hi")
        Encode.to_bytes(dat, Json.utf8)
        |> Str.from_utf8

    expected = Ok(
        """
        [10,null,"opt","hi"]
        """,
    )
    expected == encoded
# Encode Option list
expect
    encoded =
        dat = [some(1), none({}), some(2), some(3)]
        Encode.to_bytes(dat, Json.utf8_with({ empty_encode_as_null: Json.encode_as_null_option({ list: Bool.true }) }))
        |> Str.from_utf8

    expected = Ok("[1,null,2,3]")
    expected == encoded

option_decode = Decode.custom(
    |bytes, fmt|
        if bytes |> List.len == 0 then
            { result: Ok(@Option(None)), rest: [] }
        else
            when bytes |> Decode.decode_with(Decode.decoder, fmt) is
                { result: Ok(res), rest } -> { result: Ok(@Option(Some(res))), rest }
                { result: Err(a), rest } -> { result: Err(a), rest },
)

# Now I can try to modify the json decoding to try decoding every type with a zero byte buffer and see if that will decode my field
OptionTest : { y : U8, maybe : Option U8 }
expect
    decoded : Result OptionTest _
    decoded =
        """
        {"y":1}
        """
        |> Str.to_utf8
        |> Decode.from_bytes(Json.utf8)

    expected = Ok({ y: 1u8, maybe: none({}) })
    is_good =
        when (decoded, expected) is
            (Ok(a), Ok(b)) ->
                a == b

            _ -> Bool.false
    is_good == Bool.true

OptionTest2 : { maybe : Option U8 }
expect
    decoded : Result OptionTest2 _
    decoded =
        """
        {"maybe":1}
        """
        |> Str.to_utf8
        |> Decode.from_bytes(Json.utf8)

    expected = Ok({ maybe: some(1u8) })
    expected == decoded
# Decode option list
expect
    decoded =
        "[1,2,3]"
        |> Str.to_utf8
        |> Decode.from_bytes(Json.utf8)

    expected = Ok([some(1), some(2), some(3)])
    expected == decoded

# Decode Option Tuple
expect
    decoded : Result (Option U8, Option U8, Option U8) _
    decoded =
        "[1,null,2]"
        |> Str.to_utf8
        |> Decode.from_bytes(Json.utf8)
    expected = Ok((some(1), none({}), some(2)))
    expected == decoded

# null decode
expect
    decoded : Result OptionTest _
    decoded =
        """
        {"y":1,"maybe":null}
        """
        |> Str.to_utf8
        |> Decode.from_bytes(Json.utf8)

    expected = Ok({ y: 1u8, maybe: none({}) })
    is_good =
        when (decoded, expected) is
            (Ok(a), Ok(b)) ->
                a == b

            _ -> Bool.false
    is_good == Bool.true

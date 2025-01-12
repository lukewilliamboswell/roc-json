module [
    split_camel,
    split_pascal,
]

is_lower_case : U8 -> Bool
is_lower_case = \byte ->
    'a' <= byte && byte <= 'z'

is_digit : U8 -> Bool
is_digit = \byte ->
    '0' <= byte && byte <= '9'

is_upper_case : U8 -> Bool
is_upper_case = \byte ->
    'A' <= byte && byte <= 'Z'

# CascalCase is also known as "Lower" CamelCase
# Input must be ASCII -- not checked here as this is an internal helper
split_camel : Str -> Result (List Str) [InvalidCamel]
split_camel = \str ->
    ascii_bytes = Str.to_utf8(str)
    ascii_bytes_len = List.len(ascii_bytes)

    segment_indexes : Result (List _) _
    segment_indexes =
        when List.walk_with_index(ascii_bytes, StartCamel, split_camel_help) is
            Invalid -> Err(InvalidCamel)
            StartCamel | StartPascal -> Ok([]) # an empty string was passed in
            Upper(start, indexes) -> Ok(List.append(indexes, { start, len: ascii_bytes_len }))
            Number(start, indexes) -> Ok(List.append(indexes, { start, len: ascii_bytes_len }))
            Lower(start, indexes) -> Ok(List.append(indexes, { start, len: ascii_bytes_len }))

    slices =
        segment_indexes?
        |> List.map(
            \{ start, len } ->
                List.sublist(ascii_bytes, { start, len }),
        )
        |> List.keep_oks(Str.from_utf8)

    Ok(slices)

# PascalCase is also known as "Upper" CamelCase
# Input must be ASCII -- not checked here as this is an internal helper
split_pascal : Str -> Result (List Str) [InvalidPascal]
split_pascal = \str ->
    ascii_bytes = Str.to_utf8(str)
    ascii_bytes_len = List.len(ascii_bytes)

    segment_indexes : Result (List _) _
    segment_indexes =
        when List.walk_with_index(ascii_bytes, StartPascal, split_camel_help) is
            Invalid -> Err(InvalidPascal)
            StartCamel | StartPascal -> Ok([]) # an empty string was passed in
            Upper(start, indexes) -> Ok(List.append(indexes, { start, len: ascii_bytes_len }))
            Number(start, indexes) -> Ok(List.append(indexes, { start, len: ascii_bytes_len }))
            Lower(start, indexes) -> Ok(List.append(indexes, { start, len: ascii_bytes_len }))

    slices =
        segment_indexes?
        |> List.map(
            \{ start, len } ->
                List.sublist(ascii_bytes, { start, len }),
        )
        |> List.keep_oks(Str.from_utf8)

    Ok(slices)

SplitCaseState : [
    StartCamel,
    StartPascal,
    Upper U64 (List { start : U64, len : U64 }),
    Number U64 (List { start : U64, len : U64 }),
    Lower U64 (List { start : U64, len : U64 }),
    Invalid,
]

split_camel_help : SplitCaseState, U8, U64 -> SplitCaseState
split_camel_help = \state, byte, index ->
    when state is
        Invalid -> Invalid
        StartCamel if is_lower_case(byte) -> Lower(index, [])
        StartPascal if is_upper_case(byte) -> Upper(index, [])
        StartCamel | StartPascal -> Invalid # must start with an Uppercase letter
        Upper(start, indexes) if is_upper_case(byte) -> Upper(start, indexes)
        Upper(start, indexes) if is_digit(byte) -> Number(start, indexes)
        Upper(start, indexes) if is_lower_case(byte) ->
            if (index - start) > 1 then
                Lower(index - 1, List.append(indexes, { start, len: index - start - 1 }))
            else
                Lower(start, indexes)

        Number(start, indexes) if is_digit(byte) -> Number(start, indexes)
        Number(start, indexes) if is_lower_case(byte) -> Lower(start, indexes)
        Number(start, indexes) if is_upper_case(byte) -> Upper(index, List.append(indexes, { start, len: index - start }))
        Lower(start, indexes) if is_lower_case(byte) -> Lower(start, indexes)
        Lower(start, indexes) if is_digit(byte) -> Number(start, indexes)
        Lower(start, indexes) if is_upper_case(byte) -> Upper(index, List.append(indexes, { start, len: index - start }))
        _ -> Invalid

expect
    expected = Ok(["Foo", "Bar"])
    result = split_pascal("FooBar")
    result == expected

expect
    expected = Ok(["foo", "Bar"])
    result = split_camel("fooBar")
    result == expected

expect
    expected = Err(InvalidCamel)
    result = split_camel("FooBar")
    result == expected

expect
    expected = Err(InvalidPascal)
    result = split_pascal("abc")
    result == expected

expect
    expected = Ok(["FOO", "Bar"])
    result = split_pascal("FOOBar")
    result == expected

expect
    expected = Ok(["FOO", "Bar", "BAZ"])
    result = split_pascal("FOOBarBAZ")
    result == expected

expect
    expected = Ok(["foo", "Bar", "BAZ"])
    result = split_camel("fooBarBAZ")
    result == expected

expect
    expected = Ok(["ABC"])
    result = split_pascal("ABC")
    result == expected

expect
    expected = Ok(["Foo123", "Bar"])
    result = split_pascal("Foo123Bar")
    result == expected

expect
    expected = Ok([])
    result = split_pascal("")
    result == expected

expect
    expected = Ok(["f", "OO", "Bar", "BAZ"])
    result = split_camel("fOOBarBAZ")
    result == expected

expect split_pascal("123Foo") == Err(InvalidPascal)
expect split_camel("123foo") == Err(InvalidCamel)

expect split_pascal("Foo123Bar456Baz") == Ok(["Foo123", "Bar456", "Baz"])
expect split_camel("foo123Bar456Baz") == Ok(["foo123", "Bar456", "Baz"])

expect split_pascal("XMLHttpRequest") == Ok(["XML", "Http", "Request"])
expect split_camel("parseXMLHttpRequest") == Ok(["parse", "XML", "Http", "Request"])

expect split_pascal("Foo_Bar") == Err(InvalidPascal)
expect split_camel("foo_bar") == Err(InvalidCamel)
expect split_pascal("FööBar") == Err(InvalidPascal)
expect split_camel("fööBar") == Err(InvalidCamel)

expect split_pascal("A") == Ok(["A"])
expect split_camel("a") == Ok(["a"])

expect split_pascal("FooBAR123baz") == Ok(["Foo", "BAR123baz"])
expect split_camel("fooBAR123baz") == Ok(["foo", "BAR123baz"])

expect split_pascal("Foo1Bar") == Ok(["Foo1", "Bar"])
expect split_camel("foo1Bar") == Ok(["foo1", "Bar"])

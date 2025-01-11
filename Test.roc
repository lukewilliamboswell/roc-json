module [Test]

Test := {
    result : Result { lower_case : Str } [TooShort],
}
    implements [Eq, Decoding]

expect @Test({ result: Ok({ lower_case: "1" }) }) == @Test({ result: Ok({ lower_case: "1" }) })

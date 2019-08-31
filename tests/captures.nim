import unittest
import npeg
import json
  
{.push warning[Spacing]: off.}


suite "captures":

  test "string captures":
    doAssert     patt(>1).match("ab").captures == @["a"]
    doAssert     patt(>(>1)).match("ab").captures == @["a", "a"]
    doAssert     patt(>1 * >1).match("ab").captures == @["a", "b"]
    doAssert     patt(>(>1 * >1)).match("ab").captures == @["ab", "a", "b"]
    doAssert     patt(>(>1 * >1)).match("ab").captures == @["ab", "a", "b"]

  test "action captures":
    var a: string
    let p = peg "foo":
      foo <- >1:
        a = $1
    doAssert p.match("a").ok
    doassert a == "a"
  
  test "action captures with typed parser":

    type Thing = object
      word: string
      number: int

    let s = peg("foo", userdata: Thing):
      foo <- word * number
      word <- >+Alpha:
        userdata.word = $1
      number <- >+Digit:
        userdata.number = parseInt($1)

    var t = Thing()
    doAssert s.match("foo123", t).ok == true
    doAssert t.word == "foo"
    doAssert t.number == 123

  test "JSON captures":
    doAssert patt(Js(1)).match("a").capturesJSon == parseJson(""" "a" """)
    doAssert patt(Jb(+1)).match("true").capturesJSon == parseJson(""" true """)
    doAssert patt(Jb(+1)).match("false").capturesJSon == parseJson(""" false """)
    doAssert patt(Ji(+1)).match("42").capturesJSon == parseJson(""" 42 """)
    doAssert patt(Jf(+1)).match("3.14").capturesJSon == parseJson(""" 3.14 """)
    doAssert patt(Js(1) * Js(1)).match("ab").capturesJSon == parseJson(""" "b" """)
    doAssert patt(Ja(Js(1) * Js(1))).match("ab").capturesJSon == parseJson(""" ["a", "b"] """)
    doAssert patt(Jo(Jf("one", Js(1))) ).match("ab").capturesJSon == parseJson(""" { "one":"a" } """)
    doAssert patt(Jo(Jf("one", Js(1)) * Jf("two", Js(1))) ).match("ab").capturesJSon == 
      parseJson(""" { "one":"a", "two":"b" } """)



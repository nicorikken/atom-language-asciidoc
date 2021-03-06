describe "AsciiDoc grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-asciidoc")

    runs ->
      grammar = atom.grammars.grammarForScopeName("source.asciidoc")

  # convenience function during development
  debug = (tokens) ->
    console.log(JSON.stringify(tokens, null, '\t'))

  it "parses the grammar", ->
    expect(grammar).toBeDefined()
    expect(grammar.scopeName).toBe "source.asciidoc"

  describe "Should tokenizes *bold* text", ->

    it "when constrained *bold* text", ->
      {tokens} = grammar.tokenizeLine("this is *bold* text")
      expect(tokens[0]).toEqual value: "this is ", scopes: ["source.asciidoc"]
      expect(tokens[1]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[2]).toEqual value: "bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[3]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[4]).toEqual value: " text", scopes: ["source.asciidoc"]

    it "when unconstrained **bold** text", ->
      {tokens} = grammar.tokenizeLine("this is**bold**text")
      expect(tokens[0]).toEqual value: "this is", scopes: ["source.asciidoc"]
      expect(tokens[1]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[2]).toEqual value: "bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[3]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[4]).toEqual value: "text", scopes: ["source.asciidoc"]

    it "when unconstrained **bold** text with asterisks", ->
      {tokens} = grammar.tokenizeLine("this is**bold*text**")
      expect(tokens[0]).toEqual value: "this is", scopes: ["source.asciidoc"]
      expect(tokens[1]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[2]).toEqual value: "bold*text", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[3]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]

    it "when multi-line constrained *bold* text", ->
      tokens = grammar.tokenizeLines("""
                                      this is *multi-
                                      line bold* text
                                      """)
      expect(tokens[0][0]).toEqual value: "this is ", scopes: ["source.asciidoc"]
      expect(tokens[0][1]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[0][2]).toEqual value: "multi-", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[1][0]).toEqual value: "line bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[1][1]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[1][2]).toEqual value: " text", scopes: ["source.asciidoc"]

    it "when multi-line constrained *bold* text closes on a new line", ->
      tokens = grammar.tokenizeLines("""
                                      this is *multi-
                                      line bold
                                      * text
                                      """)
      expect(tokens[0][0]).toEqual value: "this is ", scopes: ["source.asciidoc"]
      expect(tokens[0][1]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[0][2]).toEqual value: "multi-", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[1][0]).toEqual value: "line bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[2][0]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[2][1]).toEqual value: " text", scopes: ["source.asciidoc"]

    it "when multi-line unconstrained **bold** text", ->
      tokens = grammar.tokenizeLines("""
                                      this is**multi-
                                      line bold**text
                                      """)
      expect(tokens[0][0]).toEqual value: "this is", scopes: ["source.asciidoc"]
      expect(tokens[0][1]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[0][2]).toEqual value: "multi-", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[1][0]).toEqual value: "line bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[1][1]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[1][2]).toEqual value: "text", scopes: ["source.asciidoc"]

    it "when multi-line unconstrained **bold** text closes on a new line", ->
      tokens = grammar.tokenizeLines("""
                                      this is**multi-
                                      line bold
                                      **text
                                      """)
      expect(tokens[0][0]).toEqual value: "this is", scopes: ["source.asciidoc"]
      expect(tokens[0][1]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[0][2]).toEqual value: "multi-", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[1][0]).toEqual value: "line bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[2][0]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[2][1]).toEqual value: "text", scopes: ["source.asciidoc"]

    it "when constrained *bold* at the beginning of the line", ->
      {tokens} = grammar.tokenizeLine("*bold text* from the start.")
      expect(tokens.length).toEqual 4
      expect(tokens[0]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[1]).toEqual value: "bold text", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[2]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[3]).toEqual value: " from the start.", scopes: ["source.asciidoc"]

    it "when constrained *bold* in a * bulleted list", ->
      {tokens} = grammar.tokenizeLine("* *bold text* followed by normal text")
      expect(tokens.length).toEqual 6
      expect(tokens[0]).toEqual value: "*", scopes: ["source.asciidoc", "markup.list.asciidoc", "markup.list.bullet.asciidoc"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.asciidoc", "markup.list.asciidoc"]
      expect(tokens[2]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[3]).toEqual value: "bold text", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[4]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[5]).toEqual value: " followed by normal text", scopes: ["source.asciidoc"]

    it "when constrained *bold* text within special characters", ->
      {tokens} = grammar.tokenizeLine("a*non-bold*a, !*bold*?, '*bold*:, .*bold*; ,*bold*")
      expect(tokens.length).toEqual 16
      expect(tokens[0]).toEqual value: "a*non-bold*a, !", scopes: ["source.asciidoc"]
      expect(tokens[1]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[2]).toEqual value: "bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[3]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[4]).toEqual value: "?, '", scopes: ["source.asciidoc"]
      expect(tokens[5]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[6]).toEqual value: "bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[7]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[8]).toEqual value: ":, .", scopes: ["source.asciidoc"]
      expect(tokens[9]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[10]).toEqual value: "bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[11]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[12]).toEqual value: "; ,", scopes: ["source.asciidoc"]
      expect(tokens[13]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[14]).toEqual value: "bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[15]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]

    it "when variants of unbalanced asterisks around *bold* text", ->
      {tokens} = grammar.tokenizeLine("*bold* **bold* ***bold* ***bold** ***bold*** **bold*** *bold*** *bold**")
      expect(tokens.length).toEqual 26
      expect(tokens[0]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[1]).toEqual value: "bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[2]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[3]).toEqual value: " ", scopes: ["source.asciidoc"]
      expect(tokens[4]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[5]).toEqual value: "bold* ", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[6]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[7]).toEqual value: "*bold* ", scopes: ["source.asciidoc"]
      expect(tokens[8]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[9]).toEqual value: "*bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[10]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[11]).toEqual value: " ", scopes: ["source.asciidoc"]
      expect(tokens[12]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[13]).toEqual value: "*bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[14]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[15]).toEqual value: "* ", scopes: ["source.asciidoc"]
      expect(tokens[16]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[17]).toEqual value: "bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[18]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[19]).toEqual value: "* ", scopes: ["source.asciidoc"]
      expect(tokens[20]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[21]).toEqual value: "bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[22]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[23]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[24]).toEqual value: " *bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[25]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]

    it "when text is 'this is *bold* text'", ->
      {tokens} = grammar.tokenizeLine("this is *bold* text")
      expect(tokens.length).toEqual 5
      expect(tokens[0]).toEqual value: "this is ", scopes: ["source.asciidoc"]
      expect(tokens[1]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[2]).toEqual value: "bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[3]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[4]).toEqual value: " text", scopes: ["source.asciidoc"]

    it "when text is '* text*'", ->
      {tokens} = grammar.tokenizeLine("* text*")
      expect(tokens.length).toEqual 3
      expect(tokens[0]).toEqual value: "*", scopes: ["source.asciidoc", "markup.list.asciidoc", "markup.list.bullet.asciidoc"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.asciidoc", "markup.list.asciidoc"]
      expect(tokens[2]).toEqual value: "text*", scopes: ["source.asciidoc"]

    it "when text is '*bold text*'", ->
      {tokens} = grammar.tokenizeLine("*bold text*")
      expect(tokens.length).toEqual 3
      expect(tokens[0]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[1]).toEqual value: "bold text", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[2]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]

    it "when text is '*bold*text*'", ->
      {tokens} = grammar.tokenizeLine("*bold*text*")
      expect(tokens.length).toEqual 3
      expect(tokens[0]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[1]).toEqual value: "bold*text", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[2]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]

    it "when text is '*bold* text *bold* text'", ->
      {tokens} = grammar.tokenizeLine("*bold* text *bold* text")
      expect(tokens.length).toEqual 8
      expect(tokens[0]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[1]).toEqual value: "bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[2]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[3]).toEqual value: " text ", scopes: ["source.asciidoc"]
      expect(tokens[4]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[5]).toEqual value: "bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[6]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[7]).toEqual value: " text", scopes: ["source.asciidoc"]

    it "when text is '* *bold* text' (list context)", ->
      {tokens} = grammar.tokenizeLine("* *bold* text")
      expect(tokens.length).toEqual 6
      expect(tokens[0]).toEqual value: "*", scopes: ["source.asciidoc", "markup.list.asciidoc", "markup.list.bullet.asciidoc"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.asciidoc", "markup.list.asciidoc"]
      expect(tokens[2]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[3]).toEqual value: "bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[4]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[5]).toEqual value: " text", scopes: ["source.asciidoc"]

    it "when text is '* *bold*' (list context)", ->
      {tokens} = grammar.tokenizeLine("* *bold*")
      expect(tokens.length).toEqual 5
      expect(tokens[0]).toEqual value: "*", scopes: ["source.asciidoc", "markup.list.asciidoc", "markup.list.bullet.asciidoc"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.asciidoc", "markup.list.asciidoc"]
      expect(tokens[2]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[3]).toEqual value: "bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[4]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]

    it "when having a [role] set on constrained *bold* text", ->
      {tokens} = grammar.tokenizeLine("[role]*bold*")
      expect(tokens.length).toEqual 4
      expect(tokens[0]).toEqual value: "[role]", scopes: ["source.asciidoc", "markup.bold.asciidoc", "support.constant.asciidoc"]
      expect(tokens[1]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[2]).toEqual value: "bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[3]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]

    it "when having [role1 role2] set on constrained *bold* text", ->
      {tokens} = grammar.tokenizeLine("[role1 role2]*bold*")
      expect(tokens.length).toEqual 4
      expect(tokens[0]).toEqual value: "[role1 role2]", scopes: ["source.asciidoc", "markup.bold.asciidoc", "support.constant.asciidoc"]
      expect(tokens[1]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[2]).toEqual value: "bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[3]).toEqual value: "*", scopes: ["source.asciidoc", "markup.bold.asciidoc"]

    it "when having a [role] set on unconstrained *bold* text", ->
      {tokens} = grammar.tokenizeLine("[role]**bold**")
      expect(tokens.length).toEqual 4
      expect(tokens[0]).toEqual value: "[role]", scopes: ["source.asciidoc", "markup.bold.asciidoc", "support.constant.asciidoc"]
      expect(tokens[1]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[2]).toEqual value: "bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[3]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]

    it "when having [role1 role2] set on unconstrained **bold** text", ->
      {tokens} = grammar.tokenizeLine("[role1 role2]**bold**")
      expect(tokens.length).toEqual 4
      expect(tokens[0]).toEqual value: "[role1 role2]", scopes: ["source.asciidoc", "markup.bold.asciidoc", "support.constant.asciidoc"]
      expect(tokens[1]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[2]).toEqual value: "bold", scopes: ["source.asciidoc", "markup.bold.asciidoc"]
      expect(tokens[3]).toEqual value: "**", scopes: ["source.asciidoc", "markup.bold.asciidoc"]

  it "tokenizes _italic_ text", ->
    {tokens} = grammar.tokenizeLine("this is _italic_ text")
    expect(tokens[0]).toEqual value: "this is ", scopes: ["source.asciidoc"]
    expect(tokens[1]).toEqual value: "_italic_", scopes: ["source.asciidoc", "markup.italic.asciidoc"]
    expect(tokens[2]).toEqual value: " text", scopes: ["source.asciidoc"]

  it "tokenizes unconstrained __italic__ text", ->
    {tokens} = grammar.tokenizeLine("this is__italic__text")
    expect(tokens[0]).toEqual value: "this is", scopes: ["source.asciidoc"]
    expect(tokens[1]).toEqual value: "__italic__", scopes: ["source.asciidoc", "markup.italic.asciidoc"]
    expect(tokens[2]).toEqual value: "text", scopes: ["source.asciidoc"]

  it "tokenizes _italic_ text with underscores", ->
    {tokens} = grammar.tokenizeLine("this is _italic_text_ with underscores")
    expect(tokens[0]).toEqual value: "this is ", scopes: ["source.asciidoc"]
    expect(tokens[1]).toEqual value: "_italic_text_", scopes: ["source.asciidoc", "markup.italic.asciidoc"]
    expect(tokens[2]).toEqual value: " with underscores", scopes: ["source.asciidoc"]

  it "tokenizes multi-line constrained _italic_ text", ->
    {tokens} = grammar.tokenizeLine("""
                                    this is _multi-
                                    line italic_ text
                                    """)
    expect(tokens[0]).toEqual value: "this is ", scopes: ["source.asciidoc"]
    expect(tokens[1]).toEqual value: """
                                    _multi-
                                    line italic_
                                    """, scopes: ["source.asciidoc", "markup.italic.asciidoc"]
    expect(tokens[2]).toEqual value: " text", scopes: ["source.asciidoc"]

  it "tokenizes multi-line unconstrained _italic_ text", ->
    {tokens} = grammar.tokenizeLine("""
                                    this is__multi-
                                    line italic__text
                                    """)
    expect(tokens[0]).toEqual value: "this is", scopes: ["source.asciidoc"]
    expect(tokens[1]).toEqual value: """
                                    __multi-
                                    line italic__
                                    """, scopes: ["source.asciidoc", "markup.italic.asciidoc"]
    expect(tokens[2]).toEqual value: "text", scopes: ["source.asciidoc"]

  it "tokenizes _italic_ text at the beginning of the line", ->
    {tokens} = grammar.tokenizeLine("_italic text_ from the start.")
    expect(tokens[0]).toEqual value: "_italic text_", scopes: ["source.asciidoc", "markup.italic.asciidoc"]
    expect(tokens[1]).toEqual value: " from the start.", scopes: ["source.asciidoc"]

  it "tokenizes _italic_ text in a * bulleted list", ->
    {tokens} = grammar.tokenizeLine("* _italic text_ followed by normal text")
    expect(tokens[0]).toEqual value: "*", scopes: ["source.asciidoc", "markup.list.asciidoc", "markup.list.bullet.asciidoc"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.asciidoc", "markup.list.asciidoc"]
    expect(tokens[2]).toEqual value: "_italic text_", scopes: ["source.asciidoc", "markup.italic.asciidoc"]
    expect(tokens[3]).toEqual value: " followed by normal text", scopes: ["source.asciidoc"]

  it "tokenizes constrained _italic_ text within special characters", ->
    {tokens} = grammar.tokenizeLine("a_non-italic_a, !_italic_?, '_italic_:, ._italic_; ,_italic_")
    expect(tokens[0]).toEqual value: "a_non-italic_a, !", scopes: ["source.asciidoc"]
    expect(tokens[1]).toEqual value: "_italic_", scopes: ["source.asciidoc", "markup.italic.asciidoc"]
    expect(tokens[2]).toEqual value: "?, '", scopes: ["source.asciidoc"]
    expect(tokens[3]).toEqual value: "_italic_", scopes: ["source.asciidoc", "markup.italic.asciidoc"]
    expect(tokens[4]).toEqual value: ":, .", scopes: ["source.asciidoc"]
    expect(tokens[5]).toEqual value: "_italic_", scopes: ["source.asciidoc", "markup.italic.asciidoc"]
    expect(tokens[6]).toEqual value: "; ,", scopes: ["source.asciidoc"]
    expect(tokens[7]).toEqual value: "_italic_", scopes: ["source.asciidoc", "markup.italic.asciidoc"]

  it "tokenizes variants of unbalanced underscores around _italic_ text", ->
    {tokens} = grammar.tokenizeLine("_italic_ __italic_ ___italic_ ___italic__ ___italic___ __italic___ _italic___ _italic__")
    expect(tokens[0]).toEqual value: "_italic_", scopes: ["source.asciidoc", "markup.italic.asciidoc"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.asciidoc"]
    expect(tokens[2]).toEqual value: "__italic_", scopes: ["source.asciidoc", "markup.italic.asciidoc"]
    expect(tokens[3]).toEqual value: " ", scopes: ["source.asciidoc"]
    expect(tokens[4]).toEqual value: "___italic_", scopes: ["source.asciidoc", "markup.italic.asciidoc"]
    expect(tokens[5]).toEqual value: " ", scopes: ["source.asciidoc"]
    expect(tokens[6]).toEqual value: "___italic__", scopes: ["source.asciidoc", "markup.italic.asciidoc"]
    expect(tokens[7]).toEqual value: " ", scopes: ["source.asciidoc"]
    expect(tokens[8]).toEqual value: "___italic___", scopes: ["source.asciidoc", "markup.italic.asciidoc"]
    expect(tokens[9]).toEqual value: " ", scopes: ["source.asciidoc"]
    expect(tokens[10]).toEqual value: "__italic___", scopes: ["source.asciidoc", "markup.italic.asciidoc"]
    expect(tokens[11]).toEqual value: " ", scopes: ["source.asciidoc"]
    expect(tokens[12]).toEqual value: "_italic___", scopes: ["source.asciidoc", "markup.italic.asciidoc"]
    expect(tokens[13]).toEqual value: " ", scopes: ["source.asciidoc"]
    expect(tokens[14]).toEqual value: "_italic__", scopes: ["source.asciidoc", "markup.italic.asciidoc"]

  it "tokenizes HTML elements", ->
    {tokens} = grammar.tokenizeLine("Dungeons &amp; Dragons")
    expect(tokens[0]).toEqual value: "Dungeons ", scopes: ["source.asciidoc"]
    expect(tokens[1]).toEqual value: "&", scopes: ["source.asciidoc", "markup.htmlentity.asciidoc", "support.constant.asciidoc"]
    expect(tokens[2]).toEqual value: "amp", scopes: ["source.asciidoc", "markup.htmlentity.asciidoc"]
    expect(tokens[3]).toEqual value: ";", scopes: ["source.asciidoc", "markup.htmlentity.asciidoc", "support.constant.asciidoc"]
    expect(tokens[4]).toEqual value: " Dragons", scopes: ["source.asciidoc"]

  it "tokenizes URLs", ->
    {tokens} = grammar.tokenizeLine("http://www.docbook.org is great")
    expect(tokens[0]).toEqual value: "http://www.docbook.org", scopes: ["source.asciidoc", "markup.underline.link.asciidoc"]

  it "does not tokenizes email addresses as URLs", ->
    {tokens} = grammar.tokenizeLine("John Smith <johnSmith@example.com>")
    expect(tokens[0]).toEqual value: "John Smith <johnSmith@example.com>", scopes: ["source.asciidoc"]

  it "tokenizes inline macros", ->
    {tokens} = grammar.tokenizeLine("http://www.docbook.org/[DocBook.org]")
    expect(tokens[0]).toEqual value: "http:", scopes: ["source.asciidoc", "markup.macro.inline.asciidoc", "support.constant.asciidoc"]
    expect(tokens[1]).toEqual value: "//www.docbook.org/", scopes: ["source.asciidoc", "markup.macro.inline.asciidoc"]
    expect(tokens[2]).toEqual value: "[", scopes: ["source.asciidoc", "markup.macro.inline.asciidoc", "support.constant.asciidoc"]
    expect(tokens[3]).toEqual value: "DocBook.org", scopes: ["source.asciidoc", "markup.macro.inline.asciidoc"]
    expect(tokens[4]).toEqual value: "]", scopes: ["source.asciidoc", "markup.macro.inline.asciidoc", "support.constant.asciidoc"]

  it "tokenizes block macros", ->
    {tokens} = grammar.tokenizeLine("image::tiger.png[Tyger tyger]")
    expect(tokens[0]).toEqual value: "image::", scopes: ["source.asciidoc", "markup.macro.block.asciidoc", "support.constant.asciidoc"]
    expect(tokens[1]).toEqual value: "tiger.png", scopes: ["source.asciidoc", "markup.macro.block.asciidoc"]
    expect(tokens[2]).toEqual value: "[", scopes: ["source.asciidoc", "markup.macro.block.asciidoc", "support.constant.asciidoc"]
    expect(tokens[3]).toEqual value: "Tyger tyger", scopes: ["source.asciidoc", "markup.macro.block.asciidoc"]
    expect(tokens[4]).toEqual value: "]", scopes: ["source.asciidoc", "markup.macro.block.asciidoc", "support.constant.asciidoc"]

  it "tokenizes [[blockId]] elements", ->
    {tokens} = grammar.tokenizeLine("this is a [[blockId]] element")
    expect(tokens[0]).toEqual value: "this is a ", scopes: ["source.asciidoc"]
    expect(tokens[1]).toEqual value: "[[", scopes: ["source.asciidoc", "support.constant.asciidoc"]
    expect(tokens[2]).toEqual value: "blockId", scopes: ["source.asciidoc", "markup.blockid.asciidoc"]
    expect(tokens[3]).toEqual value: "]]", scopes: ["source.asciidoc", "support.constant.asciidoc"]
    expect(tokens[4]).toEqual value: " element", scopes: ["source.asciidoc"]

  it "tokenizes [[[bib-ref]]] bibliography references", ->
    {tokens} = grammar.tokenizeLine("this is a [[[bib-ref]]] element")
    expect(tokens[0]).toEqual value: "this is a ", scopes: ["source.asciidoc"]
    expect(tokens[1]).toEqual value: "[[[", scopes: ["source.asciidoc", "support.constant.asciidoc"]
    expect(tokens[2]).toEqual value: "bib-ref", scopes: ["source.asciidoc", "markup.biblioref.asciidoc"]
    expect(tokens[3]).toEqual value: "]]]", scopes: ["source.asciidoc", "support.constant.asciidoc"]
    expect(tokens[4]).toEqual value: " element", scopes: ["source.asciidoc"]

  it "tokenizes <<reference>> elements", ->
    {tokens} = grammar.tokenizeLine("this is a <<reference>> element")
    expect(tokens[0]).toEqual value: "this is a ", scopes: ["source.asciidoc"]
    expect(tokens[1]).toEqual value: "<<", scopes: ["source.asciidoc", "support.constant.asciidoc"]
    expect(tokens[2]).toEqual value: "reference", scopes: ["source.asciidoc", "markup.reference.asciidoc"]
    expect(tokens[3]).toEqual value: ">>", scopes: ["source.asciidoc", "support.constant.asciidoc"]
    expect(tokens[4]).toEqual value: " element", scopes: ["source.asciidoc"]

  testAsciidocHeaders = (level) ->
    equalsSigns = level + 1
    marker = Array(equalsSigns + 1).join('=')
    {tokens} = grammar.tokenizeLine("#{marker} Heading #{level}")
    expect(tokens[0]).toEqual value: "#{marker} ", scopes: ["source.asciidoc", "markup.heading.asciidoc"]
    expect(tokens[1]).toEqual value: "Heading #{level}", scopes: ["source.asciidoc", "markup.heading.asciidoc"]

  it "tokenizes AsciiDoc-style headings", ->
    testAsciidocHeaders(level) for level in [0..5]

  it "tokenizes block titles", ->
    {tokens} = grammar.tokenizeLine("""
                                    .An e-xample' e_xample
                                    =========
                                    Example
                                    =========
                                    """)
    expect(tokens[1]).toEqual value: "An e-xample' e_xample", scopes: ["source.asciidoc", "markup.heading.blocktitle.asciidoc"]

  it "tokenizes Mardown-style headings", ->
    {tokens} = grammar.tokenizeLine("# Heading 0")
    expect(tokens[0]).toEqual value: "# ", scopes: ["source.asciidoc", "markup.heading.asciidoc"]
    expect(tokens[1]).toEqual value: "Heading 0", scopes: ["source.asciidoc", "markup.heading.asciidoc"]

    {tokens} = grammar.tokenizeLine("## Heading 1")
    expect(tokens[0]).toEqual value: "## ", scopes: ["source.asciidoc", "markup.heading.asciidoc"]
    expect(tokens[1]).toEqual value: "Heading 1", scopes: ["source.asciidoc", "markup.heading.asciidoc"]

    {tokens} = grammar.tokenizeLine("### Heading 2")
    expect(tokens[0]).toEqual value: "### ", scopes: ["source.asciidoc", "markup.heading.asciidoc"]
    expect(tokens[1]).toEqual value: "Heading 2", scopes: ["source.asciidoc", "markup.heading.asciidoc"]

    {tokens} = grammar.tokenizeLine("#### Heading 3")
    expect(tokens[0]).toEqual value: "#### ", scopes: ["source.asciidoc", "markup.heading.asciidoc"]
    expect(tokens[1]).toEqual value: "Heading 3", scopes: ["source.asciidoc", "markup.heading.asciidoc"]

    {tokens} = grammar.tokenizeLine("##### Heading 4")
    expect(tokens[0]).toEqual value: "##### ", scopes: ["source.asciidoc", "markup.heading.asciidoc"]
    expect(tokens[1]).toEqual value: "Heading 4", scopes: ["source.asciidoc", "markup.heading.asciidoc"]

    {tokens} = grammar.tokenizeLine("###### Heading 5")
    expect(tokens[0]).toEqual value: "###### ", scopes: ["source.asciidoc", "markup.heading.asciidoc"]
    expect(tokens[1]).toEqual value: "Heading 5", scopes: ["source.asciidoc", "markup.heading.asciidoc"]

  it "tokenizes list bullets with the length up to 5 symbols", ->
    {tokens} = grammar.tokenizeLine("""
                                    . Level 1
                                    .. Level 2
                                    *** Level 3
                                    **** Level 4
                                    ***** Level 5
                                    """)
    expect(tokens[0]).toEqual  value: ".", scopes: ["source.asciidoc", "markup.list.asciidoc", "markup.list.bullet.asciidoc"]
    expect(tokens[3]).toEqual  value: "..", scopes: ["source.asciidoc", "markup.list.asciidoc", "markup.list.bullet.asciidoc"]
    expect(tokens[6]).toEqual  value: "***", scopes: ["source.asciidoc", "markup.list.asciidoc", "markup.list.bullet.asciidoc"]
    expect(tokens[9]).toEqual  value: "****", scopes: ["source.asciidoc", "markup.list.asciidoc", "markup.list.bullet.asciidoc"]
    expect(tokens[12]).toEqual value: "*****", scopes: ["source.asciidoc", "markup.list.asciidoc", "markup.list.bullet.asciidoc"]

  it "tokenizes table delimited block", ->
    {tokens} = grammar.tokenizeLine("|===\n|===")
    expect(tokens[0]).toEqual value: "|===", scopes: ["source.asciidoc", "support.table.asciidoc"]
    expect(tokens[2]).toEqual value: "|===", scopes: ["source.asciidoc", "support.table.asciidoc"]

  it "ignores table delimited block with less than 3 equal signs", ->
    {tokens} = grammar.tokenizeLine("|==\n|==")
    expect(tokens[0]).toEqual value: "|==\n|==", scopes: ["source.asciidoc"]

  it "tokenizes cell delimiters within table block", ->
    {tokens} = grammar.tokenizeLine("|===\n|Name h|Purpose\n|===")
    expect(tokens[2]).toEqual value: "|", scopes: ["source.asciidoc", "support.table.asciidoc"]
    expect(tokens[6]).toEqual value: "|", scopes: ["source.asciidoc", "support.table.asciidoc"]

  it "tokenizes cell specs within table block", ->
    {tokens} = grammar.tokenizeLine("|===\n^|1 2.2+^.^|2 .3+<.>m|3\n|===")
    expect(tokens[2]).toEqual value: "^", scopes: ["source.asciidoc", "support.table.spec.asciidoc"]
    expect(tokens[6]).toEqual value: "2.2+^.^", scopes: ["source.asciidoc", "support.table.spec.asciidoc"]
    expect(tokens[10]).toEqual value: ".3+<.>m", scopes: ["source.asciidoc", "support.table.spec.asciidoc"]

  it "tokenizes admonition", ->
    {tokens} = grammar.tokenizeLine("NOTE: This is a note")
    expect(tokens[0]).toEqual value: "NOTE:", scopes: ["source.asciidoc", "markup.admonition.asciidoc", "support.constant.asciidoc"]
    expect(tokens[2]).toEqual value: "This is a note", scopes: ["source.asciidoc", "markup.admonition.asciidoc"]

  it "tokenizes explicit paragraph styles", ->
    {tokens} = grammar.tokenizeLine("[NOTE]\n====\n")
    expect(tokens[1]).toEqual value: "NOTE", scopes: ["source.asciidoc", "markup.explicit.asciidoc", "support.constant.asciidoc"]
    expect(tokens[4]).toEqual value: "====", scopes: ["source.asciidoc", "markup.block.example.asciidoc"]

  it "tokenizes section templates", ->
    {tokens} = grammar.tokenizeLine("[sect1]\nThis is an section.\n")
    expect(tokens[1]).toEqual value: "sect1", scopes: ["source.asciidoc", "markup.section.asciidoc", "support.constant.asciidoc"]
    expect(tokens[3]).toEqual value: "\nThis is an section.\n", scopes: ["source.asciidoc"]

  it "tokenizes quote blocks", ->
    {tokens} = grammar.tokenizeLine("""
                                    [quote]
                                    ____
                                    D'oh!
                                    ____
                                    """)
    expect(tokens[1]).toEqual value: "quote", scopes: ["source.asciidoc", "markup.quote.declaration.asciidoc"]
    expect(tokens[4]).toEqual value: "____", scopes: ["source.asciidoc", "markup.quote.block.asciidoc"]
    expect(tokens[5]).toEqual value: "\nD'oh!\n", scopes: ["source.asciidoc", "markup.quote.block.asciidoc"]
    expect(tokens[6]).toEqual value: "____", scopes: ["source.asciidoc", "markup.quote.block.asciidoc"]

  it "tokenizes quote declarations with attribution", ->
    {tokens} = grammar.tokenizeLine("[verse, Homer Simpson]\n")
    expect(tokens[1]).toEqual value: "verse", scopes: ["source.asciidoc", "markup.quote.declaration.asciidoc"]
    expect(tokens[3]).toEqual value: "Homer Simpson", scopes: ["source.asciidoc", "markup.quote.attribution.asciidoc"]

  it "tokenizes quote declarations with attribution and citation", ->
    {tokens} = grammar.tokenizeLine("[quote, Erwin Schrödinger, Sorry]\n")
    expect(tokens[1]).toEqual value: "quote", scopes: ["source.asciidoc", "markup.quote.declaration.asciidoc"]
    expect(tokens[3]).toEqual value: "Erwin Schrödinger", scopes: ["source.asciidoc", "markup.quote.attribution.asciidoc"]
    expect(tokens[5]).toEqual value: "Sorry", scopes: ["source.asciidoc", "markup.quote.citation.asciidoc"]

  testBlock = (delimiter, type) ->
    marker = Array(5).join(delimiter)
    {tokens} = grammar.tokenizeLine("#{marker}\ncontent\n#{marker}")
    expect(tokens[0]).toEqual value: marker, scopes: ["source.asciidoc", type]
    expect(tokens[2]).toEqual value: marker, scopes: ["source.asciidoc", type]

  it "tokenizes comment block", ->
    testBlock "/", "comment.block.asciidoc"

  it "tokenizes example block", ->
    testBlock "=", "markup.block.example.asciidoc"

  it "tokenizes sidebar block", ->
    testBlock "*", "markup.block.sidebar.asciidoc"

  it "tokenizes literal block", ->
    testBlock ".", "markup.block.literal.asciidoc"

  it "tokenizes passthrough block", ->
    testBlock "+", "markup.block.passthrough.asciidoc"

  describe "should tokenize todo lists", ->

    it "when todo", ->
      {tokens} = grammar.tokenizeLine("- [ ] todo 1")
      expect(tokens.length).toEqual 4
      expect(tokens[0]).toEqual value: "-", scopes: ["source.asciidoc", "markup.todo.asciidoc", "markup.list.bullet.asciidoc"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.asciidoc", "markup.todo.asciidoc"]
      expect(tokens[2]).toEqual value: "[ ]", scopes: ["source.asciidoc", "markup.todo.asciidoc", "markup.todo.box.asciidoc"]
      expect(tokens[3]).toEqual value: " todo 1", scopes: ["source.asciidoc"]

    it "when [*] done", ->
      {tokens} = grammar.tokenizeLine("- [*] todo 1")
      expect(tokens.length).toEqual 4
      expect(tokens[0]).toEqual value: "-", scopes: ["source.asciidoc", "markup.todo.asciidoc", "markup.list.bullet.asciidoc"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.asciidoc", "markup.todo.asciidoc"]
      expect(tokens[2]).toEqual value: "[*]", scopes: ["source.asciidoc", "markup.todo.asciidoc", "markup.todo.box.asciidoc"]
      expect(tokens[3]).toEqual value: " todo 1", scopes: ["source.asciidoc"]

    it "when [x] done", ->
      {tokens} = grammar.tokenizeLine("- [x] todo 1")
      expect(tokens.length).toEqual 4
      expect(tokens[0]).toEqual value: "-", scopes: ["source.asciidoc", "markup.todo.asciidoc", "markup.list.bullet.asciidoc"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.asciidoc", "markup.todo.asciidoc"]
      expect(tokens[2]).toEqual value: "[x]", scopes: ["source.asciidoc", "markup.todo.asciidoc", "markup.todo.box.asciidoc"]
      expect(tokens[3]).toEqual value: " todo 1", scopes: ["source.asciidoc"]

    it "when a varied todo-list", ->
      tokens = grammar.tokenizeLines("""
                                      - [ ] todo 1
                                      - normal item
                                       - [x] done x
                                      - [*] done *
                                      """)
      expect(tokens.length).toEqual 4
      expect(tokens[0].length).toEqual 4
      expect(tokens[0][0]).toEqual value: "-", scopes: ["source.asciidoc", "markup.todo.asciidoc", "markup.list.bullet.asciidoc"]
      expect(tokens[0][1]).toEqual value: " ", scopes: ["source.asciidoc", "markup.todo.asciidoc"]
      expect(tokens[0][2]).toEqual value: "[ ]", scopes: ["source.asciidoc", "markup.todo.asciidoc", "markup.todo.box.asciidoc"]
      expect(tokens[0][3]).toEqual value: " todo 1", scopes: ["source.asciidoc"]
      expect(tokens[1].length).toEqual 3
      expect(tokens[1][0]).toEqual value: "-", scopes: ["source.asciidoc", "markup.list.asciidoc", "markup.list.bullet.asciidoc"]
      expect(tokens[1][1]).toEqual value: " ", scopes: ["source.asciidoc", "markup.list.asciidoc"]
      expect(tokens[1][2]).toEqual value: "normal item", scopes: ["source.asciidoc"]
      expect(tokens[2].length).toEqual 5
      expect(tokens[2][0]).toEqual value: " ", scopes: ["source.asciidoc", "markup.todo.asciidoc"]
      expect(tokens[2][1]).toEqual value: "-", scopes: ["source.asciidoc", "markup.todo.asciidoc", "markup.list.bullet.asciidoc"]
      expect(tokens[2][2]).toEqual value: " ", scopes: ["source.asciidoc", "markup.todo.asciidoc"]
      expect(tokens[2][3]).toEqual value: "[x]", scopes: ["source.asciidoc", "markup.todo.asciidoc", "markup.todo.box.asciidoc"]
      expect(tokens[2][4]).toEqual value: " done x", scopes: ["source.asciidoc"]
      expect(tokens[3].length).toEqual 4
      expect(tokens[3][0]).toEqual value: "-", scopes: ["source.asciidoc", "markup.todo.asciidoc", "markup.list.bullet.asciidoc"]
      expect(tokens[3][1]).toEqual value: " ", scopes: ["source.asciidoc", "markup.todo.asciidoc"]
      expect(tokens[3][2]).toEqual value: "[*]", scopes: ["source.asciidoc", "markup.todo.asciidoc", "markup.todo.box.asciidoc"]
      expect(tokens[3][3]).toEqual value: " done *", scopes: ["source.asciidoc"]
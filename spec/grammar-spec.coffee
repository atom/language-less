describe "less grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-less")

    runs ->
      grammar = atom.grammars.grammarForScopeName("source.css.less")

  it "parses the grammar", ->
    expect(grammar).toBeDefined()
    expect(grammar.scopeName).toBe "source.css.less"

  it "parses constant.numeric.css", ->
    {tokens} = grammar.tokenizeLine(" 10")
    expect(tokens).toHaveLength 2
    expect(tokens[0]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[1]).toEqual value: "10", scopes: ['source.css.less', 'constant.numeric.css']

    {tokens} = grammar.tokenizeLine("-.1")
    expect(tokens).toHaveLength 1
    expect(tokens[0]).toEqual value: "-.1", scopes: ['source.css.less', 'constant.numeric.css']

    {tokens} = grammar.tokenizeLine(".4")
    expect(tokens).toHaveLength 1
    expect(tokens[0]).toEqual value: ".4", scopes: ['source.css.less', 'constant.numeric.css']

  it "parses property names", ->
    {tokens} = grammar.tokenizeLine("{display: none;}")
    expect(tokens[1]).toEqual value: "display", scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']

    {tokens} = grammar.tokenizeLine("{displaya: none;}")
    expect(tokens[1]).toEqual value: "displaya", scopes: ['source.css.less', 'meta.property-list.css']

  it "parses property names distinctly from property values with the same text", ->
    {tokens} = grammar.tokenizeLine("{left: left;}")
    expect(tokens).toHaveLength 7
    expect(tokens[1]).toEqual value: "left", scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[2]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.separator.key-value.css']
    expect(tokens[3]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css']
    expect(tokens[4]).toEqual value: "left", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
    expect(tokens[5]).toEqual value: ";", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.terminator.rule.css']

    {tokens} = grammar.tokenizeLine("{left:left;}")
    expect(tokens).toHaveLength 6
    expect(tokens[1]).toEqual value: "left", scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[2]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.separator.key-value.css']
    expect(tokens[3]).toEqual value: "left", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
    expect(tokens[4]).toEqual value: ";", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.terminator.rule.css']

  it "parses property names distinctly from element selectors with the same prefix", ->
    {tokens} = grammar.tokenizeLine("{table-layout: fixed;}")
    expect(tokens).toHaveLength 7
    expect(tokens[1]).toEqual value: "table-layout", scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[2]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.separator.key-value.css']
    expect(tokens[3]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css']
    expect(tokens[4]).toEqual value: "fixed", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
    expect(tokens[5]).toEqual value: ";", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.terminator.rule.css']

  it "does not parse @media conditions as a property-list", ->
    {tokens} = grammar.tokenizeLine('@media (min-resolution: 2dppx) {}')
    expect(tokens[4].scopes).not.toContain 'support.type.property-name.css'
    expect(tokens[7].scopes).not.toContain 'meta.property-value.css'
    expect(tokens[11].scopes).not.toContain 'meta.property-value.css'

  it "parses parent selector", ->
    {tokens} = grammar.tokenizeLine('& .foo {}')
    expect(tokens).toHaveLength 7
    expect(tokens[0]).toEqual value: "&", scopes: ['source.css.less', 'entity.other.attribute-name.parent-selector.css', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[2]).toEqual value: ".", scopes: ['source.css.less', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
    expect(tokens[3]).toEqual value: "foo", scopes: ['source.css.less', 'entity.other.attribute-name.class.css']
    expect(tokens[4]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[5]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
    expect(tokens[6]).toEqual value: "}", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.end.css']

    {tokens} = grammar.tokenizeLine('&:hover {}')
    expect(tokens).toHaveLength 6
    expect(tokens[0]).toEqual value: "&", scopes: ['source.css.less', 'entity.other.attribute-name.parent-selector.css', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: ":", scopes: ['source.css.less', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
    expect(tokens[2]).toEqual value: "hover", scopes: ['source.css.less', 'entity.other.attribute-name.pseudo-class.css']
    expect(tokens[3]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[4]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
    expect(tokens[5]).toEqual value: "}", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.end.css']

  it "parses id selectors", ->
    {tokens} = grammar.tokenizeLine("#abc {}")
    expect(tokens).toHaveLength 5
    expect(tokens[0]).toEqual value: "#", scopes: ['source.css.less', 'meta.selector.css', 'entity.other.attribute-name.id', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: "abc", scopes: ['source.css.less', 'meta.selector.css', 'entity.other.attribute-name.id']

    {tokens} = grammar.tokenizeLine("#abc-123 {}")
    expect(tokens).toHaveLength 5
    expect(tokens[0]).toEqual value: "#", scopes: ['source.css.less', 'meta.selector.css', 'entity.other.attribute-name.id', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: "abc-123", scopes: ['source.css.less', 'meta.selector.css', 'entity.other.attribute-name.id']

  it "parses property lists", ->
    {tokens} = grammar.tokenizeLine(".foo { border: none; }")
    expect(tokens).toHaveLength 12
    expect(tokens[0]).toEqual value: ".", scopes: ['source.css.less', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: "foo", scopes: ['source.css.less', 'entity.other.attribute-name.class.css']
    expect(tokens[2]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[3]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
    expect(tokens[4]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[5]).toEqual value: "border", scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[6]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.separator.key-value.css']
    expect(tokens[7]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css']
    expect(tokens[8]).toEqual value: "none", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
    expect(tokens[9]).toEqual value: ";", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.terminator.rule.css']
    expect(tokens[10]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[11]).toEqual value: "}", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.end.css']

  it 'parses an incomplete property list', ->
    {tokens} = grammar.tokenizeLine '.foo { border: none}'
    expect(tokens[5]).toEqual value: 'border', scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[8]).toEqual value: 'none', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
    expect(tokens[9]).toEqual value: '}', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.section.property-list.end.css']

  it 'parses multiple lines of an incomplete property-list', ->
    lines = grammar.tokenizeLines '''
      very-custom { color: inherit }
      another-one { display: none; }
    '''
    expect(lines[0][0]).toEqual value: 'very-custom', scopes: ['source.css.less', 'keyword.control.html.custom.elements']
    expect(lines[0][4]).toEqual value: 'color', scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(lines[0][7]).toEqual value: 'inherit', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
    expect(lines[0][9]).toEqual value: '}', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.section.property-list.end.css']

    expect(lines[1][0]).toEqual value: 'another-one', scopes: ['source.css.less', 'keyword.control.html.custom.elements']
    expect(lines[1][10]).toEqual value: '}', scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.end.css']

  it "parses variables", ->
    {tokens} = grammar.tokenizeLine(".foo { border: @bar; }")
    expect(tokens).toHaveLength 12
    expect(tokens[0]).toEqual value: ".", scopes: ['source.css.less', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: "foo", scopes: ['source.css.less', 'entity.other.attribute-name.class.css']
    expect(tokens[2]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[3]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
    expect(tokens[4]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[5]).toEqual value: "border", scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[6]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.separator.key-value.css']
    expect(tokens[7]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css']
    expect(tokens[8]).toEqual value: "@bar", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'variable.other.less']
    expect(tokens[9]).toEqual value: ";", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.terminator.rule.css']
    expect(tokens[10]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[11]).toEqual value: "}", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.end.css']

  it 'parses variable interpolation', ->
    {tokens} = grammar.tokenizeLine '.@{selector} { @{property}: #0ee; }'
    expect(tokens[1]).toEqual value: '@{selector}', scopes: ['source.css.less', 'variable.other.interpolation.less']
    expect(tokens[2]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[3]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
    expect(tokens[4]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[5]).toEqual value: '@{property}', scopes: ['source.css.less', 'meta.property-list.css', 'variable.other.interpolation.less']
    expect(tokens[6]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.separator.key-value.css']
    expect(tokens[7]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css']

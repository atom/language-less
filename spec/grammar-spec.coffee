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

  it 'parses color names', ->
    {tokens} = grammar.tokenizeLine '.foo { color: rebeccapurple; background: whitesmoke; }'
    expect(tokens[8]).toEqual value: "rebeccapurple", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.color.w3c-standard-color-name.css']
    expect(tokens[14]).toEqual value: "whitesmoke", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.color.w3c-standard-color-name.css']

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

  it "parses @media features", ->
    {tokens} = grammar.tokenizeLine('@media (min-width: 100px) {}')
    expect(tokens[4]).toEqual value: "min-width", scopes: ['source.css.less', 'support.type.property-name.media-feature.media.css']

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

  it "parses pseudo classes", ->
    {tokens} = grammar.tokenizeLine(".foo:hover { span:last-of-type { font-weight: bold; } }")
    expect(tokens[0]).toEqual value: ".", scopes: ['source.css.less', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: "foo", scopes: ['source.css.less', 'entity.other.attribute-name.class.css']
    expect(tokens[2]).toEqual value: ":", scopes: ['source.css.less', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
    expect(tokens[3]).toEqual value: "hover", scopes: ['source.css.less', 'entity.other.attribute-name.pseudo-class.css' ]
    expect(tokens[4]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[5]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
    expect(tokens[6]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[7]).toEqual value: "span", scopes: ['source.css.less', 'meta.property-list.css', 'keyword.control.html.elements']
    expect(tokens[8]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
    expect(tokens[9]).toEqual value: "last-of-type", scopes: ['source.css.less', 'meta.property-list.css', 'entity.other.attribute-name.pseudo-class.css']
    expect(tokens[10]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[11]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
    expect(tokens[12]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-list.css']
    expect(tokens[13]).toEqual value: "font-weight", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[14]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.separator.key-value.css']

  it "parses property lists", ->
    {tokens} = grammar.tokenizeLine(".foo { display: table-row; }")
    expect(tokens).toHaveLength 12
    expect(tokens[0]).toEqual value: ".", scopes: ['source.css.less', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: "foo", scopes: ['source.css.less', 'entity.other.attribute-name.class.css']
    expect(tokens[2]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[3]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
    expect(tokens[4]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[5]).toEqual value: "display", scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[6]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.separator.key-value.css']
    expect(tokens[7]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css']
    expect(tokens[8]).toEqual value: "table-row", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
    expect(tokens[9]).toEqual value: ";", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.terminator.rule.css']
    expect(tokens[10]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[11]).toEqual value: "}", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.end.css']

  it 'parses font lists', ->
    {tokens} = grammar.tokenizeLine '.foo { font-family: "Some Font Name", serif; }'
    expect(tokens[5]).toEqual value: 'font-family', scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[9]).toEqual value: 'Some Font Name', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'string.quoted.double.css']
    expect(tokens[12]).toEqual value: 'serif', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.font-name.css']

  it 'parses an incomplete property list', ->
    {tokens} = grammar.tokenizeLine '.foo { border: none}'
    expect(tokens[5]).toEqual value: 'border', scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[8]).toEqual value: 'none', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
    expect(tokens[9]).toEqual value: '}', scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.end.css']

  it 'parses multiple lines of an incomplete property-list', ->
    lines = grammar.tokenizeLines '''
      very-custom { color: inherit }
      another-one { display: none; }
    '''
    expect(lines[0][0]).toEqual value: 'very-custom', scopes: ['source.css.less', 'keyword.control.html.custom.elements']
    expect(lines[0][4]).toEqual value: 'color', scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(lines[0][7]).toEqual value: 'inherit', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
    expect(lines[0][9]).toEqual value: '}', scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.end.css']

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

  it 'parses variable interpolation in selectors', ->
    {tokens} = grammar.tokenizeLine '.@{selector} { color: #0ee; }'
    expect(tokens[1]).toEqual value: '@{selector}', scopes: ['source.css.less', 'variable.other.interpolation.less']
    expect(tokens[2]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[3]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
    expect(tokens[4]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']

  it 'parses variable interpolation in properties', ->
    {tokens} = grammar.tokenizeLine '.foo { @{property}: #0ee; }'
    expect(tokens[0]).toEqual value: ".", scopes: ['source.css.less', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: "foo", scopes: ['source.css.less', 'entity.other.attribute-name.class.css']
    expect(tokens[2]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[3]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
    expect(tokens[4]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[5]).toEqual value: '@{property}', scopes: ['source.css.less', 'meta.property-list.css', 'variable.other.interpolation.less']
    expect(tokens[6]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.separator.key-value.css']
    expect(tokens[7]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css']

  it 'parses options in import statements', ->
    {tokens} = grammar.tokenizeLine '@import (optional, reference) "theme";'
    expect(tokens[0]).toEqual value: "@", scopes: ['source.css.less', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.less', 'punctuation.definition.keyword.less']
    expect(tokens[1]).toEqual value: "import", scopes: ['source.css.less', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.less']
    expect(tokens[4]).toEqual value: "optional", scopes: ['source.css.less', 'keyword.control.import.option.less']
    expect(tokens[6]).toEqual value: "reference", scopes: ['source.css.less', 'keyword.control.import.option.less']
    expect(tokens[10]).toEqual value: "theme", scopes: ['source.css.less', 'string.quoted.double.css']

  it 'parses built-in functions in property values', ->
    {tokens} = grammar.tokenizeLine '.foo { border: 1px solid rgba(0,0,0); }'
    expect(tokens[0]).toEqual value: ".", scopes: ['source.css.less', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: "foo", scopes: ['source.css.less', 'entity.other.attribute-name.class.css']
    expect(tokens[2]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[3]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
    expect(tokens[4]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[5]).toEqual value: "border", scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[6]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.separator.key-value.css']
    expect(tokens[8]).toEqual value: "1", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'constant.numeric.css']
    expect(tokens[9]).toEqual value: "px", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'keyword.other.unit.css']
    expect(tokens[11]).toEqual value: "solid", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
    expect(tokens[13]).toEqual value: "rgba", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.function.any-method.builtin.css']
    expect(tokens[14]).toEqual value: "(", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'meta.brace.round.less']
    expect(tokens[15]).toEqual value: "0", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'constant.numeric.css']
    expect(tokens[21]).toEqual value: ";", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.terminator.rule.css']

  it 'parses linear-gradient', ->
    {tokens} = grammar.tokenizeLine '.foo { background: linear-gradient(white, black); }'
    expect(tokens[5]).toEqual value: "background", scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[6]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.separator.key-value.css']
    expect(tokens[7]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css']
    expect(tokens[8]).toEqual value: "linear-gradient", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.function.any-method.builtin.css']
    expect(tokens[9]).toEqual value: "(", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'meta.brace.round.less']

  it 'parses transform functions', ->
    {tokens} = grammar.tokenizeLine '.foo { transform: scaleY(1); }'
    expect(tokens[5]).toEqual value: "transform", scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[6]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.separator.key-value.css']
    expect(tokens[7]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css']
    expect(tokens[8]).toEqual value: "scaleY", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.function.any-method.builtin.css']
    expect(tokens[9]).toEqual value: "(", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'meta.brace.round.less']

  it 'parses blend modes', ->
    {tokens} = grammar.tokenizeLine '.foo { background-blend-mode: color-dodge; }'
    expect(tokens[5]).toEqual value: "background-blend-mode", scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[6]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.separator.key-value.css']
    expect(tokens[7]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css']
    expect(tokens[8]).toEqual value: "color-dodge", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
    expect(tokens[9]).toEqual value: ";", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.terminator.rule.css']

  it 'parses nested multiple lines with pseudo-classes', ->
    lines = grammar.tokenizeLines '''
      a { p:hover,
      p:active { color: blue; } }
    '''
    expect(lines[0][0]).toEqual value: 'a', scopes: ['source.css.less', 'keyword.control.html.elements']
    expect(lines[0][1]).toEqual value: ' ', scopes: ['source.css.less']
    expect(lines[0][2]).toEqual value: '{', scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
    expect(lines[0][3]).toEqual value: ' ', scopes: ['source.css.less', 'meta.property-list.css']
    expect(lines[0][4]).toEqual value: 'p', scopes: ['source.css.less', 'meta.property-list.css', 'keyword.control.html.elements' ]
    expect(lines[0][5]).toEqual value: ':', scopes: ['source.css.less', 'meta.property-list.css', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
    expect(lines[0][6]).toEqual value: 'hover', scopes: ['source.css.less', 'meta.property-list.css', 'entity.other.attribute-name.pseudo-class.css']
    expect(lines[0][7]).toEqual value: ',', scopes: ['source.css.less', 'meta.property-list.css']
    expect(lines[1][0]).toEqual value: 'p', scopes: ['source.css.less', 'meta.property-list.css', 'keyword.control.html.elements' ]
    expect(lines[1][1]).toEqual value: ':', scopes: ['source.css.less', 'meta.property-list.css', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
    expect(lines[1][2]).toEqual value: 'active', scopes: ['source.css.less', 'meta.property-list.css', 'entity.other.attribute-name.pseudo-class.css']
    expect(lines[1][3]).toEqual value: ' ', scopes: ['source.css.less', 'meta.property-list.css']
    expect(lines[1][4]).toEqual value: '{', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
    expect(lines[1][5]).toEqual value: ' ', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-list.css']

  #TODO
  # it 'parses variable interpolation in imports', ->
  #   {tokens} = grammar.tokenizeLine '@import "@{themes}/tidal-wave.less";'
  #TODO
  # it 'parses variable interpolation in urls', ->
  #   {tokens} = grammar.tokenizeLine '.foo { background: url("@{images}/white-sand.png"); }";'
  #TODO
  # it 'parses non-quoted urls' ->
  #   {tokens} = grammar.tokenizeLine '.foo { background: #f00ba7 url(http://placehold.alpha-centauri/42.png) no-repeat; }";'

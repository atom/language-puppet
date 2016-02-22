describe "Puppet grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-puppet")

    runs ->
      grammar = atom.grammars.grammarForScopeName("source.puppet")

  it "parses the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "source.puppet"

  describe "resources", ->
    manifest = "type { title: parameter1 => 'stringvalue', inlineparameter => Resource['reference']; }"

    it 'tokenizes resource types', ->
      {tokens} = grammar.tokenizeLine(manifest)
      expect(tokens[0]).toEqual value: 'type', scopes: ['source.puppet', 'meta.definition.resource.puppet', 'storage.type.puppet']

    it 'tokenizes defined type resources', ->
      manifest = "classname::type { title: parameter1 => 'stringvalue', inlineparameter => Resource['reference']; }"
      {tokens} = grammar.tokenizeLine(manifest)
      expect(tokens[0]).toEqual value: 'classname::type', scopes: ['source.puppet', 'meta.definition.resource.puppet', 'storage.type.puppet']

    it 'tokenizes resource title punctuation', ->
      {tokens} = grammar.tokenizeLine(manifest)
      expect(tokens[3]).toEqual value: ':', scopes: ['source.puppet', 'meta.definition.resource.puppet', 'meta.title.puppet', 'punctuation.classtitle.puppet']

    it 'tokenizes resource parameter', ->
      {tokens} = grammar.tokenizeLine(manifest)
      expect(tokens[5]).toEqual value: 'parameter1', scopes: ['source.puppet', 'meta.definition.resource.puppet', 'meta.parameter.resource.puppet', 'name.parameter.resource.puppet']

    it 'tokenizes resource parameter separators', ->
      {tokens} = grammar.tokenizeLine(manifest)
      expect(tokens[7]).toEqual value: '=>', scopes: ['source.puppet', 'meta.definition.resource.puppet', 'meta.parameter.resource.puppet', 'punctuation.separator.key-value.puppet']

  describe "classes", ->
    it 'should tokenize a class without parameters', ->
      {tokens} = grammar.tokenizeLine("class classname {  }")
      expect(tokens[0]).toEqual value: 'class', scopes: ['source.puppet', 'meta.definition.class.puppet', 'storage.type.puppet']
      expect(tokens[2]).toEqual value: 'classname', scopes: ['source.puppet', 'meta.definition.class.puppet', 'entity.name.type.class.puppet']
      expect(tokens[4]).toEqual value: '{', scopes: [ 'source.puppet', 'meta.definition.class.puppet', 'punctuation.definition.class.begin.puppet' ]

    it 'should tokenize a class with parameters', ->
      {tokens} = grammar.tokenizeLine("class classname ( $parameter1, $parameter2 = 'value', $parameter3 = $classname::params) {  }")
      expect(tokens[4]).toEqual value: '(', scopes: ['source.puppet', 'meta.definition.class.puppet', 'meta.classparameter.language.puppet', 'punctuation.definition.classparameter.begin.puppet']
      expect(tokens[21]).toEqual value: ')', scopes: ['source.puppet', 'meta.definition.class.puppet', 'meta.classparameter.language.puppet', 'punctuation.definition.classparameter.end.puppet']

    it 'should tokenize a class with ineritence', ->
      {tokens} = grammar.tokenizeLine("class classname ( $parameter1, $parameter2 = 'value', $parameter3 = $classname::params) inherits another::class {  }")
      expect(tokens[23]).toEqual value: 'inherits', scopes: ['source.puppet', 'meta.definition.class.puppet', 'meta.definition.class.inherits.puppet', 'storage.modifier.puppet']
      expect(tokens[25]).toEqual value: 'another::class', scopes: ['source.puppet', 'meta.definition.class.puppet', 'meta.definition.class.inherits.puppet', 'entity.name.type.class.puppet']

  describe "applications", ->
    it 'should tokenize an application without parameters', ->
      {tokens} = grammar.tokenizeLine("application appname {  }")
      expect(tokens[0]).toEqual value: 'application', scopes: ['source.puppet', 'meta.definition.class.puppet', 'storage.type.puppet']
      expect(tokens[2]).toEqual value: 'appname', scopes: ['source.puppet', 'meta.definition.class.puppet', 'entity.name.type.class.puppet']
      expect(tokens[4]).toEqual value: '{', scopes: [ 'source.puppet', 'meta.definition.class.puppet', 'punctuation.definition.class.begin.puppet' ]

    it 'should tokenize an application with parameters', ->
      {tokens} = grammar.tokenizeLine("application appname ( $parameter1, $parameter2 = 'value', $parameter3 = $classname::params) {  }")
      expect(tokens[4]).toEqual value: '(', scopes: ['source.puppet', 'meta.definition.class.puppet', 'meta.classparameter.language.puppet', 'punctuation.definition.classparameter.begin.puppet']
      expect(tokens[21]).toEqual value: ')', scopes: ['source.puppet', 'meta.definition.class.puppet', 'meta.classparameter.language.puppet', 'punctuation.definition.classparameter.end.puppet']

  describe "defined types", ->
    it 'should tokenize a defined type without parameters', ->
      {tokens} = grammar.tokenizeLine("define typename {  }")
      expect(tokens[0]).toEqual value: 'define', scopes: ['source.puppet', 'meta.definition.class.puppet', 'storage.type.puppet']
      expect(tokens[2]).toEqual value: 'typename', scopes: ['source.puppet', 'meta.definition.class.puppet', 'entity.name.type.class.puppet']
      expect(tokens[4]).toEqual value: '{', scopes: [ 'source.puppet', 'meta.definition.class.puppet', 'punctuation.definition.class.begin.puppet' ]

    it 'should tokenize a defined type with parameters', ->
      {tokens} = grammar.tokenizeLine("define typename ( $parameter1, $parameter2 = 'value', $parameter3 = $classname::params) {  }")
      expect(tokens[4]).toEqual value: '(', scopes: ['source.puppet', 'meta.definition.class.puppet', 'meta.classparameter.language.puppet', 'punctuation.definition.classparameter.begin.puppet']
      expect(tokens[21]).toEqual value: ')', scopes: ['source.puppet', 'meta.definition.class.puppet', 'meta.classparameter.language.puppet', 'punctuation.definition.classparameter.end.puppet']

  describe "constants", ->
    it 'should tokenize a resource reference', ->
      {tokens} = grammar.tokenizeLine("Resource::Reference[title]")
      expect(tokens[0]).toEqual value: "Resource::Reference[", scopes: ['source.puppet', 'constant.support.puppet']
      expect(tokens[2]).toEqual value: "]", scopes: ['source.puppet', 'constant.support.puppet']

  describe "nodes", ->
    it "tokenizes single quoted node", ->
      {tokens} = grammar.tokenizeLine("node 'hostname' {")
      expect(tokens[0]).toEqual value: 'node', scopes: ['source.puppet', 'meta.definition.class.puppet', 'storage.type.puppet']

    it "tokenizes double quoted node", ->
      {tokens} = grammar.tokenizeLine('node "hostname" {')
      expect(tokens[0]).toEqual value: 'node', scopes: ['source.puppet', 'meta.definition.class.puppet', 'storage.type.puppet']

  describe "functions", ->
    it 'should tokenize a function with no space between name and (', ->
      {tokens} = grammar.tokenizeLine('function(parameter, parameter2)')
      expect(tokens[0]).toEqual value: 'function', scopes: [ 'source.puppet', 'meta.function.puppet', 'support.function.puppet' ]
      expect(tokens[1]).toEqual value: '(', scopes: [ 'source.puppet', 'meta.function.puppet', 'punctuation.definition.function.begin.puppet' ]
      expect(tokens[3]).toEqual value: ',', scopes: [ 'source.puppet', 'meta.function.puppet', 'punctuation.separator.parameter.puppet' ]
      expect(tokens[5]).toEqual value: ')', scopes: [ 'source.puppet', 'meta.function.puppet', 'punctuation.definition.function.end.puppet' ]

  describe "numbers", ->
    it "should tokenize floats", ->
      {tokens} = grammar.tokenizeLine('883.111999')
      expect(tokens[0]).toEqual value: '883.111999', scopes: [ 'source.puppet', 'meta.control.puppet', 'number.constant.puppet' ]

    it "should tokenize integers", ->
      {tokens} = grammar.tokenizeLine('883')
      expect(tokens[0]).toEqual value: '883', scopes: [ 'source.puppet', 'meta.control.puppet', 'number.constant.puppet' ]

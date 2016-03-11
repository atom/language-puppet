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

  describe "separators", ->
    it "tokenizes attribute separator", ->
      {tokens} = grammar.tokenizeLine('ensure => present')
      expect(tokens[1]).toEqual value: '=>', scopes: ['source.puppet', 'punctuation.separator.key-value.puppet']

    it "tokenizes attribute separator with string values", ->
      {tokens} = grammar.tokenizeLine('ensure => "present"')
      expect(tokens[1]).toEqual value: '=>', scopes: ['source.puppet', 'punctuation.separator.key-value.puppet']

  describe "blocks", ->
    it "tokenizes single quoted node", ->
      {tokens} = grammar.tokenizeLine("node 'hostname' {")
      expect(tokens[0]).toEqual value: 'node', scopes: ['source.puppet', 'meta.definition.class.puppet', 'storage.type.puppet']

    it "tokenizes double quoted node", ->
      {tokens} = grammar.tokenizeLine('node "hostname" {')
      expect(tokens[0]).toEqual value: 'node', scopes: ['source.puppet', 'meta.definition.class.puppet', 'storage.type.puppet']

    it "tokenizes include as an include function", ->
      {tokens} = grammar.tokenizeLine("contain foo")
      expect(tokens[0]).toEqual value: 'contain', scopes: ['source.puppet', 'meta.include.puppet', 'keyword.control.import.include.puppet']

    it "tokenizes contain as an include function", ->
      {tokens} = grammar.tokenizeLine('include foo')
      expect(tokens[0]).toEqual value: 'include', scopes: ['source.puppet', 'meta.include.puppet', 'keyword.control.import.include.puppet']

    it "tokenizes resource type and string title", ->
      {tokens} = grammar.tokenizeLine("package {'foo':}")
      expect(tokens[0]).toEqual value: 'package', scopes: ['source.puppet', 'meta.definition.resource.puppet', 'storage.type.puppet']
      expect(tokens[2]).toEqual value: "'foo'", scopes: ['source.puppet', 'meta.definition.resource.puppet', 'entity.name.section.puppet']

    it "tokenizes resource type and variable title", ->
      {tokens} = grammar.tokenizeLine("package {$foo:}")
      expect(tokens[0]).toEqual value: 'package', scopes: ['source.puppet', 'meta.definition.resource.puppet', 'storage.type.puppet']
      expect(tokens[2]).toEqual value: '$foo', scopes: ['source.puppet', 'meta.definition.resource.puppet', 'entity.name.section.puppet']

    it "tokenizes require classname as an include", ->
      {tokens} = grammar.tokenizeLine("require ::foo")
      expect(tokens[0]).toEqual value: 'require', scopes: ['source.puppet', 'meta.include.puppet', 'keyword.control.import.include.puppet']

    it "tokenizes require => variable as a parameter", ->
      {tokens} = grammar.tokenizeLine("require => Class['foo']")
      expect(tokens[0]).toEqual value: 'require ', scopes: ['source.puppet', 'constant.other.key.puppet']

    it "tokenizes regular variables", ->
      {tokens} = grammar.tokenizeLine('$foo')
      expect(tokens[0]).toEqual value: '$', scopes: ['source.puppet', 'variable.other.readwrite.global.puppet', 'punctuation.definition.variable.puppet']
      expect(tokens[1]).toEqual value: 'foo', scopes: ['source.puppet', 'variable.other.readwrite.global.puppet']

      {tokens} = grammar.tokenizeLine('$_foo')
      expect(tokens[0]).toEqual value: '$', scopes: ['source.puppet', 'variable.other.readwrite.global.puppet', 'punctuation.definition.variable.puppet']
      expect(tokens[1]).toEqual value: '_foo', scopes: ['source.puppet', 'variable.other.readwrite.global.puppet']

      {tokens} = grammar.tokenizeLine('$_foo_')
      expect(tokens[0]).toEqual value: '$', scopes: ['source.puppet', 'variable.other.readwrite.global.puppet', 'punctuation.definition.variable.puppet']
      expect(tokens[1]).toEqual value: '_foo_', scopes: ['source.puppet', 'variable.other.readwrite.global.puppet']

      {tokens} = grammar.tokenizeLine('$::foo')
      expect(tokens[0]).toEqual value: '$', scopes: ['source.puppet', 'variable.other.readwrite.global.puppet', 'punctuation.definition.variable.puppet']
      expect(tokens[1]).toEqual value: '::foo', scopes: ['source.puppet', 'variable.other.readwrite.global.puppet']

    it "tokenizes resource types correctly", ->
      {tokens} = grammar.tokenizeLine("file {'/var/tmp':}")
      expect(tokens[0]).toEqual value: 'file', scopes: ['source.puppet', 'meta.definition.resource.puppet', 'storage.type.puppet']

      {tokens} = grammar.tokenizeLine("package {'foo':}")
      expect(tokens[0]).toEqual value: 'package', scopes: ['source.puppet', 'meta.definition.resource.puppet', 'storage.type.puppet']

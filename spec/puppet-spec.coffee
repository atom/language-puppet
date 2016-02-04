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

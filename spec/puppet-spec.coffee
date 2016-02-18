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

    it 'tokenizes resource titles', ->
      {tokens} = grammar.tokenizeLine(manifest)
      expect(tokens[3]).toEqual value: 'title', scopes: ['source.puppet', 'meta.definition.resource.puppet', 'meta.title.puppet', 'name.title.puppet']

    it 'tokenizes resource parameter', ->
      {tokens} = grammar.tokenizeLine(manifest)
      expect(tokens[6]).toEqual value: 'parameter1', scopes: ['source.puppet', 'meta.definition.resource.puppet', 'meta.parameter.resource.puppet', 'name.parameter.resource.puppet']

    it 'tokenizes resource parameter separators', ->
      {tokens} = grammar.tokenizeLine(manifest)
      expect(tokens[8]).toEqual value: '=>', scopes: ['source.puppet', 'meta.definition.resource.puppet', 'meta.parameter.resource.puppet', 'punctuation.separator.key-value.puppet']


  describe "blocks", ->
    it "tokenizes single quoted node", ->
      {tokens} = grammar.tokenizeLine("node 'hostname' {")
      expect(tokens[0]).toEqual value: 'node', scopes: ['source.puppet', 'meta.definition.class.puppet', 'storage.type.puppet']

    it "tokenizes double quoted node", ->
      {tokens} = grammar.tokenizeLine('node "hostname" {')
      expect(tokens[0]).toEqual value: 'node', scopes: ['source.puppet', 'meta.definition.class.puppet', 'storage.type.puppet']
